#!/bin/bash -e

AWS_REGION="ap-southeast-2"
TF_STATE_BUCKET="tf-examples-terraform-state"
TF_STATE_LOCKS="tf-examples-terraform-locks"
ENVIRONMENT_NAME="DEV"
TF_VAR_stack_name="stack_raw_waio_ent_test_v2"


# only init will accept the backend config params
declare -g TF_BACKEND_CONFIG="\
-backend-config=region=${AWS_REGION} \
-backend-config=bucket=${TF_STATE_BUCKET} \
-backend-config=dynamodb_table=${TF_STATE_LOCKS} \
-backend-config=key=${TF_VAR_stack_name}/${ENVIRONMENT_NAME}/terraform.tfstate \
-backend-config=encrypt=false"

declare -g JQ_PLAN='
  (
    [.resource_changes[]?.change.actions?] | flatten
  ) | {
    "create":(map(select(.=="create")) | length),
    "update":(map(select(.=="update")) | length),
    "delete":(map(select(.=="delete")) | length)
  }
'

TFE_PARALLELISM=25
PLAN_CACHE="plan.cache"
PLAN_JSON="plan.json"

init() {
    # will create .terraform/terraform.tfstate
    #   terraform.tfstate only contains the backend info (e.g. s3 bucket name)
    #     normally, this would be the state for all resources, but since we're using a backend, it's just the backend details
    #   will not change terraform.tfstate if input params the same
    #   can be safely deleted - it will be recreated identcailly if params the same
    #   if input params change, you'll get a "change detected" error (if terraform.tfstate exists)
    #   if input params change and no state file exists, it will just create a new state file in the new location
    #   if you delete terraform.tfstate and re-run init with the same params, it will find the state file in s3 and re-use it again
    # does not create state in s3 or lock in dynamodb
    echo "Initialising terraform..."
    echo "TF_BACKEND_CONFIG=${TF_BACKEND_CONFIG}"
    eval terraform init -upgrade -compact-warnings "${TF_BACKEND_CONFIG}"
}

plan() {
  # creates state in s3 and lock in dynamodb
  echo "Planning terraform..."
  terraform plan -compact-warnings -lock=true -parallelism="${TFE_PARALLELISM}" -out="${PLAN_CACHE}" -refresh=false
}

apply() {
    # terraform plan does a plan and an apply in one, unless you specify the plan to use
    echo "Applying terraform..."
    terraform apply -compact-warnings -lock=true -auto-approve -parallelism="${TFE_PARALLELISM}" "${PLAN_CACHE}"
}

show() {
  # this will output a count of each create, update, and delete from plan
  echo "Showing terraform..."
  terraform show -json "${PLAN_CACHE}" | jq -r "${JQ_PLAN}" >"${PLAN_JSON}"
}

destroy() {
  # state will still remain
  echo "Destroying terraform..."
  terraform destroy -compact-warnings -lock=true -auto-approve -parallelism="${TFE_PARALLELISM}"
}

if [ "$1" = "init" ]; then
  init
  #init_params
elif [ "$1" = "plan" ]; then
  init
  plan
elif [ "$1" = "apply" ]; then
  init
  apply
elif [ "$1" = "show" ]; then
  init
  show
elif [ "$1" = "destroy" ]; then
  init
  destroy
else
  echo "Invalid parameter. Usage: $0 [param1 | param2]"
fi
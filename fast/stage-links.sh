#!/bin/bash
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ $# -eq 0 ]; then
  echo "pass one argument with the path to the output files folder or GCS bucket"
  exit 1
fi

if [[ "$1" == "gs://"* ]]; then
  CMD="gcloud alpha storage cp $1"
  CP_CMD=$CMD
elif [ ! -d "$1" ]; then
  echo "folder $1 not found"
  exit 1
else
  CMD="ln -s $1"
  CP_CMD="cp $1"
fi

GLOBALS="tfvars/globals.auto.tfvars.json"
PROVIDER_CMD=$CMD
STAGE_NAME=$(basename "$(pwd)")

case $STAGE_NAME in

"0-bootstrap")
  GLOBALS=""
  PROVIDER="providers/multitenant/${STAGE_NAME}-providers.tf"
  TFVARS=""
  ;;
"0-bootstrap-tenant")
  MESSAGE="remember to set the prefix in the provider file"
  PROVIDER_CMD=$CP_CMD
  PROVIDER="providers/multitenant/0-bootstrap-tenant-providers.tf"
  TFVARS="tfvars/0-bootstrap.auto.tfvars.json
  tfvars/1-resman.auto.tfvars.json"
  ;;
"0-bootstrap-multitenant")
  PROVIDER="providers/multitenant/0-mt-bootstrap-providers.tf"
  TFVARS="tfvars/0-bootstrap.auto.tfvars.json
  tfvars/1-resman.auto.tfvars.json"
  ;;
"1-resman")
  PROVIDER="providers/${STAGE_NAME}-providers.tf"
  TFVARS="tfvars/0-bootstrap.auto.tfvars.json"
  ;;
"1-resman-tenant")
  if [[ -z "$TENANT" ]]; then
    TENANT="\${TENANT}"
  fi
  PROVIDER="tenants/${TENANT}/providers/1-resman-providers.tf"
  TFVARS="tenants/${TENANT}/tfvars/0-bootstrap.auto.tfvars.json"
  ;;
"2-"*)
  PROVIDER="providers/multitenant/${STAGE_NAME}-providers.tf"
  TFVARS="tfvars/0-bootstrap.auto.tfvars.json
  tfvars/1-resman.auto.tfvars.json"
  ;;
*)
  # check for a "dev" stage 3
  echo "trying for parent stage 3..."
  STAGE_NAME=$(basename $(dirname "$(pwd)"))
  if [[ "$STAGE_NAME" == "3-"* ]]; then
    PROVIDER="providers/${STAGE_NAME}-providers.tf"
    TFVARS="tfvars/0-bootstrap.auto.tfvars.json
    tfvars/1-resman.auto.tfvars.json
    tfvars/2-networking.auto.tfvars.json
    tfvars/2-security.auto.tfvars.json"
  else
    echo "stage '$STAGE_NAME' not found"
  fi
  ;;

esac

echo -e "copy and paste the following commands for '$STAGE_NAME'\n"

echo "$PROVIDER_CMD/$PROVIDER ./"
echo "$CMD/$GLOBALS ./"

for f in $TFVARS; do
  echo "$CMD/$f ./"
done

if [[ -v MESSAGE ]]; then
  echo -e "\n---> $MESSAGE <---"
fi
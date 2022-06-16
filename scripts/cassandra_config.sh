#!/bin/bash

set -exv

function check_deps() {
  test -f $(which jq) || error_exit "jq command not detected in path, please install it"
  test -f $(which az) || error_exit "az command not detected in path, please install it"
}

function parse_input() {
  eval "$(jq -r '@sh "export AZ_TENANT=\(.tenant_id)"')"
  if [[ -z "${AZ_TENANT}" ]]; then export AZ_TENANT=none; fi
}


function az_login() {
  OPTIONS=(--service-principal --username ${TF_VAR_azuread_application_id} --password=${TF_VAR_azuread_client_secret} --tenant ${AZ_TENANT})
  # eval "$(az login --service-principal --username ${TF_VAR_azuread_application_id} --password=${TF_VAR_azuread_client_secret} --tenant ${AZ_TENANT})"
  az login "${OPTIONS[@]}"
}

function set_subscription() {
  OPTIONS=(--subscription "tnt-nonproduction1-kubernetes")
  # eval "$(az account set --subscription "$SUBSCRIPTION_NAME")"
  az account set "${OPTIONS[@]}"
}

check_deps
parse_input
az_login


#az login --service-principal --username=${TF_VAR_azuread_application_id} --password=${TF_VAR_azuread_client_secret} --tenant=${AZ_TENANT} --verbose

eval "$(jq -r '@sh "CLUSTER_NAME=\(.cluster_name) RESOURCE_GROUP=\(.resource_group) SUBSCRIPTION_NAME=\(.subscription_name)"')"

set_subscription

#az account set --subscription "$SUBSCRIPTION_NAME" --verbose

PROPERTIES=$(az managed-cassandra cluster show --cluster-name "castntcluster-cassandra" --resource-group "neur-tntnpk-nonprod-mytnt2-rg" --subscription "tnt-nonproduction1-kubernetes" --query "properties" -o json)

jq -n --arg properties "$PROPERTIES" '{"properties":$properties}'

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
  OPTIONS=(--service-principal --username ""${azuread_application_id} --password=${azuread_client_secret} --tenant ${AZ_TENANT})
  az login "${OPTIONS[@]}"
}

function set_subscription() {
  OPTIONS=(--subscription ${SUBSCRIPTION_NAME})
  az account set "${OPTIONS[@]}"
}

check_deps
parse_input
az_login

eval "$(jq -r '@sh "CLUSTER_NAME=\(.cluster_name) RESOURCE_GROUP=\(.resource_group) SUBSCRIPTION_NAME=\(.subscription_name)"')"

set_subscription

PROPERTIES=$(az managed-cassandra cluster show --cluster-name SUBSCRIPTION_NAME --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION_NAME --query "properties" -o json)

jq -n --arg properties "$PROPERTIES" '{"properties":$properties}'

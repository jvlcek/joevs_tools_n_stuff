#!/usr/bin/env bash

function print_curl_examples {
  if [ "$1" == "" ]; then
    error_exit "No MiQ Appliance hostname or ipaddr specified"
  fi

  miq_ipaddr="${1}"
  http_port="80" 
  https_port="443" 
  port="${https_port}"

  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# User jsonpp or jq to pretty print the API output"
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# curl to appliance at IPAddr ->${1}<-"
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# curl to GET the tip of /api"
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}:${port}/api/ | jq "
  echo ""

  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# curl for automate_domains"
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "# GET vms with filtering"
  echo "# --------------------------------------------------"

  echo "  curl --user admin:smartvm --insecure --request GET --header \"Content-Type: application/json\" -G https://${miq_ipaddr}:${port}/api/vms -d \"expand=resources&attributes=name\" -d \"filter[]=name='JoeV*'\" | jq "
  echo ""

  echo "# GET automate_domains"
  echo "# --------------------------------------------------"

  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}:${port}/api/automate_domains | jq "
  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}:${port}/api/automate_domains/1 | jq "
  echo ""

  echo "# POST automate_domains create_from_git from github"
  echo "# --------------------------------------------------"
  echo ""

  echo "  curl -k --user admin:smartvm -i -X  POST -H \"Content-Type: application/json\" -H \"Accept: application/json\" -d ' { \"action\": \"create_from_git\", \"resources\": [{ \"git_url\": \"https://github.com/jvlcek/SimpleDomain\", \"ref_type\": \"branch\", \"ref_name\": \"master\" }] }' https://${miq_ipaddr}:${port}/api/automate_domains"
  echo ""

  echo "# POST automate_domains create_from_git from gitlab"
  echo "# --------------------------------------------------"
  echo ""

  echo "  curl -k --user admin:smartvm -i -X  POST -H \"Content-Type: application/json\" -H \"Accept: application/json\" -d  @/Users/jvlcek/MYJUNK/scripts/action_create_from_gitlab  https://${miq_ipaddr}:${port}/api/automate_domains"
  echo ""

  echo "# GET query miq task"
  echo "# --------------------------------------------------"
  echo ""

  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}:${port}/api/tasks/69 | jq "
  echo ""

  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# curl for users "
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "# GET users"
  echo "# --------------------------------------------------"
  echo ""

  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}:${port}/api/users | jq"
  echo ""

  echo "# POST create users"
  echo "# --------------------------------------------------"
  echo ""

  echo "  curl -k --user admin:smartvm -i -X  POST -H \"Content-Type: application/json\" -H \"Accept: application/json\" -d  @/Users/jvlcek/MYJUNK/scripts/action_create_users https://${miq_ipaddr}:${port}/api/users"
  echo ""

  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# curl for tenants "
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "# GET tenants"
  echo "# --------------------------------------------------"
  echo ""

  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}:${port}/api/tenants | jq"
  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}:${port}/api/tenants/1 | jq"
  echo ""

  echo "# POST create tenants"
  echo "# --------------------------------------------------"
  echo "  curl -k --user admin:smartvm -i -X  POST -H \"Content-Type: application/json\" -H \"Accept: application/json\" -d@/Users/jvlcek/MYJUNK/scripts/action_create_tenants  https://${miq_ipaddr}:${port}/api/tenants"
  echo ""

  echo "# POST edit tenants"
  echo "# --------------------------------------------------"
  echo "  curl -k --user admin:smartvm -i -X  POST -H \"Content-Type: application/json\" -H \"Accept: application/json\" -d@/Users/jvlcek/MYJUNK/scripts/action_edit_tenants  https://${miq_ipaddr}:${port}/api/tenants/2"
  echo ""

  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# curl for quotas "
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "# GET quotas"
  echo "# --------------------------------------------------"
  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}:${port}/api/tenants/2/quotas | jq"
  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}:${port}/api/tenants/2/quotas/7 | jq"
  echo ""

  echo "# GET quotas Virtual Attributes used allocated and available"
  echo "# --------------------------------------------------"
  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}:${port}/api/tenants/2/quotas/7?attributes=used,allocated,available | jq"
  echo ""

  echo "# OPTIONS list all available attributes included virtual attributes"
  echo "# --------------------------------------------------"
  echo "  curl --user admin:smartvm -k -X OPTIONS -H \"Accept: application/json\" https://${miq_ipaddr}:${port}/api/vms | jq"
  echo ""

}

function error_exit {
  echo "ERROR EXITING: $1"
  exit 22
}

function main {
  print_curl_examples $1
}

main $1

#!/usr/bin/env bash

function print_curl_examples {
  if [ "$1" == "" ]; then
    error_exit "No MiQ Appliance hostname or ipaddr specified"
  fi

  miq_ipaddr="${1}"
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# curl to appliance at IPAddr ->${1}<-"
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# curl to GET the tip of /api"
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}/api/ | jsonpp "
  echo ""

  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# curl for automate_domains"
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "# GET automate_domains"
  echo "# --------------------------------------------------"

  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}/api/automate_domains | jsonpp "
  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}/api/automate_domains/1 | jsonpp "
  echo ""

  echo "# POST automate_domains create_from_git from github"
  echo "# --------------------------------------------------"
  echo ""

  echo "  curl -k --user admin:smartvm -i -X  POST -H \"Content-Type: application/json\" -H \"Accept: application/json\" -d ' { \"action\": \"create_from_git\", \"resources\": [{ \"git_url\": \"https://github.com/jvlcek/SimpleDomain\", \"ref_type\": \"branch\", \"ref_name\": \"master\" }] }' https://${miq_ipaddr}/api/automate_domains"
  echo ""

  echo "# POST automate_domains create_from_git from gitlab"
  echo "# --------------------------------------------------"
  echo ""

  echo "  curl -k --user admin:smartvm -i -X  POST -H \"Content-Type: application/json\" -H \"Accept: application/json\" -d  @/Users/jvlcek/MYJUNK/scripts/action_create_from_gitlab  https://${miq_ipaddr}/api/automate_domains"
  echo ""

  echo "# GET query miq task"
  echo "# --------------------------------------------------"
  echo ""

  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}/api/tasks/69 | jsonpp "
  echo ""

  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# curl for users "
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "# GET users"
  echo "# --------------------------------------------------"
  echo ""

  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}/api/users | jsonpp"
  echo ""

  echo "# POST create users"
  echo "# --------------------------------------------------"
  echo ""

  echo "  curl -k --user admin:smartvm -i -X  POST -H \"Content-Type: application/json\" -H \"Accept: application/json\" -d  @/Users/jvlcek/MYJUNK/scripts/action_create_users https://${miq_ipaddr}/api/users"
  echo ""

  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# curl for tenants "
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "# GET tenants"
  echo "# --------------------------------------------------"
  echo ""

  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}/api/tenants | jsonpp"
  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}/api/tenants/1 | jsonpp"
  echo ""

  echo "# POST create tenants"
  echo "# --------------------------------------------------"
  echo "  curl -k --user admin:smartvm -i -X  POST -H \"Content-Type: application/json\" -H \"Accept: application/json\" -d@/Users/jvlcek/MYJUNK/scripts/action_create_tenants  https://${miq_ipaddr}/api/tenants"
  echo ""

  echo "# POST edit tenants"
  echo "# --------------------------------------------------"
  echo "  curl -k --user admin:smartvm -i -X  POST -H \"Content-Type: application/json\" -H \"Accept: application/json\" -d@/Users/jvlcek/MYJUNK/scripts/action_edit_tenants  https://${miq_ipaddr}/api/tenants/2"
  echo ""

  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo "# curl for quotas "
  echo "# +-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-=+-="
  echo ""

  echo "# GET quotas"
  echo "# --------------------------------------------------"
  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}/api/tenants/2/quotas | jsonpp"
  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}/api/tenants/2/quotas/7 | jsonpp"
  echo ""

  echo "# GET quotas Virtual Attributes used allocated and available"
  echo "# --------------------------------------------------"
  echo "  curl --user admin:smartvm -k -X GET -H \"Accept: application/json\" https://${miq_ipaddr}/api/tenants/2/quotas/7?attributes=used,allocated,available | jsonpp"
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

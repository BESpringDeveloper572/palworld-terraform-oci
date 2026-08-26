#!/bin/sh

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

(
  cd terraform
  cp terraform.tfvars.sample terraform.tfvars
  terraform init
  terraform apply
)

(
  cd ansible
  cp group_vars/palworld_servers.yml.sample group_vars/palworld_servers.yml
#  ansible-playbook deploy-palworld.yml
)
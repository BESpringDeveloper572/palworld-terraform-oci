#!/bin/sh

set -e

(
  cd terraform
  cp terraform.tfvars.example terraform.tfvars
  terraform init
  terraform apply
)

(
  cd ansible
  cp group_vars/palworld_server.yml.sample group_vars/palworld_server.yml
  ansible-playbook deploy-palworld.yml
)
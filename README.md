# Create a Palworld server on Oracle Cloud Infrastructure for FREE

## Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Ansible](https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_installation.html)

## Features
- Deploys server in Oracle Cloud Infrastructure (OCI) with networking to prevent malicious attacks
- Backup Palworld server into S3 Object Store in OCI in the event Oracle shuts down your server
- Useful script to restart server

## Installation
1. [Create a Oracle Cloud Infrastructure (OCI) account](https://www.oracle.com/cloud/free/) 
1. Create a compartment with whatever name you want and save the OCID for it somewhere
1. [Create a API key pair](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two) and bind it to your root user. Save the fingerprint somewhere for later.
1. Go into terraform.tfvars.sample and fill in the fields (I used a password for my key pair, but you don't have to. You will need to delete the variable and the line where it's used if you do.). For `image_id`, go [here](https://docs.oracle.com/en-us/iaas/images/ubuntu-2404/canonical-ubuntu-24-04-minimal-aarch64-2026-07-17-0.htm) and look for your region (feel free to use a different OS but you will have to rename remote_user in Ansible scripts). Rename terraform.tfvars.sample to terraform.tfvars. 
1. Now go into your terminal and go to terraform directory and run `terraform init`.
1. If you just created your account, update line 5 of `terraform/modules/server/server.tf` to `VM.Standard.A2.Flex`, else skip to step 10. You will create a paid instance temporarily then downgrade to a free tier instance. Otherwise, you may get Out of Host Capacity error when creating.
1. Run `terraform apply` and type "yes" when prompted. Save your public ip address.
1. If you updated line 5, change it back to `VM.Standard.A1.Flex` and run `terraform apply`.
1. Now go into the ansible directory and update hosts.ini.sample and rename to hosts.ini.
   (Public ip should be outputted after terraform apply)
1. Update the vars in ansible/group_vars/palworld_server.yml.sample and rename to palworld_server.yml. (timezone should be like CST, PST, etc)
1. Create a new ssh-key pair (**DIFFERENT** from the one used for your OCI account). Use this [guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to generate (notice it is different from one generated before with .pub files)
1. Go into Ansible directory and run `ansible-playbook deploy-palworld.yml --ask-pass` If you get permission denied, run `ssh-add <path-to-ssh-key>` first.
1. Wait about 10-20 min for server to full launch.

### Untested automated script instructions
1. Fill out `terraform/terraform.tfvars.sample` and `ansible/group_vars/palworld_server.yml.sample`
2. Run `./deploy-and-run.sh`

- If you are unable to see/connect to your server after about an hour after deploy, run restart. I've had issues where download gets stuck. 

## Maintenance

### Restart server
1. Run `ansible-playbook restart-palworld.yml`.

### Create manual backup
1. Run `ansible-playbook create-manual-backup.yml`.
2. Download newly created backup from keep directory in your [bucket](https://cloud.oracle.com/object-storage/buckets).

### Restore from backup
- Run `ansible-playbook upload-backup.yml -e "palworld_backup_tar=<file-name>"` to copy your backup from Object Store into server. Put keep/ in front of filename if the file is in keep directory.
- To restore from backup, ssh into server and run `docker exec -it palworld-server restore`. This command will look in `/opt/palworld/backups` so if you had to recreate your server, download from Object Store and move here.
- Backups are periodically saved in [OCI Object Store](https://cloud.oracle.com/object-storage/buckets) in your compartment with bucket name `palworld-backups`.
- Backups are deleted after 14 days so either download saves to your computer or move backups to `/keep/` directory in [bucket](https://cloud.oracle.com/object-storage/buckets). Backups moved there are not deleted.

### Configuration
- Server config is saved in `/opt/palworld/` **on the server**.

### Delete resources
- To just destroy the server, run `terraform destroy -target=module.server`.
- To remove everything in your server (ensure you want to do this and you have your backups stored on your computer), run `terraform destroy`. The server and bucket are the only things we may cost money so this can be overkill.

## More information
- Make sure to **keep** your ssh key for your server (the non pem/pub files). You will need this to restart the server or go into the server for maintenance (like restoring a backup).
- After you are done with `terraform` commands, unpair your API key pair just to make sure no one creates/deletes stuff in your account. You can also delete the pem files (**not the one without a filename extension**) If you ever need to delete your server, do it from the [console](https://www.oracle.com/cloud/free/) or[ create a new API key pair](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two).
- You can skip steps 7 and 8 if you upgrade to Pay As You Go (PAYG). If you upgrade to PAYG, you can update your ocpus from 2 to 4 and memory from 12 to 24 (which allows you to have more players), but be careful as you may accidentally be charged due to [June 2026 free tier changes](https://www.cnelecar.com/blog/oracle-always-free-arm-limits-cut-2026/).
- To ensure you don't get charged, [set up a budget alert](https://docs.oracle.com/en-us/iaas/Content/Billing/Tasks/create-alert-rule.htm).
- Be aware that things may change in the future and Oracle can shut down your server at any time (and may be even your account). I'd suggest to copy your server backup to your computer every once in a while.
- Backups are created everyday at midnight by Palworld and my cron job will upload them to Object Store at 3AM/3PM. You can configure backups by adding [these variables](https://github.com/supersunho/docker-palworld-server#backups) into the envs for [docker](ansible/roles/palworld/tasks/main.yml) under env.

- There is a branch called `thijsvanloef` that uses their Docker image. It is more configurable with more frequent updates, but it is less compatible with Oracle's Ampere servers since they are ARM64.

If you are stuck on any steps or need additional info, please look over official documentation for [Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/devtoolshome.htm) or [Ansible](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_intro.html) or [Palworld](https://hub.docker.com/r/thijsvanloef/palworld-server-docker).

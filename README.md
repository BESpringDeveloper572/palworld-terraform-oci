# Create a Palworld server on Oracle Cloud Infrastructure for FREE

## Prerequisites
- Terraform
- Ansible

## Features
- Deploys server in Oracle Cloud Infrastructure (OCI) with networking to prevent malicious attacks
- Backup Palworld server into S3 Object Store in OCI in the event Oracle shuts down your server
- Useful script to restart server

## Steps
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

### Restart server
1. Run `ansible-playbook restart-palworld`.

### Restore from backup
- Backups are periodically saved in OCI Object Store in your compartment with bucket name `palworld-backups`.
- Backups are deleted after 14 days so either download saves to your computer or move backups to `/keep/` directory in bucket. Backups moved there are not deleted.
- To restore from backup, ssh into server and run `docker exec -it palworld-server restore`. This command will look in `/opt/palworld/backups` so if you had to recreate your server. Just download from Object Store and move here.

### Configuration
- Server config is saved in `/opt/palworld/` **on the server**.

## Delete resource
- To just destroy the server, run `terraform destroy -target=module.server`.
- To remove everything in your server (ensure you want to do this and you have your backups stored on your computer), run `terraform destroy`.

## More information
- Make sure to **keep** your ssh key for your server (the non pem/pub files). You will need this to restart the server or go into the server to maintenance (like restoring a backup).
- After you are done with `terraform` commands, unpair your API key pair just to make sure no one creates/deletes stuff in your account. You can also delete the pem files (**not the one without a filename extension**) If you ever need to delete your server, do it from the [console](https://www.oracle.com/cloud/free/) or create a new API key pair.
- You can skip steps 7 and 8 if you upgrade to Pay As You Go (PAYG). If you upgrade to PAYG, you can update your ocpus from 2 to 4 and memory from 12 to 24 (which allows you to have more players), but be careful as you may accidentally be charged due to [June 2026 free tier changes](https://www.cnelecar.com/blog/oracle-always-free-arm-limits-cut-2026/).
- To ensure you don't get charged, [set up a budget alert](https://docs.oracle.com/en-us/iaas/Content/Billing/Tasks/create-alert-rule.htm).
- Be aware that things may change in the future and Oracle can shut down your server at any time (and may be even your account). I'd suggest to copy your server backup to your computer every once in a while.
- Add AUTO_UPDATE_CRON_EXPRESSION and BACKUP_CRON_EXPRESSION to deploy-palworld.yml under env to a time when you think people won't be online. It defaults to around 2 AM in the timezone you set (my friends are nocturnal so I'll probably change this myself).

If you are stuck on any steps or need additional info, please look over official documentation for [Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/devtoolshome.htm) or [Ansible](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_intro.html) or [Palworld](https://hub.docker.com/r/thijsvanloef/palworld-server-docker).

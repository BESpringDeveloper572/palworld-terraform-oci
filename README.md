# Create a Palworld server on Oracle Cloud Infrastructure for FREE

## Prerequisites
- Terraform
- Ansible


## Steps
1. [Create a Oracle Cloud Infrastructure (OCI) account](https://www.oracle.com/cloud/free/) 
2. Create a compartment with whatever name you want and save the OCID for it somewhere
3. (Optional) This next part will go over how to create a user with limited permissions to create your server. You can skip this and use your root user, but I'd recommend creating it in case somehow someone gets your SSH key
   1. Go to your default domain (Identity & Security -> Domains) -> Settings -> Domain settings - Locale and click Edit Domain Settings. Uncheck primary email address is required.
   2. Go to user management tab in domain and create a group. There will be a section to create a policy for this group. Create a policy with the following 
   ```text
   Allow group 'Default'/'<your-group-name>' to manage instance-family in compartment <your-compartment-name>
   Allow group 'Default'/'<your-group-name>' to read app-catalog-listing in tenancy
   Allow group 'Default'/'<your-group-name>' to read volume-family in compartment <your-compartment-name>
   allow group 'Default'/'<your-group-name>'  to inspect tenancies in tenancy
   Allow group 'Default'/'<your-group-name>' to manage virtual-network-family in compartment <your-compartment-name>
   Allow group 'Default'/'<your-group-name>' to read vaults in compartment <your-compartment-name>
   Allow group 'Default'/'<your-group-name>' to read secret-family in compartment <your-compartment-name>
   Allow group 'Default'/'<your-group-name>' to manage object-family in compartment palworld
   ```
   3. In the same user management tab, create a user and assign it to this group
1. [Create a API key pair](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two) and bind it to your root user or the user created in step 3 if you did it. Save the fingerprint somewhere for later.
1. Go into terraform.tfvars.sample and fill in the fields (I used a password for my key pair, but you don't have to. You will need to delete the variable and the line where it's used if you do.). Rename terraform.tfvars.sample to terraform.tfvars. 
1. Now go into your terminal and go to terraform directory and run `terraform init`.
1. If you just created your account, update line 5 of `terraform/modules/server/server.tf` to `VM.Standard.A2.Flex`, else skip to step 10. You will create a paid instance temporarily then downgrade to a free tier instance. Otherwise, you may get Out of Host Capacity error when creating.
1. Run `terraform apply` and type "yes" when prompted. Save your public ip address.
1. If you updated line 5, change it back to `VM.Standard.A1.Flex` and run `terraform apply`.
1. Now go into the ansible directory and update hosts.ini.sample and rename to hosts.ini.
   (Public ip should be outputted after terraform apply)
1. Update the vars in ansible/group_vars/palworld_server.yml.sample and rename to palworld_server.yml. (timezone should be like CST, PST, etc)
1. Create a new ssh-key pair (**DIFFERENT** from the one used for your OCI account). Use this [guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to generate (notice it is different from one generated before with .pub files)
1. Go into Ansible directory and run `ANSIBLE_PRIVATE_KEY_FILE=<path-to-non-pub-file-generated-for-ssh-key> ansible-playbook deploy-palworld.yml --ask-pass`.

## Tips and Tricks
- You can skip steps 7 and 8 if you upgrade to Pay As You Go (PAYG). If you upgrade to PAYG, you can update your ocpus from 2 to 4 and memory from 12 to 24 (which allows you to have more players), but be careful as you may accidentally be charged due to June 2026 free tier changes.
- Be aware that things may change in the future and Oracle can shut down your server at any time (and may be even your account). I'd suggest to copy your server backup to a hard drive every once in a while.
- Add AUTO_UPDATE_CRON_EXPRESSION and BACKUP_CRON_EXPRESSION to deploy-palworld.yml under env to a time when you think people won't be online. It defaults to around 2 AM in the timezone you set (my friends are nocturnal so I'll probably change this myself).

If you are stuck on any steps, please look over official documentation for [Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/devtoolshome.htm) or [Ansible](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_intro.html).

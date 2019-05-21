#Vars that we can tweak
#Whether to use the userdata handler or the tags script to get vars
# for ansible.
#   True: use the ec2-handler.tf system and related config
#   False: use the ec2-tags.tf system and related config
variable "instance_type" {
  default = "simple"
  description = "Which single type of instance to create. ['simple', 'handler', 'tags']?"
}

#Define the repo we want to use for anisble pull:
# Setting to "AWS" will create and use a codecommit repo.
# Setting to "Other" will use the repo address below
variable "repo_type" {
  default = "AWS"
  description = "Repo Source for Ansible Pull"
}
variable "repo_address" {
  default = "https://github.com/G42makes/terraform-ansible-handoff.git"
}

#SSH key to use, this will default to your personal pub key
variable "public_key_filename" {
  default = "~/.ssh/id_rsa_aws.pub"
}
#We need the private key filename as well, for the code upload.
variable "private_key_filename" {
  default = "~/.ssh/id_rsa_aws"
}

#If we are using the aws git repos, we upload the above SSH key into this account.
variable "codecommit_user" {
  default = "jyoung"
  description = "Leave blank to not upload any new keys"
}

#Set the name of the repo on codecommit to use.
variable "codecommit_repo" {
  default = "terraform-ansible-handoff"
}

#Tags to use for the instances and that will be passed to ansible
variable "instance_tags" {
  type = "map"
  default = {
    "test1" = "one",
    "test2" = "2",
  }
}

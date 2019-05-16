#Vars that we can tweak
#Whether to use the userdata handler or the tags script to get vars
# for ansible.
#   True: use the ec2-handler.tf system and related config
#   False: use the ec2-tags.tf system and related config
variable "instance_type" {
  default = "simple"
  description = "Which single type of instance to create. ['simple', 'handler', 'tags']?"
}

#SSH key to use, this will default to your personal pub key
variable "public_key_filename" {
  default = "~/.ssh/id_rsa.pub"
}

#Tags to use for the instances and that will be passed to ansible
variable "instance_tags" {
  type = "map"
  default = {
    "test1" = "one",
    "test2" = "2",
  }
}

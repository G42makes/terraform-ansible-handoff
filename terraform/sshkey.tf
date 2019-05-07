#Add and use your local keypair
locals {
  public_key_filename = "~/.ssh/id_rsa.pub"
}

resource "aws_key_pair" "tf-ansible" {
  key_name = "tf-ansible"
  public_key = "${file("${local.public_key_filename}")}"
}

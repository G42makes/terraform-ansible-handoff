#Add and use your local keypair
variable "public_key_filename" {
  default = "~/.ssh/id_rsa.pub"
}

resource "aws_key_pair" "tf-ansible" {
  key_name = "tf-ansible"
  public_key = "${file("${var.public_key_filename}")}"
}

#Add and use your local keypair
resource "aws_key_pair" "tf-ansible" {
  key_name = "tf-ansible"
  public_key = "${file("${var.public_key_filename}")}"
}

#create the actual instance and userdata
resource "aws_instance" "handoff" {
  ami = "${data.aws_ami.ubuntu_18_04.id}"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.handoff_profile.name}"
  tags {
    Name = "handoff"
    Test1 = "one"
    Test2 = "two"
  }
  key_name = "${aws_key_pair.tf-ansible.key_name}"
}

#create the actual instance and userdata
resource "aws_instance" "handler" {
  count = "${var.use_hander}"
  ami = "${data.aws_ami.ubuntu_18_04.id}"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.handler_profile.name}"
  tags = "${merge(
    map(
      "Name", "handler"
    ),
    var.instance_tags)}"
  key_name = "${aws_key_pair.tf-ansible.key_name}"
  user_data_base64 = "${data.template_cloudinit_config.config.rendered}"
}

#Generate our files for a multi-part cloud-init data block.
data "template_cloudinit_config" "config" {
  gzip = true
  base64_encode = true

  #The same userdata file for both variations
  part {
    content_type = "text/x-shellscript"
    filename = "userdata.sh"
    content = "${file("userdata.sh")}"
  }
  #We need to tell cloud init what to do with our "application/json"
  #   data. This handler accepts it, and with the filename writes it
  #   out to /run/cloud-init/<filename>
  part {
    content_type = "text/part-handler"
    filename = "handler-json.py"
    content = "${file("handler-json.py")}"
  }
  #And this is the collection of vars that we want to pass to our
  #   ansible process to be used as needed from there.
  # You may want to add the hostname here, but it's not automatic.
  part {
    content_type = "application/json"
    filename = "user-vars.json"
    content = "${jsonencode(var.instance_tags)}"
  }
}

#Create our policies/roles and connections.
data "aws_iam_policy_document" "handler_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals = {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"],
    }
  }
}
resource "aws_iam_role" "handler_role" {
  count = "${var.use_hander}"
  name = "handler_role"
  assume_role_policy = "${data.aws_iam_policy_document.handler_role.json}"
}
resource "aws_iam_instance_profile" "handler_profile" {
  count = "${var.use_hander}"
  name = "handler_profile"
  role = "${aws_iam_role.handler_role.name}"
}
resource "aws_iam_policy_attachment" "handler_policy" {
  count = "${var.use_hander}"
  name = "handler_policy"
  roles = ["${aws_iam_role.handler_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

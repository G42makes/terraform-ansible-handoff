## Using ec2 host tags and the userdata script to extract values.
#create the actual instance and userdata
resource "aws_instance" "tags" {
  count = "${var.instance_type == "tags" ? 1 : 0}"
  ami = "${data.aws_ami.ubuntu_18_04.id}"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.tags_profile.name}"
  tags = "${merge(
    map(
      "Name", "tags"
    ),
    var.instance_tags)}"
  key_name = "${aws_key_pair.tf-ansible.key_name}"
  user_data = "${file("userdata.sh")}"
}

#Create our policies/roles and connections.
data "aws_iam_policy_document" "tags_role" {
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
resource "aws_iam_role" "tags_role" {
  count = "${var.instance_type == "tags" ? 1 : 0}"
  name = "tags_role"
  assume_role_policy = "${data.aws_iam_policy_document.tags_role.json}"
}
resource "aws_iam_instance_profile" "tags_profile" {
  count = "${var.instance_type == "tags" ? 1 : 0}"
  name = "tags_profile"
  role = "${aws_iam_role.tags_role.name}"
}
resource "aws_iam_policy_attachment" "tags_policy" {
  count = "${var.instance_type == "tags" ? 1 : 0}"
  name = "tags_policy"
  roles = ["${aws_iam_role.tags_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# Create and attach a policy that allows this instance to read ec2 tags.
#   AWS does not let us restrict to only our own tags that I have seen/tested.
data "aws_iam_policy_document" "tags_read_policy" {
  statement {
    sid = "Stmt1557408958537"
    actions = [
      "ec2:DescribeTags",
    ]
    resources = [
      "*"
    ]
  }
}
resource "aws_iam_policy" "tags_read_policy" {
  count = "${var.instance_type == "tags" ? 1 : 0}"
  name = "tags_read_policy"
  description = "Allow the handoff system to read it's own tags"

  policy = "${data.aws_iam_policy_document.tags_read_policy.json}"
}
resource "aws_iam_policy_attachment" "tags_read_policy" {
  count = "${var.instance_type == "tags" ? 1 : 0}"
  name = "tags_read_policy"
  roles = ["${aws_iam_role.tags_role.name}"]
  policy_arn = "${aws_iam_policy.tags_read_policy.arn}"
}

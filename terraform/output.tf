#outputs for usability
output "ip" {
  value = "${aws_instance.handler.0.public_ip}"
}
output "dns" {
  value = "${aws_instance.handler.0.public_dns}"
}

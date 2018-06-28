
resource "aws_instance" "proxy" {
  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(data.terraform_remote_state.networking.public_subnets,0)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.proxy_sg.id}"]
  #key_name                    = "${var.key_name}"

  #tags = "${merge(
  #  local.common_tags,
  #  map(
  #    "Name", "ddt_bastion_host",
  #  )
  #)}"
}

## TODO eip
resource "aws_eip" "proxy" {
  instance = "${aws_instance.proxy.id}"
  vpc      = true
}

## TODO proxy_sg

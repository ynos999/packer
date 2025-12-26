packer {
  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = ">= 1.0.0"
    }
  }
}

source "virtualbox-iso" "ubuntu" {
  iso_url          = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum     = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"

  vm_name          = "ubuntu-22.04-packer"
  guest_os_type    = "Ubuntu_64"
  cpus             = 4
  memory           = 4096
  output_directory = "output-ubuntu"

  # SSH iestatījumi (definēti tikai VIENU reizi)
  ssh_username           = "packer"
  ssh_password           = "packer"
  ssh_timeout            = "60m"
  ssh_handshake_attempts = 100
  ssh_host_port_min      = 2222
  ssh_host_port_max      = 2222

  # VirtualBox tīkla stabilitātei
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--natdnshostresolver1", "on"]
  ]

  http_directory    = "http"
  http_bind_address = "0.0.0.0"

  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"

  boot_wait = "15s"
  boot_command = [
    "e<wait>",
    "<down><down><down>",
    "<end>",
    "<bs><bs><bs>",
    # Izmantojam pēdiņas, lai izvairītos no semikola interpretācijas kļūdām
    " autoinstall \"ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\"",
    "<enter><wait>",
    "<f10>"
  ]
}

build {
  sources = ["source.virtualbox-iso.ubuntu"]

  provisioner "shell" {
    pause_before = "20s"
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io"
    ]
  }
}
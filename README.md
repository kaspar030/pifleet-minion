# Introduction

The Pi fleet is a centrally provisioned network of Raspberry Pi's used for
testing / developing the RIOT operating system. It's main purpose is to
provide both maintainers and the CI system with access to target boards that
might be needed for testing purposes.

## Overview

The fleet consist of a server running a salt master instance that is used to
set up users, networking, ... on a bunch of Raspberry Pis.
This repository contains the scripts and files to set up a Pi fleet base image.

Currently it does the following:

- at first boot, set hostname to "pi-\${cpu serial number}"
- install salt-minion, set up pihub.riot-labs.de as master

## How-to

Set up qemu-arm-static and binfmt-support.

On Arch Linux, install "qemu-user-static" and "qemu-user-static-binfmt".

On Debian, run this:

```bash
sudo apt-get install -y qemu qemu-user-static binfmt-support qemu-system-arm
```

Download and unzip a Raspian image.

Run

```bash
sudo ./setup_image.sh <Raspian image>
```

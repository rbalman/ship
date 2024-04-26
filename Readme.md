Bare minimum shell based container run time built just for fun. :warning: Not a production grade tool in any ways.

## Features
  - Run the container using exported filesystem
  - Exec inside the container
  - Remove container
  - Tail logs of the container
  - List the containers

## Limitations
  - Containers run in the foreground.
  - Containers Prompt is borken.
  - Containers networking doesn't work by default.
  - Containers Security and Capabilities are not supported.
  - Layer Fileystem is not supported.

## Installation

### System requirements
  - libcgroup-tools

```shell
sudo curl -o /usr/bin/ship <download url> 
```

## Available Commands
```shell
Commands:
  run <root_fs_path> [<command>]    Run a new container
  exec <container_id> <command>     Execute a command inside a running container
  rm <container_id>                 Remove a container
  logs <container_id>               tail logs
  ps                                List all running containers
```

## Examples
- Download the file system
```shell
mkdir alpine-image && cd alpine-image
curl -o alpine-rootfs.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-minirootfs-3.19.1-x86_64.tar.gz
tar -xvf alpine-rootfs.tar.gz
cd ..
```

```shell
  ./ship ps
  sudo ./ship run ./alpine-rootfs /bin/sh
  sudo ./ship exec <container-id>
  ./ship stop container-id
```
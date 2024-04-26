Bare minimum shell based container run time built just for fun. :warning: Not a production grade tool in any ways.

## Features
  - Run the container using exported filesystem
  - Exec inside the container
  - Remove container
  - List the containers

## Limitations
  - Containers run in the foreground mode only.
  - No log tailing support.
  - Containers networking doesn't work by default.
  - Containers Security and Capabilities are not supported.
  - Layer Fileystem is not supported.

## Installation

### System requirements
  - libcgroup-tools

```shell
sudo curl -o /usr/bin/ship https://raw.githubusercontent.com/rbalman/ship/main/ship.sh
```

## Available Commands
```shell
Commands:
  run <root_fs_path> [<command>]    Run a new container
  exec <container_id> <command>     Execute a command inside a running container
  rm <container_id>                 Remove a container
  ps                                List all running containers
```

## Examples
- Download the file system
```shell
mkdir alpine-fs
curl -o alpine-fs/alpine-rootfs.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-minirootfs-3.19.1-x86_64.tar.gz
tar -xvf alpine-fs/alpine-rootfs.tar.gz -C alpine-fs/
```

**Running Container**
```shell
  vagrant@vagrant:~$ sudo ship run ${PWD}/alpine-fs /bin/sh
  Running Container: 1920f52b6cd8 from image /var/lib/ship/1920f52b6cd8/root...
  / # apk --version
  apk-tools 2.14.0, compiled for x86_64.
  / # ps -ef
  PID   USER     TIME  COMMAND
      1 root      0:00 /bin/sh
      4 root      0:00 ps -ef
  / # ip link
  1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN qlen 1000
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    sudo ship stop 1920f52b6cd8
```

**Exec Container**

```shell
  vagrant@vagrant:/vagrant$ sudo ship exec 1920f52b6cd8 /bin/sh
  / # apk --version
  apk-tools 2.14.0, compiled for x86_64.
  / # ps -ef
  PID   USER     TIME  COMMAND
      1 root      0:00 /bin/sh
      7 root      0:00 /bin/sh
      9 root      0:00 ps -ef
  / # 
```

**List Containers**

```shell
vagrant@vagrant:/vagrant$ ship ps
CONTAINER_ID         CONTAINER_IMAGE     
1920f52b6cd8         /var/lib/ship/1920f52b6cd8/root
```

**Stop Container**

```shell
vagrant@vagrant:/vagrant$ sudo ship rm 1920f52b6cd8
killing container process with pids: 12483

vagrant@vagrant:/vagrant$ sudo ship ps
CONTAINER_ID         CONTAINER_IMAGE  
```
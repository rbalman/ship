## 1. Chroot

### Create your own root filesystem
```shell
## intro about the root and demo
ls -la /
ls -la /proc/self/root/

## create my own root and run ls -la command
mkdir newroot
ddtree -l `which bash`

mkdir -p newroot/{usr/bin,lib64/,lib/x86_64-linux-gnu}

cp /usr/bin/bash ~/newroot/usr/bin/
cp /lib64/ld-linux-x86-64.so.2 ~/newroot/lib64
cp /lib/x86_64-linux-gnu/libc.so.6 ~/newroot/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libtinfo.so.6 ~/newroot/lib/x86_64-linux-gnu/

## run shell inside the chrooted environment
/vagrant/copy-dep.sh `which ls` ~/newroot/
sudo chroot ~/myroot ls -la /

## run demo docker hello-world program
sudo chroot ~/alpine /bin/sh
```

## 2. Namespaces

- ​Feature of the Linux kernel
- partition kernel resources
- one set of processes sees one set of resources
- another set of processes sees a different set of resources 

### Types
- PID
- Mount
- UTS(Unix Time Sharing)
- User
- Network
- Time
- IPC
- Cgroup

### Listing Namespaces

**Syntax:**

```shell
lsns
lsns -p <pid>
```

```shell
lsns
lsns -p $$
ls /proc/<pid>/ns

watch ps -fC sh
docker run --name busybox --rm -it busybox
sudo lsns -p <pid>
```

### Entering into namespace

**Syntax:**

```shell
nsenter --target <pid> [namespaces]
```

```shell
docker run --rm -it --name busybox busybox httpd -fv
docker exec -it busybox /bin/sh
ps -fC httpd
sudo nsenter --target <pid> --net
sudo nsenter --target <pid> --net --pid --mount
```

### PID NS

```shell
unshare --pid --mount-proc --fork
ps -ef
```

### Network NS

```shell
unshare --pid --fork --mount-proc --net
python3 -m http.server 8080

## another terminal
curl localhost:8080
nsenter --target <pid> --net
ip link set lo up
curl localhost:8080
```

### UTS NS

```shell
unshare --pid --fork --mount-proc --uts
export PS1="\h ~ "
hostname mycontainer
exec $SHELL
```

### User NS

```shell
#### 1. without map root
unshare --pid --fork --mount-proc --uts --user
export PS1="\u@\h ~ "
ps -fC bash

#### 2. map root with non root user
unshare --pid --fork --mount-proc --uts --user --map-root
export PS1="\u@\h ~ "
ps -fC bash

#### 3. map root with root user
sudo unshare --pid --fork --mount-proc --uts --user --map-root
export PS1="\u@\h ~ "
ps -fC bash
```

### Cgroup NS

### Mount NS

### Time NS

### IPC NS

## 3. Cgroups

### Requires:

- libcgroup-tools

### Examples
```shell
# creating cgroup with ownership to a user

cgcreate -a $USER -t $USER -g memory,cpu,pids:demo-groups
ls -la /sys/fs/cgroup/demo-groups

# limit the memory size to 10MB for that cgroup directly using filesystem
echo 0 > /sys/fs/cgroup/demo-groups/cpuset.mems
echo 10 > /sys/fs/cgroup/demo-groups/pids.max
echo 10000000 > /sys/fs/cgroup/demo-groups/memory.max

# run process in a namespace
cgexec -g *:demo-groups /bin/bash
cgexec -g *:demo-groups unshare --pid --mount-proc --fork

## test fork bomb
fork() {
    fork | fork &
}
fork
```

## 4. Security 

### Capabilities

```shell
pscap

docker run --rm -it --name busybox busybox sh
ping google.com
pscap | grep -i sh

docker run --rm -it --cap-drop=net_raw busybox sh
pscap | grep -i sh
ping google.com
```

### Seccomp
### LSM(apparmor, selinux)


## 5. Resources

- https://github.com/lizrice/containers-from-scratch
- https://github.com/p8952/bocker
- https://www.youtube.com/watch?v=7CKCWqUkMJ4&list=PLdh-RwQzDsaNWBex2I09OFLCph7l_KnQE&ab_channel=Datadog
- https://wiki.archlinux.org/title/cgroups
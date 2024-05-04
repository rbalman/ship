#!/bin/bash

CONTAINER_ID_COLUMN=20
CONTAINER_IMAGE_COLUMN=20

DEFAULT_SHELL=/bin/bash
SHIP_LOGS=/var/log/ship
SHIP_FS=/var/lib/ship

check_root(){
  if [ $( id -u ) != 0 ]
  then
    echo "ERROR: Root access is required for this action."
      exit
  fi
}

function ship_run() {
  check_root
  ROOT_FS=${1}
  shift 1
  CMD=${@:-${DEFAULT_SHELL}}
  if [ -z $ROOT_FS ]
  then
    echo "please provide the root filesystem path for the container"
    exit 1
  fi

  if [ ! -d ${ROOT_FS} ]
  then
    echo "${ROOT_FS} doesn't exist, exitting.."
    exit 1
  fi

  CONTAINER_ID="$(hexdump -n 6 -e '6/1 "%02x"' /dev/urandom)"
  mkdir -p ${SHIP_LOGS}/${CONTAINER_ID}
  mkdir -p ${SHIP_FS}/${CONTAINER_ID}

  CONTAINER_ROOT=${SHIP_FS}/${CONTAINER_ID}/root
  ln -s ${ROOT_FS} ${CONTAINER_ROOT}

  echo "ROOT:${CONTAINER_ROOT}" > ${SHIP_LOGS}/${CONTAINER_ID}/${CONTAINER_ID}.info

  echo "Running Container: ${CONTAINER_ID} from image ${CONTAINER_ROOT}..."

  cgcreate -g cpu,memory,pids:ship-${CONTAINER_ID}
  cgexec -g 'cpu,memory,pids:ship-'${CONTAINER_ID} \
    unshare --pid --mount --net --ipc --time --cgroup --uts --fork \
    chroot ${CONTAINER_ROOT}/ /bin/sh -c "mount -t proc proc /proc && $CMD" #2>&1 | tee ${SHIP_LOGS}/${CONTAINER_ID}/${CONTAINER_ID}.log || true
}

function ship_exec() {
  check_root
  CONTAINER_ID=${1}
  if [ -z $CONTAINER_ID ]
  then
    echo "please provide the container id"
    exit 1
  fi

  ppid=$(ps o pid,cmd | grep -E "^\ *[0-9]+ unshare.*${CONTAINER_ID}" | awk '{print $1}'| head -n1)
  pid=$(pgrep -P ${ppid} 2> /dev/null)

  # echo "Parent Pid: ${ppid} Child pid: ${pid}"

  if [ -z $pid ]
  then
    echo "no container with the give name found."
    exit 0
  fi

  nsenter --pid --mount --uts --net --target ${pid} chroot ${SHIP_FS}/${CONTAINER_ID}/root "${@:2}"
}

function ship_ps() {
  printf "%-${CONTAINER_ID_COLUMN}s %-${CONTAINER_IMAGE_COLUMN}s\n" "CONTAINER_ID" "CONTAINER_IMAGE"
  if [ -d ${SHIP_LOGS} ]; then
    cd ${SHIP_LOGS}
    for CONTAINER_ID in $(ls -d */ 2> /dev/null | sed 's/\///g' | xargs )
    do
      [ $CONTAINER_ID == "." ] && exit 0
      CONTAINER_IMAGE=$(awk -F: '/ROOT/ {print $2}' ./$CONTAINER_ID/$CONTAINER_ID.info)
      printf "%-${CONTAINER_ID_COLUMN}s %-${CONTAINER_IMAGE_COLUMN}s\n" "$CONTAINER_ID" "${CONTAINER_IMAGE}"
    done
  fi
}

# function ship_logs() {
#   CONTAINER_ID=${1}
#   if [ -z $CONTAINER_ID ]
#   then
#     echo "please provide the name of the container"
#     exit 1
#   fi
#   tail -f ${SHIP_LOGS}/${CONTAINER_ID}/${CONTAINER_ID}.log
# }

function ship_rm() {
  check_root
  CONTAINER_ID=${1}
  if [ -z $CONTAINER_ID ]
  then
    echo "please provide the name of the container"
    exit 1
  fi

  ppid=$(ps o pid,cmd | grep -E "^ *[0-9]+ unshare.*${CONTAINER_ID}" | awk '{print $1}')
  pids=$(pgrep -P ${ppid} 2> /dev/null)

  # echo "Parent Pid: ${ppid} Child pid: ${pid}"

  if [ ! -z $pids ]
  then
    echo "killing container process with pids: ${pids}"
    kill -9 ${pids}
  fi

  rm -r ${SHIP_FS}/${CONTAINER_ID} &> /dev/null
  rm -r ${SHIP_LOGS}/${CONTAINER_ID} &> /dev/null

  sudo cgcreate -g memory,cpu,pids:"ship_${CONTAINER_ID}" &> /dev/null || true
}

function ship_help() {
  echo "Usage: $0 <command>"
  echo
  echo "Commands:"
  echo "  run <root_fs_path> [<command>]    Run a new container"
  echo "  exec <container_id> <command>     Execute a command inside a running container"
  echo "  rm <container_id>                 Remove a container"
  echo "  ps                                List all running containers"
}

case "$1" in
  "run" | "exec" | "rm" | "ps") ship_"$1" "${@:2}" ;;
  *) ship_help ;;
esac

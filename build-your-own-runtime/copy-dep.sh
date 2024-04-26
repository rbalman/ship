#!/bin/bash

set -e

BINARY=$1
DEST_DIR=$2

if [ -z $BINARY ]
then
  echo "First argument should be valid absolute path of the binary"
  echo "exitting..."
  exit 1
fi

if [ -z $DEST_DIR ]
then
  echo "Second argument should be valid destination folder. It can be relative or absolute path."
  echo "exitting..."
  exit 1
fi

if [ ! -d $DEST_DIR ]
then
  echo "Desitnation directory doesn't exist: $DEST_DIR"
  echo "exitting..."
  exit 1
fi

echo
echo "###############################################"
echo "Received Arguments"
echo "Binary: $BINARY"
echo "Destination : $DEST_DIR"
echo "###############################################"
echo

DEPS=$(lddtree -l $BINARY | xargs)

# DEPS="/usr/sbin/nginx /lib64/ld-linux-x86-64.so.2 /lib/x86_64-linux-gnu/libcrypt.so.1 /lib/x86_64-linux-gnu/libpcre.so.3 /lib/x86_64-linux-gnu/libssl.so.3 /lib/x86_64-linux-gnu/libcrypto.so.3 /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libc.so.6"

for dep in $DEPS
do 
  echo "Dependency: $dep"

  DIR=$(dirname $dep)
  echo "DIRNAME: $DIR"
  echo "runing mkdir -p ${DEST_DIR}${DIR}"
  mkdir -p ${DEST_DIR}${DIR}

  echo "copying.. $dep to ${DEST_DIR}${DIR}"
  cp -L $dep ${DEST_DIR}${DIR}
  # docker cp -L $dep ubuntu:/${DIR}
done


#!/usr/bin/env bash

nasm -f elf64 server.asm
if [ $? -ne 0 ]; then
  echo "failed to assemble"
  exit -1
fi

ld server.o -o server
if [ $? -ne 0 ]; then
  echo "failed to link"
  exit -1
fi

exit 0

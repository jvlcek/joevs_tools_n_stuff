#!/bin/bash
DISTGITDIR="/home/jvlcek/distgit"
file="${DISTGITDIR}/${1}/${1}.spec"
echo ${file}
echo "1,.s/abi).*$/release)/wq" | vim -e ${file}
echo "g/rubyabi/dwq" | vim -e ${file}

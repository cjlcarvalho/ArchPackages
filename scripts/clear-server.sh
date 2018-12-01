#! /usr/bin/bash
while true; do size=$(df . | sed -e /Filesystem/d | awk '{ print $5 }' | sed 's/[^0-9]*//g'); if [ $size -ge 90 ]; then files=$(ls | grep 'model' | sort); for i in $files; do rm $i; break; done; else echo 'Size: '$size; fi; done

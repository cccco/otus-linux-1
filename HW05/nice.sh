#!/bin/bash

NICE_LOG=/tmp/nice.log
NOT_NICE_LOG=/tmp/not_nice.log
F1=/tmp/testfile
F2=/tmp/testfile2

(time nice -n 19 dd if=/dev/urandom of=$F1 count=1024 bs=1048576) > $NICE_LOG 2>&1 &
(time nice -n -20 dd if=/dev/urandom of=$F2 count=1024 bs=1048576)  > $NOT_NICE_LOG 2>&1 &

echo "Please wait for the script to finish..."
sleep 5

# wait until two files are created
while [ "$(/usr/bin/du -m $F1 | awk '{ print $1 }')" -lt 1025 ] || [ "$(/usr/bin/du -m $F2 | awk '{ print $1 }')" -lt 1025 ];
do
  sleep 2
done

nice_time=$(grep real $NICE_LOG | awk '{ print $2 }')
not_nice_time=$(grep real $NOT_NICE_LOG | awk '{ print $2 }')

# print results
echo "================================================="
echo "Process with the nice set to 19 has been completed in $nice_time"
echo "Process with the nice set to -20 has been completed in $not_nice_time"
echo "================================================="


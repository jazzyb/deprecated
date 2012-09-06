#!/usr/bin/env bash

TEST="TEST create-remove"
FAILURE="FAIL"
SUCCESS="Success!"
MOUNT="/tmp/mnt"

mkdir -p $MOUNT
./calypso $MOUNT

# The while-true loop allows us to break on the first error.
while [ true ]; do

	# Test that we can create a file.
	touch $MOUNT/hello
	if [ $? -ne 0 ]; then
		echo $TEST-1: $FAILURE
		break
	fi
	if [ ! -e $MOUNT/hello ]; then
		echo $TEST-2: $FAILURE
		break
	fi

	# Test that we can remove the created file without removing others.
	touch $MOUNT/hello2
	rm $MOUNT/hello
	if [ $? -ne 0 ]; then
		echo $TEST-3: $FAILURE
		break
	fi
	if [ -e $MOUNT/hello -o ! -e $MOUNT/hello2 ]; then
		echo $TEST-4: $FAILURE
		break
	fi

	echo $TEST: $SUCCESS
	break
done

# Running lsof will tell us if anything is using our mount point in case we are
# unable to unmount or remove the directory for some reason.
echo $(lsof | grep $MOUNT)
fusermount -u $MOUNT
rm -rf $MOUNT

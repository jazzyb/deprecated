#!/usr/bin/env bash

TEST="TEST read-write"
FAILURE="FAIL"
SUCCESS="Success!"
MOUNT="/tmp/mnt"

mkdir -p $MOUNT
./calypso $MOUNT

# The while-true loop allows us to break on the first error.
while [ true ]; do

	# Test that the mount point exists and we can read it.
	if [ -n "$(ls $MOUNT)" ]; then
		echo $TEST-1: $FAILURE
		break
	fi

	# Test that we can write to and read from files as well as display
	# appropriate file sizes.
	echo -n "foobar" > $MOUNT/hello
	if [ ! -e $MOUNT/hello ]; then
		echo $TEST-2: $FAILURE
		break
	fi
	if [ "$(ls -l $MOUNT/hello | awk '{ print $5 }')" != "6" ]; then
		echo $TEST-3: $FAILURE
		break
	fi
	if [ "$(cat $MOUNT/hello)" != "foobar" ]; then
		echo $TEST-4: $FAILURE
		break
	fi

	# Test that appending data modifies the file appropriately.
	echo -n " hello world" >> $MOUNT/hello
	if [ "$(ls -l $MOUNT/hello | awk '{ print $5 }')" != "18" ]; then
		echo $TEST-5: $FAILURE
		break
	fi
	if [ "$(cat $MOUNT/hello)" != "foobar hello world" ]; then
		echo $TEST-6: $FAILURE
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

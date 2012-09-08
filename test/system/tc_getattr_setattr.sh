#!/usr/bin/env bash

TEST="TEST getattr-setattr"
FAILURE="FAIL"
SUCCESS="Success!"
MOUNT="/tmp/mnt"

mkdir -p $MOUNT
./calypso $MOUNT

# The while-true loop allows us to break on the first error.
while [ true ]; do

	# Test we can set uid.
	touch $MOUNT/hello
	chown root $MOUNT/hello
	if [ "$(ls -l $MOUNT/hello | awk '{ print $3 }')" != "root" ]; then
		echo $TEST-1: $FAILURE
		break
	fi
	rm $MOUNT/hello

	# Test we can set permissions.
	touch $MOUNT/hello
	chmod 0755 $MOUNT/hello
	if [ "$(ls -l $MOUNT/hello | cut -d' ' -f1)" != "-rwxr-xr-x" ]; then
		echo $TEST-2: $FAILURE
		break
	fi
	rm $MOUNT/hello

	# Test we can set timestamps.
	touch --date='1 Jan 1975 00:00:01' $MOUNT/hello
	if [ "$(ls -l $MOUNT/hello | awk '{ print $8 }')" != "1975" ]; then
		echo $TEST-3: $FAILURE
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

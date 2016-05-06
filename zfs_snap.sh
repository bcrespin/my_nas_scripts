#! /bin/sh
 
# Path to ZFS executable:
 ZFS=`which zfs`
 
# Parse arguments:
 TARGET=$1
 S_TYPE=$2
 COUNT=$3
 
# Function to display usage:
 usage()
 {
 scriptname=`/usr/bin/basename $0`
 echo $scriptname: Take and rotate snapshots on a ZFS file system
 echo
 echo Usage:
 echo  $scriptname target snap_type count
 echo
 echo target: ZFS file system to act on
 echo  snap_type: Internal identifier for snapshots of this kind
 echo  e.g. hourly, daily, monthly, 
 echo  count: Number of snapshots of the type to keep at one time
 echo
 exit
 }
 
# Basic argument checks:
 if [ -z $COUNT ]; then
	 usage
 fi
 
if [ ! -z $4 ]; then
	 usage
 fi
 
# Create new snapshot using current time stamp:
 DATE=`date +"%Y-%m-%d_%H.%M.%S"`
#touch dir for smaba shadow copy
touch "/$TARGET" >/dev/null 2>&1
 $ZFS snapshot  -o snapshot:type=$S_TYPE $TARGET@$DATE
 
# Get list of snapshots ordered by creation time and delete the ones which
 # are no longer needed
 snap_count=0
 $ZFS list -d 1 -H -o snapshot:type,name -S creation -t snapshot $TARGET |
 while read snap_type snap_name
 do
	 if [ "$snap_type" == "$S_TYPE" ]; then
		 snap_count=`expr $snap_count + 1`
 
		if [ $snap_count -gt $COUNT ]; then
			 $ZFS destroy -r $snap_name
		fi
	 fi
 done


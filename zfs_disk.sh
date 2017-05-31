#!/bin/bash

# display based on : https://pastebin.com/DsjT51aq

# trim  based on : https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

## disks / serial / models
DISKS=`ls -1 /dev/ | egrep -E "(da[0-9]+|ada[0-9]+)"'$'`

if [ "$DISKS" == "" ]; then
  echo "ERROR: no disks found!"
  exit 1
fi
echo ""
LINE="+===============================+===========================+==========+"
echo $LINE
echo "| MODEL                         | SERIAL                    | SIZE     |"
echo $LINE

for DISK in $DISKS
do
  SERIAL=`smartctl -i /dev/$DISK | grep -i "Serial Number" | awk -F":" '{ print $2}' `
  SERIAL=$(trim $SERIAL)
  MODEL=`(smartctl -i /dev/$DISK | grep "Device Model" | awk -F":" '{ print $2}') `
  MODEL=$(trim $MODEL)
  if [ "$MODEL" == "" ]; then
    MODEL="Unknown model"
  fi
  SIZE=`smartctl -i /dev/$DISK | grep "User Capacity" | awk -F"bytes " '{ print $2}' `
  SIZE=$(echo ${SIZE//[\[\]]/})
  printf "| %-30s | %-20s | %-10s |\n" "$MODEL" "$SERIAL" "$SIZE"
done
echo $LINE

### zfs pool

POOLS=`zpool list | awk '{print $1}' | grep -v NAME |xargs`

if [ "POOLS" == "" ]; then
 echo "ERROR: no zfs pool found !"
 exit 1
fi

echo ""
echo "+==============+============================================+==================+"
echo "| POOL         | GPTID                                      | SERIAL           |"
echo "+==============+============================================+==================+"
for POOL in $POOLS
do
   DISKS=`zpool status $POOL | xargs -L1 echo | egrep -v -E "(^$POOL|state|mirror|^disk|file|raidz|spare|log|cache)"  | egrep -E "(ONLINE|FAULTED|REMOVED|OFFLINE|UNAVAIL)" | awk '{ print $1}
' | xargs `
   #echo pool  $POOL has disks : $DISKS

   for DISK in $DISKS
   do
    if [[ "$DISK" =~ "gpt" ]] ; then
      GPTID=$DISK
      REALDISK=`glabel status -s | grep $DISK | awk '{print $3}'`
    else
      REALDISK=$DISK
      GPTID="N/A"
    fi
    if [ "$REALDISK" == "" ]; then
      SERIAL="DISK NOT FOUND!"
    else
      #trim partition stuff
      [[ $REALDISK =~ ^(ada[0-9]*|da[0-9]*) ]]
      REALDISK=$BASH_REMATCH
      if [ "$REALDISK" == "" ]; then
        SERIAL="DISK NOT FOUND!"
      else
        SERIAL=`smartctl -i /dev/$REALDISK | grep -i "serial number" | awk '{print $3}'`
        if [ "$SERIAL" == "" ]; then
          SERIAL="SERIAL NOT FOUND"
        fi
      fi
    fi

    #display datas
    printf "| %-12s | %-42s | %-16s |\n" "$POOL" "$GPTID" "$SERIAL"
   done
done
echo "+==============+============================================+==================+"

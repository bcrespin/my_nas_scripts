#!/bin/sh

# change me if needed
jailpath="/usr/jails"



usage="$0 -u|-l -j JAILNAME"


chgflags_recurse()
{
	dir=$jailpath/$jailname/$1	
	if [ -d $dir ]; then
		echo  chflags ${NO}schg on $jailpath/$jailname/$1 ...
		/bin/chflags -R ${NO}schg $jailpath/$jailname/$1
	fi
}

unlock=0;
lock=0;

while getopts "ulj:" opt; do
	case "$opt" in
		 u)	unlock=1;;
		 l)	lock=1;;
		j)	jailname=$OPTARG;;
	esac
done

if [ "$unlock" == "$lock" ]; then
	echo ERROR : check arguments !	
	echo USAGE :  $usage
	exit 1
fi

if [ "$jailname" == "" ]; then
	echo ERROR : check arguments !
        echo USAGE :  $usage
        exit 1
fi

if [ ! -d $jailpath/$jailname ]; then
	echo ERROR : no jail $jailname in $jailpath
	exit 1
fi 

NO=""
if [ "$unlock" == "1" ]; then
	NO="no"
fi

chgflags_recurse root
chgflags_recurse usr
chgflags_recurse etc

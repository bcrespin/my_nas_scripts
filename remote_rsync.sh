#!/bin/sh

REMOTENAME="nas"
REMOTEUSER="root"
DRYRUN=0
#--exclude=""*Thumbs.db""
RSYNC_ARG="-O -tvur --delete --exclude='*@eaDir*' --exclude=A_IMPORTER/ --exclude=import_en_cours/"
LOGFILE=/root/log-rsync.log
MAILME=0

if [ "$DRYRUN" == "0" ]; then
	RSYNCARG="$RSYNC_ARG"
else
	RSYNCARG="-n $RSYNC_ARG"
fi


myinit()
{
	echo "#****************************************************************************" > $LOGFILE
	echo "# Replication `date`" >> $LOGFILE
	echo "# Remote = $REMOTENAME" >> $LOGFILE
	echo "# rsyncarg = $RSYNCARG" >> $LOGFILE
	echo "#****************************************************************************" >> $LOGFILE

}
myend()
{
	echo "#****************************************************************************" >> $LOGFILE
	if [ "$MAILME" == "1" ]; then
       		 mail -s "Report Rsync to $REMOTENAME" root < $LOGFILE
	fi
}

myrsync() {
	echo " " >> $LOGFILE
	echo "#----------------------------------------------------------------------------" >> $LOGFILE
	echo "# Folder : $1 -> $2"  >> $LOGFILE
	echo "# Starting : `date`..." >> $LOGFILE
	rsync $RSYNCARG $1 $REMOTEUSER@$REMOTENAME:$2 >> $LOGFILE 2>&1
	echo "# Ending : `date`..." >> $LOGFILE
	echo "#----------------------------------------------------------------------------" >> $LOGFILE
	echo " " >> $LOGFILE
}

myinit

src="/zSTORAGE1/photos/"
dst="/volume1/Photos/" 
myrsync  $src $dst

src="/zSTORAGE1/musique/"
dst="/volume1/Musique/"
myrsync  $src $dst

src="/zSTORAGE1/documents/Caroline/"
dst="/volume1/Documents/Caroline/"
myrsync  $src $dst

src="/zSTORAGE1/documents/Brice/"
dst="/volume1/Documents/Brice/"
myrsync  $src $dst



myend

#!/usr/syno/synoha/bin/bash

set -u

###############################################################################
# Skriptname:       backup.sh
#
# Beschreibung:     Gehe durch alle Dateien und Verzeichnisse durch und sichere diese
#                   auf Festplatte, sobald diese angeschlossen wird.
#
###############################################################################

# Get date of today
date=$(/bin/date +'%Y%m%d')

# Mountpoint for usb-backup-drive
mpt="/volumeUSB3/usbshare/"

# File to test, if the correct usb-drive was mounted
test_file="001.mnt"

# Logfile for the Logging Events at Backup
LOGFILE="/volume1/PrivaterShare/logs/backup.log"

# Logfile especially for rsync-tasks
LOGFILE_RSYNC="/volume1/PrivaterShare/logs/rsync_${datum}.log"

# Path to rsync-binary
RSYNC="/usr/syno/bin/rsync"

# Control, if test_file is available
if [ ! -f ${mpt}/${test_file} ] ; then
    echo "$(/bin/date +'%Y-%m-%d_%H:%M:%S') - The Backup-Drive was not mounted at the expected Mountpoint: ${mpt} " | tee -a $LOGFILE
    exit 1
fi

# Control if already backed up today. If so, exit
CHECK_RSYNC=$(ps | grep -v grep | grep $RSYNC | wc -l)
[ ${CHECK_RSYNC} -ne 0 ] && { echo "rsync am Laufen" ; exit 1 ; }


# List with important dirs
important_dirs="backup_list.txt"

# Backup all important dirs to backup-mpt
# for backup use rsync
# Warning! All deleted files at nas will also be deleted at usb drive
for line in $(grep -v "#" $important_dirs); do
    mkdir -p ${mpt}/backups/${line}
    if [ -e ${mpt}/backups/${line}/${date}.bak ]; then
        echo "Already backed up the following directory or file today : ${line}"
        continue
    else
        $RSYNC -av --delete --log-file="${LOGFILE_RSYNC}" -r ${line} ${mpt} 
        touch ${mpt}/backups/${line}/${date}.bak
        echo "$(/bin/date +'%Y-%m-%d_%H:%M:%S') - rsync for the following file or directy was successful: $line" | tee -a $LOGFILE
        echo "For Details see: ${LOGFILE_RSYNC}" | tee -a $LOGFILE
    fi
done

exit 0

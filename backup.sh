#!/usr/syno/synoha/bin/bash

set -u

###############################################################################
# Skriptname:       backup.sh
#
# Beschreibung:     Gehe durch alle Dateien und Verzeichnisse durch und sichere diese
#                   auf Festplatte, sobald diese angeschlossen wird.
#
###############################################################################

# Get Datum von heute
datum=$(/bin/date +'%Y%m%d')

# Mountpoint for usb-backup-drive
mpt="/volumeUSB3/usbshare/"

# File to test, if the correct usb-drive was mounted
test_file="001.mnt"

# Logfile for the complete Backup
LOGFILE="/volume1/PrivaterShare/logs/backup.log"

# Logfile especially for rsync-tasks
LOGFILE_RSYNC="/volume1/PrivaterShare/logs/rsync_${datum}.log"

# Path to rsync-binary
RSYNC="/usr/syno/bin/rsync"

# Control, if test_file is available
if [ ! -f ${mpt}/${test_file} ] ; then
    echo "$(/bin/date +'%Y-%m-%d_%H:%M:%S') - Backup-Drive   ${mpt} is not mounted" | tee -a $LOGFILE
    exit 1
fi

# Control if already backed-up today. If so, exit
CHECK_RSYNC=$(ps | grep -v grep | grep $RSYNC | wc -l)
[ ${CHECK_RSYNC} -ne 0 ] && { echo "rsync am Laufen" ; exit 1 ; }


# List with important dirs
important_dirs="backup_list.txt"

# Backup all important dirs to backup-mpt
# for backup use rsync
# Warning! All deleted files at nas will also be deleted at usb drive
for zeile in $(grep -v "#" $important_dirs); do
    mkdir -p ${mpt}/backups/${zeile}
    if [ -e ${mpt}/backups/${zeile}/${datum}.bak ]; then
        echo "Backup fuer ${zeile} heute bereits gelaufen"
        continue
    else
        $RSYNC -av --delete --log-file="${LOGFILE_RSYNC}" -r ${zeile} ${mpt} 
        touch ${mpt}/backups/${zeile}/${datum}.bak
        echo "$(/bin/date +'%Y-%m-%d_%H:%M:%S') - rsync für folg. Verzeichnis erfolgreich gelaufen: $zeile" | tee -a $LOGFILE
        echo "Details siehe ${LOGFILE_RSYNC}" | tee -a $LOGFILE
    fi
done

exit 0

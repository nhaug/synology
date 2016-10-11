#!/usr/syno/synoha/bin/bash

set -u

###############################################################################
# Skriptname:       backup.sh
#
# Beschreibung:     Gehe durch alle Dateien und Verzeichnisse durch und sichere diese
#                   auf Festplatte, sobald diese angeschlossen wird.
#
###############################################################################

datum=$(/bin/date +'%Y%m%d')

mpt="/volumeUSB3/usbshare/"
test_id="001.mnt"
LOGFILE="/volume1/PrivaterShare/logs/backup.log"
LOGFILE_RSYNC="/volume1/PrivaterShare/logs/rsync_${datum}.log"
RSYNC="/usr/syno/bin/rsync"

# Kontrolle, ob Backup-Medium vorhanden
if [ ! -f ${mpt}/${test_id} ] ; then
    echo "$(/bin/date +'%Y-%m-%d_%H:%M:%S') - Backup-Medium  ${mpt} nicht angeschlossen" | tee -a $LOGFILE
    exit 1
fi

# Kontrolliere ob schon weitere backups laufen. Dann breche ab
CHECK_RSYNC=$(ps | grep -v grep | grep $RSYNC | wc -l)
[ ${CHECK_RSYNC} -ne 0 ] && { echo "rsync am Laufen" ; exit 1 ; }


# Backup von allen wichtigen Dateien
important_dirs="backup_list.txt"
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

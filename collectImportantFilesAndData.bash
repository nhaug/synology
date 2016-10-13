#!/usr/syno/synoha/bin/bash

# Erstmal den Output von httpd in temp. Datei

file_httpd_ps_out="/tmp/httpd_prozesse_$(date +'%Y%m%d')"
ps | grep httpd > $file_httpd_ps_out

# TAR-Archiv from all important files:
files_2_tar="${file_httpd_ps_out} /etc/group /etc/passwd /etc/httpd/conf/httpd* /usr/syno/etc/rc.sysv/httpd-user-conf-writer.sh /usr/syno/sbin/synoservicecfg /usr/bin/httpd"

tar -czvf /tmp/files_4_nils_$(date +"%Y%M%d").tar.gz $files_2_tar 

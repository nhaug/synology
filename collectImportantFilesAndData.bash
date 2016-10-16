#!/usr/syno/synoha/bin/bash

# Collect Output of temporary HTTP Output
file_httpd_ps_out="/tmp/httpd_prozesse_$(date +'%Y%m%d')"
ps | grep httpd > $file_httpd_ps_out

# All files and dirs that we would like to backup:
files_2_tar="${file_httpd_ps_out} /etc/group /etc/passwd /etc/httpd/conf/httpd* /usr/syno/etc/rc.sysv/httpd-user-conf-writer.sh /usr/syno/sbin/synoservicecfg /usr/bin/httpd"

# Create tar from all important files:
tar -czvf /tmp/files_4_nils_$(date +"%Y%M%d").tar.gz $files_2_tar 

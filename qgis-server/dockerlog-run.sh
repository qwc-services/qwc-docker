#!/bin/sh

LOGFILE=/var/log/qgis/qgis_mapserv.log
touch $LOGFILE
chown www-data:www-data $LOGFILE
exec tail -f $LOGFILE

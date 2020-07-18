#!/bin/sh

# Disable JETTY_CONSOLE output -- it causes problems when run by cron:
export JETTY_CONSOLE=/dev/null

# Pass parameters along to solr.sh:
CURRENTPATH="/var/www/crra.andornot.com"
cd $CURRENTPATH
sudo su -s /bin/sh vufind -c "export JETTY_CONSOLE=/dev/null;$CURRENTPATH/./solr.sh $*"


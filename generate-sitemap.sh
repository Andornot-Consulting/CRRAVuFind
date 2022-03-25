#!/bin/sh

# set local dir
export VUFIND_LOCAL_DIR=/var/www/crra.andornot.com/local
export VUFIND_LOCAL_MODULES=CRRA_Module

php /var/www/crra.andornot.com/util/sitemap.php

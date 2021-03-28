#!/bin/sh

# set local dir
export VUFIND_LOCAL_DIR=/var/www/crra.andornot.com/local

# harvest all the OAI specified in /local/harvest/oai.ini
# php /var/www/crra.andornot.com/harvest/harvest_oai.php

# harvest OAI from individual institutions:
php /var/www/crra.andornot.com/harvest/harvest_oai.php day
php /var/www/crra.andornot.com/harvest/harvest_oai.php edc
php /var/www/crra.andornot.com/harvest/harvest_oai.php mar
php /var/www/crra.andornot.com/harvest/harvest_oai.php olv
php /var/www/crra.andornot.com/harvest/harvest_oai.php slu
php /var/www/crra.andornot.com/harvest/harvest_oai.php stm
php /var/www/crra.andornot.com/harvest/harvest_oai.php usd
php /var/www/crra.andornot.com/harvest/harvest_oai.php vil
php /var/www/crra.andornot.com/harvest/harvest_oai.php xul
php /var/www/crra.andornot.com/harvest/harvest_oai.php duq

# these exist, but the URL does not, so do not attempt to harvest
#php /var/www/crra.andornot.com/harvest/harvest_oai.php bar
#php /var/www/crra.andornot.com/harvest/harvest_oai.php cnr
#php /var/www/crra.andornot.com/harvest/harvest_oai.php luc
#php /var/www/crra.andornot.com/harvest/harvest_oai.php sjn
#php /var/www/crra.andornot.com/harvest/harvest_oai.php wla

# deletions
/var/www/crra.andornot.com/harvest/batch-delete.sh day
/var/www/crra.andornot.com/harvest/batch-delete.sh edc
/var/www/crra.andornot.com/harvest/batch-delete.sh mar
/var/www/crra.andornot.com/harvest/batch-delete.sh olv
/var/www/crra.andornot.com/harvest/batch-delete.sh slu
/var/www/crra.andornot.com/harvest/batch-delete.sh stm
/var/www/crra.andornot.com/harvest/batch-delete.sh usd
/var/www/crra.andornot.com/harvest/batch-delete.sh vil
/var/www/crra.andornot.com/harvest/batch-delete.sh xul
/var/www/crra.andornot.com/harvest/batch-delete.sh duq

# then for each source, import the data, using the XSL specified in the .properties file and stored in /import/xsl
/var/www/crra.andornot.com/harvest/batch-import-xsl.sh day day.properties
/var/www/crra.andornot.com/harvest/batch-import-xsl.sh edc edc.properties
/var/www/crra.andornot.com/harvest/batch-import-xsl.sh mar mar.properties
/var/www/crra.andornot.com/harvest/batch-import-xsl.sh olv olv.properties
/var/www/crra.andornot.com/harvest/batch-import-xsl.sh slu slu.properties
/var/www/crra.andornot.com/harvest/batch-import-xsl.sh stm stm.properties
/var/www/crra.andornot.com/harvest/batch-import-xsl.sh usd usd.properties
/var/www/crra.andornot.com/harvest/batch-import-xsl.sh vil vil.properties
/var/www/crra.andornot.com/harvest/batch-import-xsl.sh xul xul.properties
/var/www/crra.andornot.com/harvest/batch-import-xsl.sh duq duq.properties

# commented out as URL not available so nothing to harvest nor import
#/var/www/crra.andornot.com/harvest/batch-import-xsl.sh bar bar.properties
#/var/www/crra.andornot.com/harvest/batch-import-xsl.sh cnr cnr.properties
#/var/www/crra.andornot.com/harvest/batch-import-xsl.sh luc luc.properties
#/var/www/crra.andornot.com/harvest/batch-import-xsl.sh sjn sjn.properties
#/var/www/crra.andornot.com/harvest/batch-import-xsl.sh wla wla.properties


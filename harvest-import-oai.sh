#!/bin/bash

# start a new log file, then append to it with all other output
echo "$(date +"%Y-%m-%d %H:%M:%S"): Starting OAI Harvest, Delete and Index" > /var/www/crra.andornot.com/logs/harvest-import-oai.log

# set local dir
echo "$(date +"%Y-%m-%d %H:%M:%S"): export VUFIND_LOCAL_DIR and VUFIND_LOCAL_MODULES" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
export VUFIND_LOCAL_DIR=/var/www/crra.andornot.com/local
export VUFIND_LOCAL_MODULES=CRRA_Module

# define an array of the 3 character codes representing institutions to harvest (must be defined in oai.ini)
institutions=("day" "duq" "edc" "mar" "olv" "slu" "stm" "usd" "usf" "vil" "xul")

# harvest OAI from individual institutions:
echo "---------------------------------" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
echo "$(date +"%Y-%m-%d %H:%M:%S"): Starting Harvest" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
for institution in "${institutions[@]}"; do
  echo "---------------------------------" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Harvesting $institution" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
  php /var/www/crra.andornot.com/harvest/harvest_oai.php $institution >> /var/www/crra.andornot.com/logs/harvest-import-oai.log 2>&1
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Finished harvesting $institution" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
done

# deletions
echo "---------------------------------" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
echo "$(date +"%Y-%m-%d %H:%M:%S"): Starting Deletions" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
for institution in "${institutions[@]}"; do
  echo "---------------------------------" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Deleting records for $institution" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
  /var/www/crra.andornot.com/harvest/batch-delete.sh $institution >> /var/www/crra.andornot.com/logs/harvest-import-oai.log 2>&1
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Finished deleting records for $institution" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
done

# import harvested records into VuFind
echo "---------------------------------" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
echo "$(date +"%Y-%m-%d %H:%M:%S"): Starting Import" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
for institution in "${institutions[@]}"; do
  echo "---------------------------------" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Importing harvested records for $institution" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
  /var/www/crra.andornot.com/harvest/batch-import-xsl.sh $institution $institution.properties >> /var/www/crra.andornot.com/logs/harvest-import-oai.log 2>&1
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Finished importing harvested records for $institution" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
done

# finish log file
echo "---------------------------------" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log
echo "$(date +"%Y-%m-%d %H:%M:%S"): Finished OAI Harvest, Delete and Index" >> /var/www/crra.andornot.com/logs/harvest-import-oai.log

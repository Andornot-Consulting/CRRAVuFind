#!/bin/bash

# set local dir
export VUFIND_LOCAL_DIR=/var/www/crra.andornot.com/local
export VUFIND_LOCAL_MODULES=CRRA_Module

# start a new log file, then append to it with all other output
echo "$(date +"%Y-%m-%d %H:%M:%S"): Starting OAI Harvest, Delete and Index" > ./logs/harvest-import-oai.log

# define an array of the 3 character codes representing institutions to harvest (must be defined in oai.ini)
institutions=("day" "duq" "edc" "mar" "olv" "slu" "stm" "usd" "usf" "vil" "xul")

# harvest OAI from individual institutions:
echo "---------------------------------" >> ./logs/harvest-import-oai.log
echo "$(date +"%Y-%m-%d %H:%M:%S"): Starting Harvest" >> ./logs/harvest-import-oai.log
for institution in "${institutions[@]}"; do
  echo "---------------------------------" >> ./logs/harvest-import-oai.log
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Harvesting $institution" >> ./logs/harvest-import-oai.log
  php /var/www/crra.andornot.com/harvest/harvest_oai.php $institution >> ./logs/harvest-import-oai.log 2>&1
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Finished harvesting $institution" >> ./logs/harvest-import-oai.log
done

# deletions
echo "---------------------------------" >> ./logs/harvest-import-oai.log
echo "$(date +"%Y-%m-%d %H:%M:%S"): Starting Deletions" >> ./logs/harvest-import-oai.log
for institution in "${institutions[@]}"; do
  echo "---------------------------------" >> ./logs/harvest-import-oai.log
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Deleting records for $institution" >> ./logs/harvest-import-oai.log
  /var/www/crra.andornot.com/harvest/batch-delete.sh $institution >> ./logs/harvest-import-oai.log 2>&1
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Finished deleting records for $institution" >> ./logs/harvest-import-oai.log
done

# import harvested records into VuFind
echo "---------------------------------" >> ./logs/harvest-import-oai.log
echo "$(date +"%Y-%m-%d %H:%M:%S"): Starting Import" >> ./logs/harvest-import-oai.log
for institution in "${institutions[@]}"; do
  echo "---------------------------------" >> ./logs/harvest-import-oai.log
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Importing harvested records for $institution" >> ./logs/harvest-import-oai.log
  /var/www/crra.andornot.com/harvest/batch-import-xsl.sh $institution $institution.properties >> ./logs/harvest-import-oai.log 2>&1
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Finished importing harvested records for $institution" >> ./logs/harvest-import-oai.log
done

# finish log file
echo "---------------------------------" >> ./logs/harvest-import-oai.log
echo "$(date +"%Y-%m-%d %H:%M:%S"): Finished OAI Harvest, Delete and Index" >> ./logs/harvest-import-oai.log
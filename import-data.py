#! /usr/bin/env python

# script to check for new MARC, MARCXML, EAD and PastPerfect data files and import them into VuFind, catch errors, log each step, and email the log if any files were processed
# also harvest OAI
# set SENDGRID_API_KEY as an environment variable with relevant API key first

import re
import os
from os.path import join
import logging
import shutil
import subprocess
import base64
from sendgrid.helpers.mail import (
    Mail, Attachment, FileContent, FileName,
    FileType, Disposition, ContentId)
from sendgrid import SendGridAPIClient


# set logging
logging.basicConfig(filename='/var/www/crra.andornot.com/logs/import-data.log', format='%(asctime)s: %(levelname)s: %(message)s', filemode='w', level=logging.DEBUG)

datapath="/srv/ftp/crra-ftp/"

# see if there are any MARC records to import, then import them
def importMARC():

    logging.info("Looking for MARC files")

    errorcount = 0
    filenames = []
    for root, dirs, files in os.walk(datapath, topdown=True):
        dirs[:] = [d for d in dirs if d not in "processed"] # exclude the processed folder
        for name in files:
            # append fils found in marc folder to list
            if (root.find('marc') != -1):
                filenames.append(os.path.join(root, name))

    logging.info(str(len(filenames)) + " MARC files found")
    
    # import each file
    if len(filenames) > 0:
        for file in filenames:
            institution = str(file)[len(datapath):len(datapath)+3] # get 3 char code, starting after datapath root folder in filename
            cmd = "/var/www/crra.andornot.com/import-marc.sh"
            propertiesfile = "-p /var/www/crra.andornot.com/local/import/import_" + institution + ".properties"
            logging.info("Importing " + file)
            try:
                # import file
                importerror = 0
                output = subprocess.check_output([cmd, propertiesfile, file])
                # look for ERROR in SolrMARC output
                for match in re.finditer('ERROR', str(output)):
                    errortext = str(output)[match.start():match.start()+300]
                    logging.error("Error importing " + file)
                    logging.error(errortext)
                    importerror = importerror + 1
                if importerror > 0:
                    errorcount = errorcount + 1
            except subprocess.CalledProcessError as e:
                logging.error("Error importing " + file)
                logging.error("Error is: " + str(e.output))
                errorcount = errorcount + 1
                
            # move file to processed subfolder
# commented out as leaving all uploaded data in original folder for full re-indexing            
#            sourcepath, sourcefile = os.path.split(file)
#            destpath = os.path.join(sourcepath, "processed")
#            destfile = os.path.join(sourcepath, "processed", sourcefile)
#            shutil.rmtree(destpath)
#            logging.info("Older files removed from " + destpath)
#            shutil.move(file,destfile)        
#            logging.info(file + " moved to " + destfile)                

        logging.info(str(errorcount) + " MARC files with errors")
        
    return [len(filenames), errorcount];
    
# see if there are any MARCXML records to import, then import them
def importMARCXML():

    logging.info("Looking for MARCXML files")

    errorcount = 0
    filenames = []
    for root, dirs, files in os.walk(datapath, topdown=True):
        dirs[:] = [d for d in dirs if d not in "processed"] # exclude the processed folder
        for name in files:
            # append fils found in marc folder to list
            if (root.find('marcxml') != -1):
                filenames.append(os.path.join(root, name))

    logging.info(str(len(filenames)) + " MARCXML files found")
    
    # import each file
    if len(filenames) > 0:
        for file in filenames:
            institution = str(file)[len(datapath):len(datapath)+3] # get 3 char code, starting after datapath root folder in filename
            cmd = "/var/www/crra.andornot.com/import-marc.sh"
            propertiesfile = "-p /var/www/crra.andornot.com/local/import/import_" + institution + ".properties"
            logging.info("Importing " + file)
            try:
                # import file
                importerror = 0
                output = subprocess.check_output([cmd, propertiesfile, file])
                # look for ERROR in SolrMARC output
                for match in re.finditer('ERROR', str(output)):
                    errortext = str(output)[match.start():match.start()+300]
                    logging.error("Error importing " + file)
                    logging.error(errortext)
                    importerror = importerror + 1
                if importerror > 0:
                    errorcount = errorcount + 1
            except subprocess.CalledProcessError as e:
                logging.error("Error importing " + file)
                logging.error("Error is: " + str(e.output))
                errorcount = errorcount + 1
                
            # move file to processed subfolder
# commented out as leaving all uploaded data in original folder for full re-indexing            
#            sourcepath, sourcefile = os.path.split(file)
#            destpath = os.path.join(sourcepath, "processed")
#            destfile = os.path.join(sourcepath, "processed", sourcefile)
#            shutil.rmtree(destpath)
#            logging.info("Older files removed from " + destpath)
#            shutil.move(file,destfile)        
#            logging.info(file + " moved to " + destfile)                

        logging.info(str(errorcount) + " MARCXML files with errors")
        
    return [len(filenames), errorcount];    
    
# see if there are any EAD records to import, then import them
def importEAD():

    logging.info("Looking for EAD files")

    errorcount = 0
    filenames = []
    for root, dirs, files in os.walk(datapath, topdown=True):
        dirs[:] = [d for d in dirs if d not in "processed"] # exclude the processed files
        for name in files:
            # append files found in ead folder to list
            if (root.find('ead') != -1):
                if name.endswith(".xml"):
                    filenames.append(os.path.join(root, name))

    logging.info(str(len(filenames)) + " EAD files found")
    
    # import each file
    if len(filenames) > 0:
        for file in filenames:
            institution = str(file)[len(datapath):len(datapath)+3] # get 3 char code, starting after datapath root folder in filename
            cmd = "/var/www/crra.andornot.com/import/import-xsl.php"
            propertiesfile = "ead_" + institution + ".properties"
            logging.info("Importing " + file)
            try:
                # import file
                importerror = 0
                output = subprocess.check_output(["php", cmd, file, propertiesfile])
                for match in re.finditer('Fatal error', str(output)):
                    errortext = str(output)[match.start():match.start()+300]
                    logging.error("Error importing " + file)
                    logging.error(errortext)
                    importerror = importerror + 1
                if importerror > 0:
                    errorcount = errorcount + 1
            except subprocess.CalledProcessError as e:
                logging.error("Error importing " + file)
                logging.error("Error is: " + str(e.output))
                errorcount = errorcount + 1

            # move file to processed subfolder
# commented out as leaving all uploaded data in original folder for full re-indexing            
#            sourcepath, sourcefile = os.path.split(file)
#            destpath = os.path.join(sourcepath, "processed")
#            destfile = os.path.join(sourcepath, "processed", sourcefile)
#            shutil.rmtree(destpath)
#            logging.info("Older files removed from " + destpath)
#            shutil.move(file,destfile)        
#            logging.info(file + " moved to " + destfile)                

        logging.info(str(errorcount) + " EAD files with errors")
            
    return [len(filenames), errorcount];
    
# see if there are any PastPerfect records to import, then import them
def importPP():

    logging.info("Looking for PastPerfect files")

    errorcount = 0
    filenames = []
    for root, dirs, files in os.walk(datapath, topdown=True):
        dirs[:] = [d for d in dirs if d not in "processed"] # exclude the processed folder
        for name in files:
            # append files found in pp folder to list
            if (root.find('pp') != -1):
                filenames.append(os.path.join(root, name))

    logging.info(str(len(filenames)) + " new PastPerfect files found")
    
    # import each file
    if len(filenames) > 0:
        for file in filenames:
            institution = str(file)[len(datapath):len(datapath)+3] # get 3 char code, starting after datapath root folder in filename
            cmd = "/var/www/crra.andornot.com/import/import-xsl.php"
            propertiesfile = "pp_" + institution + ".properties"
            logging.info("Importing " + file + " with command " + cmd)
            try:
                # import file
                importerror = 0
                output = subprocess.check_output(["php", cmd, file, propertiesfile])
                for match in re.finditer('Fatal error', str(output)):
                    errortext = str(output)[match.start():match.start()+300]
                    logging.error("Error importing " + file)
                    logging.error(errortext)
                    importerror = importerror + 1
                if importerror > 0:
                    errorcount = errorcount + 1
            except subprocess.CalledProcessError as e:
                logging.error("Error importing " + file)
                logging.error("Error is: " + str(e.output))
                errorcount = errorcount + 1

            # move file to processed subfolder
# commented out as leaving all uploaded data in original folder for full re-indexing            
#            sourcepath, sourcefile = os.path.split(file)
#            destpath = os.path.join(sourcepath, "processed")
#            destfile = os.path.join(sourcepath, "processed", sourcefile)
#            shutil.rmtree(destpath)
#            logging.info("Older files removed from " + destpath)
#            shutil.move(file,destfile)        
#            logging.info(file + " moved to " + destfile)                

        logging.info(str(errorcount) + " PastPerfect files with errors")
            
    return [len(filenames), errorcount];


# harvest OAI
def harvestOAI():
    logging.info("Harvesting OAI")
    errorcount = 0
    
    # delete files
    for root, dirs, files in os.walk("/var/www/crra.andornot.com/local/harvest", topdown = False):
        for file in files:
            if file != "oai.ini":
                os.remove(os.path.join(root, file))        

    cmd = "/var/www/crra.andornot.com/harvest-import-oai.sh"
    try:
        output = subprocess.check_output([cmd])
    except subprocess.CalledProcessError as e:
        logging.error("Error Harvesting OAI")
        logging.error("Error is: " + str(e.output))
        errorcount = errorcount + 1
        
    return [errorcount];

# Stop VuFind, delete Biblio core, restart
def restartVuFind():
    errorcount = 0

    # stop VuFind
    cmd = "/var/www/crra.andornot.com/solr.sh"
    parameter = "stop"
    logging.info("Stopping VuFind")
    try:
        subprocess.check_output([cmd, parameter], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        logging.error("Error stopping VuFind: " + str(e.output))
        errorcount = errorcount + 1
        
    # delete biblio core data
    try:
        shutil.rmtree("/var/www/crra.andornot.com/solr/vufind/biblio/index")
    except subprocess.CalledProcessError as e:
        logging.error("Error deleting biblio core index")
        logging.error("Error is: " + str(e.output))        
        
    # start VuFind
    cmd = "/var/www/crra.andornot.com/solr.sh"
    parameter = "start"
    logging.info("Starting VuFind")
    try:
        subprocess.check_output([cmd, parameter], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        logging.error("Error starting VuFind: " + str(e.output))
        errorcount = errorcount + 1

    return [errorcount];

# Restart VuFind, rebuild alphabetic browser
def restartVuFindAlpha():
    errorcount = 0

    # stop VuFind
    cmd = "/var/www/crra.andornot.com/solr.sh"
    parameter = "restart"
    logging.info("Restarting VuFind")
    try:
        subprocess.check_output([cmd, parameter], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        logging.error("Error restarting VuFind: " + str(e.output))
        errorcount = errorcount + 1
        
    cmd = "/var/www/crra.andornot.com/index-alphabetic-browse.sh"
    logging.info("Rebuilding alphabetic browse indexes")
    try:
        subprocess.check_output(cmd, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        logging.error("Error rebuilding alphabetic browse indexes: " + str(e.output))
        errorcount = errorcount + 1
    
    return [errorcount];


def sendMail(totalfilecount, totalerrorcount):

    # log mail send to separate lof file
    
    logging.basicConfig(filename='/var/www/crra.andornot.com/logs/sendmail.log', format='%(asctime)s: %(levelname)s: %(message)s', filemode='w', level=logging.DEBUG)

    #to_emails = [('jjacobsen@andornot.com', 'Jonathan Jacobsen')]
    to_emails = [('jjacobsen@andornot.com', 'Jonathan Jacobsen'), ('stevelapommeray@gmail.com', 'Steve Lapommeray')]

    message = Mail(
        from_email='do-not-reply@andornotmail.com',
        to_emails=to_emails,
        subject='CRRA VuFind Data Import Log',
        html_content='<p>Attached is the most recent data import log for CRRA VuFind.</p><p>Total files processed: ' + str(totalfilecount) + "</p><p>Errors: " + str(totalerrorcount) + " or more (see attached log.)</p>")
    file_path = '/var/www/crra.andornot.com/logs/import-data.log'
    with open(file_path, 'rb') as f:
        data = f.read()
        f.close()
    encoded = base64.b64encode(data).decode()
    attachment = Attachment()
    attachment.file_content = FileContent(encoded)
    attachment.file_type = FileType('application/text')
    attachment.file_name = FileName('import-data.log.txt')
    attachment.disposition = Disposition('attachment')
    attachment.content_id = ContentId('Log ID')
    message.attachment = attachment        
    try:
        sg = SendGridAPIClient(os.getenv('SENDGRID_API_KEY'))
        response = sg.send(message)
        logging.info("Email sent")
        logging.info(response.status_code)
        logging.info(response.body)
        logging.info(response.headers)
    except Exception as e:
        logging.error(e)


# MAIN

# count files found and errors reported
totalfilecount = 0
totalerrorcount = 0

# log start
logging.info("Starting CRRA VuFind import process")

# stop Vufind, delete Biblio core, restart
restartresult = restartVuFind()
totalerrorcount = totalerrorcount + restartresult[0]

# look for MARC files
marcresult = importMARC()
totalfilecount = totalfilecount + marcresult[0]
totalerrorcount = totalerrorcount + marcresult[1]

# look for MARCXML files
marcXMLresult = importMARCXML()
totalfilecount = totalfilecount + marcXMLresult[0]
totalerrorcount = totalerrorcount + marcXMLresult[1]

# look for EAD files
eadresult = importEAD()
totalfilecount = totalfilecount + eadresult[0]
totalerrorcount = totalerrorcount + eadresult[1]

# look for PastPerfect files
ppresult = importPP()
totalfilecount = totalfilecount + ppresult[0]
totalerrorcount = totalerrorcount + ppresult[1]

# log file count
logging.info(str(totalfilecount) + " total MARC, MARCXML, EAD and PP files found")

# restart Vufind, recreate alphabetic browse index
restartresult2 = restartVuFindAlpha()
totalerrorcount = totalerrorcount + restartresult2[0]

# harvest OAI
oairesult = harvestOAI()
totalerrorcount = totalerrorcount + oairesult[0]

# log error count
logging.info(str(totalerrorcount) + " total errors")

# send mail
sendMail(totalfilecount, totalerrorcount)

# log finish    
logging.info("Finished CRRA VuFind import process")    



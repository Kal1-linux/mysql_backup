#!/bin/bash

# MySQL credentials
DB_USER="root"
DB_PASSWORD=""
DB_HOST="localhost"
DB_NAME=""

# Backup directory
BACKUP_DIR="/root/wb_mysql"

# S3 bucket and folder
S3_BUCKET=""
S3_FOLDER="mysql-backups"

# Timestamp for the backup file
TIMESTAMP=$(TZ=Asia/Kolkata date +"%Y%m%d_%H%M")

# Backup filename
BACKUP_FILE="backup_$TIMESTAMP.sql"

# Check if the backup directory exists, create it if not
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Perform MySQL dump to create the backup
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/$BACKUP_FILE

# Upload the backup to S3
aws s3 cp $BACKUP_DIR/$BACKUP_FILE s3://$S3_BUCKET/$S3_FOLDER/

# Delete local backups older than 7 days
find $BACKUP_DIR -name 'backup_*' -type f -mtime +7 -exec rm {} \;

# Delete S3 backups older than 7 days
aws s3 ls s3://$S3_BUCKET/$S3_FOLDER/ | while read -r line;
  do
    createDate=$(echo $line|awk {'print $1"T"$2"Z"'})
    createDate=$(date -d"$createDate" +%s)
    olderThan=$(date -d"7 days ago" +%s)
    if [[ $createDate -lt $olderThan ]]
    then
      fileName=$(echo $line|awk {'print $4'})
      if [[ $fileName != "" ]]
      then
        aws s3 rm s3://$S3_BUCKET/$S3_FOLDER/$fileName
      fi
    fi
  done

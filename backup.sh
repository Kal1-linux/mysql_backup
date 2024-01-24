#!/bin/bash

# MySQL credentials
DB_USER="ubuntu"
DB_PASSWORD="TST_ubuntu693#"
DB_HOST="localhost"
DB_NAME="tst"

# Backup directory

BACKUP_DIR="/root/mysql_backup"

# S3 bucket and folder
S3_BUCKET="projectmean"
S3_FOLDER="mysql-backups"

# Timestamp for the backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M")

# Backup filename
BACKUP_FILE="backup_$TIMESTAMP.sql"

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Backup command
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/$BACKUP_FILE

# Upload to S3
aws s3 cp $BACKUP_DIR/$BACKUP_FILE s3://$S3_BUCKET/$S3_FOLDER/$BACKUP_FILE

# Delete backups older than 2 days
#find $BACKUP_DIR -name 'backup_*' -type f -mtime +1 -exec rm {} \;

# Delete for one min ago

#find $BACKUP_DIR -name 'backup_*' -type f -mmin +0 -mmin -1 -exec rm {} \;



# Delete backups from s3 older than 2 days
#aws s3 rm s3://$S3_BUCKET/$S3_FOLDER/ --recursive --exclude "*" --include "backup_*" --include "$(date -d '2 days ago' +backup_%Y%m%d_*.sql)"
#aws s3 rm s3://$S3_BUCKET/$S3_FOLDER/ --recursive --exclude "*" --include "backup_$(date -d '1 day ago' +'%Y%m%d_%H%M%S').sql"
#aws s3 rm s3://$S3_BUCKET/$S3_FOLDER/ --recursive --exclude "*" --include "backup_$(date -d '1 minute ago' +'%Y%m%d_%H%M%S').sql" --dryrun


# Delete local backups older than 2 days
find $BACKUP_DIR -name 'backup_*' -type f -mtime +1 -exec rm {} \;

# Delete S3 backups older than 2 days
#aws s3 rm s3://$S3_BUCKET/$S3_FOLDER/ --recursive --exclude "*" --include "backup_*" --include "$(date -d '1 days ago' +'%Y%m%d_%H%M').sql"

# Delete S3 backups from 1 minute ago for testing
#aws s3 rm s3://$S3_BUCKET/$S3_FOLDER/ --recursive --exclude "*" --include "backup_$(date -d '1 minute ago' +'%Y%m%d_%H%M').sql"

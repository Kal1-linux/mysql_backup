#!/bin/bash

# MySQL credentials
DB_USER="yourusername"
DB_PASSWORD="yourpassword"
DB_HOST="localhost"
DB_NAME="yourdatabase"

# Backup directory
BACKUP_DIR="/root/backup"

# S3 bucket and folder
S3_BUCKET="yourbucket-name"
S3_FOLDER="mysql-backups"

# Timestamp for the backup file
TIMESTAMP=$(TZ=Asia/Kolkata date +"%Y%m%d_%H%M")

# Backup filename
BACKUP_FILE="wb_$TIMESTAMP.sql"

# Check if the backup directory exists, create it if not
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Perform MySQL dump to create the backup
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/$BACKUP_FILE

# Upload the backup to S3
aws s3 cp $BACKUP_DIR/$BACKUP_FILE s3://$S3_BUCKET/$S3_FOLDER/

# Delete local backups older than 7 days
find $BACKUP_DIR -name 'wb_*' -type f -mtime +7 -exec rm {} \;

# Delete S3 backups older than 7 days
aws s3 rm s3://$S3_BUCKET/$S3_FOLDER/ --recursive --exclude "*" --include "wb_*" --include "$(TZ=Asia/Kolkata date -d '7 days ago' +'%Y%m%d_%H%M').sql"

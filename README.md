# mysql_backup
this is simple backup from mysql to local as well as stored on s3 bucket automatically using crontab.
# permission 
--> sudo chmod +x /root/mysql_backup/backup.sh
# setup crontab command
--> crontab -e
--> 0 */12 * * * /root/mysql_backup/backup.sh

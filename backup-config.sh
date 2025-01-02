#!/bin/bash

unset file_backup

host=$(hostname)
folder_backup="/config"
file_backup="config_backup_$(date +%d%m%Y_%H%M).tar.gz"

server_user={USER_SERVER}
server_backup={IP_SERVER}
server_folder=/home/$server_user/ubiquiti/$host

telegram_auth="/config/ssh-keys/telegram.env"
token=$(cat $telegram_auth | grep "TOKEN" | awk -F "=" '{print $2}')
chatid=$(cat $telegram_auth | grep "CHAT_ID" | awk -F "=" '{print $2}')
api_sendMessage="https://api.telegram.org/bot$token/sendMessage?parse_mode=HTML"
api_sendDocument="https://api.telegram.org/bot$token/sendDocument"

if [ -d "$server_folder" ]; then
    ssh $server_user@$server_backup ls -l $server_folder > /dev/null 2>&1
else
    ssh $server_user@$server_backup mkdir -p "$server_folder"
fi

cd /tmp || exit
tar -czvf $file_backup $folder_backup > /dev/null 2>&1
check_md5_local=$(md5sum /tmp/$file_backup | awk '{print $1}')

scp $file_backup $server_user@$server_backup:$server_folder/
check_md5_server=$(ssh $server_user@$server_backup md5sum $server_folder/$file_backup | awk '{print $1}')
verifyfile=$(ssh $server_user@$server_backup ls -l1t $server_folder | awk '{print $1, $9}' | head -2 | tail -1)

function _sendMessage() {
    curl -s -X POST $api_sendMessage -d chat_id=$chatid -d text="$1"
}

function _sendDocument() {
    curl -s -X POST $api_sendDocument -F chat_id=$chatid -F document=@"$1"
}

if [ "$check_md5_local" == "$check_md5_server" ]; then
    hashmd5="$check_md5_local"
else
    hashmd5="File $file_backup, hash MD5: $check_md5_server, md5 should be $check_md5_local"
fi

if [ "$check_md5_local" == "$check_md5_server" ]; then
        _sendMessage "$(printf "✅ <b>Backup successfully created</b>\n\nHostname: $host\nMD5: <code>$hashmd5</code>\nFile:\n <code>$verifyfile</code>")" && _sendDocument "$file_backup" > /dev/null 2>&1
        exit 0
else
        _sendMessage "$(printf "❌ <b>Backup failed, error MD5</b>\n\nHostname: $host\nError MD5: <code>$hashmd5</code>")" > /dev/null 2>&1
        exit 1
fi

rm -rf /tmp/$file_backup
exit 0

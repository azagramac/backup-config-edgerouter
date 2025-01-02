<p align="center">
  <img src="https://github.com/user-attachments/assets/0b3f8951-8d90-4ee9-94c2-74311057d430" width="500" title="er-4">
</p>

---

Script that performs a backup of the router configuration automatically and that we can define how often it is repeated, on a Linux server, and sends us a notification by telegram with the result. 

Requirements:
- EdgeRouter 4 Router, valid for 6P (tested with firmware: v2.0.9-hotfix.7)
- Linux server
- Telegram account

---
We connect to the router via ssh
```bash
ssh {user}@{ip_router}
sudo bash
```
\
Generate ssh key and copy it to the linux server where we are going to save the backups.
```bash
ssh-keygen -t rsa -b 4096
...
ssh-copy-id -i .ssh/id_rsa.pub {user}@{ip_server}
```
\
Create bot, and get token/chatID bot:
- [![botfather](https://img.shields.io/badge/-botfather-0088cc?style=flat&labelColor=0088cc&logo=telegram&logoColor=white)](https://t.me/botfather)
- [![myidbot](https://img.shields.io/badge/-myidbot-0088cc?style=flat&labelColor=0088cc&logo=telegram&logoColor=white)](https://t.me/myidbot)

Change in the file `telegram.env`, the variables `TOKEN` and `CHAT_ID`.
```yaml
TOKEN={YOUR_TOKEN_TELEGRAM}
CHAT_ID={YOUR_CHAT_ID}
```
\
Change in the file `backup-config.sh`, the variables `server_user` and `server_backup`.
```shell
server_user={USER_SERVER}
server_backup={IP_SERVER}
```
\
Copy files `telegram.env` and `backup-config.sh` to the router
```bash
/config/ssh-keys/telegram.env
/config/scripts/backup-config.sh
chmod a+x /config/scripts/backup-config.sh
```

```shell
configure
set system task-scheduler task backup-conf executable path /config/scripts/backup-config.sh
set system task-scheduler task backup-conf interval {interval}
commit ;save
```

`{interval}`
 - none - Execution interval in minutes 
 - m - Execution interval in minutes 
 - h - Execution interval in hours
 - d - Execution interval in days

example:
```shell
set system task-scheduler task backup-conf interval 7d
```

Capture of the result
 
<p align="left">
  <img src="https://github.com/user-attachments/assets/4ed7b51e-5be9-423a-beda-2f665e32d1d3" width="350" title="screenshot_tg">
</p>

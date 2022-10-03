# Installer
This is script what will
- clone bare repo with all backup files
- push/pull changes
- update system configuration according to ansible script

## Usage
```sh
curl -s https://raw.githubusercontent.com/Shirobachi/super-duper-octo-spork/master/Documents/Linux/Update.sh | bash &&
sudo curl -s https://raw.githubusercontent.com/Shirobachi/super-duper-octo-spork/master/Documents/Linux/super-duper-octo-spork.service -o /etc/systemd/system/super-duper-octo-spork.service &&
sudo systemctl enable super-duper-octo-spork
```
**Using on own risk!**

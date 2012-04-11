#!/bin/bash
if [ "$(echo $(pwd) | grep 'current$')" = "" ]; then
  echo "You must run this script from the 'current' directory"
else
  if [ "$1" = "" ]; then
    echo "You must provide a domain name"
  else
    echo "Installing beanstalk"
    sudo emerge --sync
    EC2_FILE=/etc/portage/package.keywords/ec2
    sudo chown deploy:deploy $EC2_FILE
    sudo echo "app-misc/beanstalkd ~amd64 ~x86" >> $EC2_FILE
    sudo chown root:root $EC2_FILE
    sudo emerge app-misc/beanstalkd
    sudo /etc/init.d/beanstalkd start
    echo "DONE"
    echo "Uninstalling ssmtp."
    sudo emerge --unmerge ssmtp
    echo "DONE"
    echo "Installing postfix."
    sudo emerge postfix
    echo "DONE"
    
    echo "Editing postfix configuration files."
    MAIN_FILE=/etc/postfix/main.cf
    MASTER_FILE=/etc/postfix/master.cf
    sudo chown deploy:deploy $MAIN_FILE
    sudo chown deploy:deploy $MASTER_FILE
    echo "myhostname = $1" >> $MAIN_FILE
    echo "mydestination = $1" >> $MAIN_FILE
    echo "myorigin = $1" >> $MAIN_FILE
    echo "local_recipient_maps =" >> $MAIN_FILE
    echo "luser_relay = deploy" >> $MAIN_FILE
    echo "tramlines_filter unix - n n - - pipe flags=Xhq user=deploy argv=/usr/bin/ruby $(pwd)/vendor/plugins/tramlines_mail_response/lib/mail_receiver.rb" >> $MASTER_FILE
    sudo sed -i -r -e 's/^[^#].+smtpd/&\n -o content_filter=tramlines_filter:/' $MASTER_FILE
    sudo chown root:root $MAIN_FILE
    sudo chown root:root $MASTER_FILE
    echo "DONE"
    
    echo "Starting postfix"
    sudo /usr/sbin/postfix start
    echo "DONE"
    echo "TODO: In order for the engine yard server to receive the emails, port 25 needs to be open."
    echo "See https://community.engineyard.com/discussions/problems/44-firewalled-ports, comment 4"
  fi
fi
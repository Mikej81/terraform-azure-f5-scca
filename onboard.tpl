#!/bin/bash

# BIG-IPS ONBOARD SCRIPT

LOG_FILE=${onboard_log}

if [ ! -e $LOG_FILE ]
then
     touch $LOG_FILE
     exec &>>$LOG_FILE
else
    #if file exists, exit as only want to run once
    exit
fi

exec 1>$LOG_FILE 2>&1

# CHECK TO SEE NETWORK IS READY
CNT=0
while true
do
  STATUS=$(curl -s -k -I example.com | grep HTTP)
  if [[ $STATUS == *"200"* ]]; then
    echo "Got 200! VE is Ready!"
    break
  elif [ $CNT -le 6 ]; then
    echo "Status code: $STATUS  Not done yet..."
    CNT=$[$CNT+1]
  else
    echo "GIVE UP..."
    break
  fi
  sleep 10
done

### DOWNLOAD ONBOARDING PKGS
# Could be pre-packaged or hosted internally

admin_username='${uname}'
admin_password='${upassword}'
CREDS="admin:"$admin_password
DO_URL='${DO_onboard_URL}'
DO_FN=$(basename "$DO_URL")
AS3_URL='${AS3_URL}'
AS3_FN=$(basename "$AS3_URL")

DO1='${DO1_Document}'
DO2='${DO2_Document}'
AS3='${AS3_Document}'

mkdir -p ${libs_dir}

echo -e "\n"$(date) "Download Declarative Onboarding Pkg"
curl -L -o ${libs_dir}/$DO_FN $DO_URL

echo -e "\n"$(date) "Download AS3 Pkg"
curl -L -o ${libs_dir}/$AS3_FN $AS3_URL
sleep 20

# Copy the RPM Pkg to the file location
cp ${libs_dir}/*.rpm /var/config/rest/downloads/

# Install Declarative Onboarding Pkg
DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$DO_FN\"}"
echo -e "\n"$(date) "Install DO Pkg"
curl -u $CREDS -X POST http://localhost:8100/mgmt/shared/iapp/package-management-tasks -d $DATA

# Install AS3 Pkg
DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$AS3_FN\"}"
echo -e "\n"$(date) "Install AS3 Pkg"
curl -u $CREDS -X POST http://localhost:8100/mgmt/shared/iapp/package-management-tasks -d $DATA

# Check DO Ready
CNT=0
while true
do
  STATUS=$(curl -u $CREDS -X GET -s -k -I https://localhost/mgmt/shared/declarative-onboarding | grep HTTP)
  if [[ $STATUS == *"200"* ]]; then
    echo "Got 200! Declarative Onboarding is Ready!"
    break
  elif [ $CNT -le 6 ]; then
    echo "Status code: $STATUS  DO Not done yet..."
    CNT=$[$CNT+1]
  else
    echo "GIVE UP..."
    break
  fi
  sleep 10
done

# Check AS3 Ready
CNT=0
while true
do
  STATUS=$(curl -u $CREDS -X GET -s -k -I https://localhost/mgmt/shared/appsvcs/info | grep HTTP)
  if [[ $STATUS == *"200"* ]]; then
    echo "Got 200! AS3 is Ready!"
    break
  elif [ $CNT -le 6 ]; then
    echo "Status code: $STATUS  AS3 Not done yet..."
    CNT=$[$CNT+1]
  else
    echo "GIVE UP..."
    break
  fi
  sleep 10
done

# vars
cat << 'EOF' > /config/cloud/do1.json
    ${do_body_01}
EOF
cat << 'EOF' > /config/cloud/do2.json
    ${do_body_02}
EOF
cat << 'EOF' > /config/cloud/as3.json
    ${as3_body}
EOF
DO_BODY_01="/config/cloud/do1.json"
DO_BODY_02="/config/cloud/do2.json"
AS3_BODY="/config/cloud/as3.json"

DO_URL_POST="/mgmt/shared/declarative-onboarding"
AS3_URL_POST="/mgmt/shared/appsvcs/declare"
# run DO
if [ $1 == "1" ]; then
    # DO_BODY=`cat /config/cloud/do1.json`
    restcurl -u $CREDS -X POST "mgmt/shared/declarative-onboarding" -d $DO_BODY_01
else
    # DO_BODY=`cat /config/cloud/do2.json`
    restcurl -u $CREDS -X POST "mgmt/shared/declarative-onboarding" -d $DO_BODY_02
fi
#curl -k -X POST https://localhost:8100$DO_URL_POST?async=true -u $CREDS -d @$DO_BODY_01 
# run as3
# AS3_BODY=`cat /config/cloud/as3.json`
restcurl -u $CREDS -X POST "/mgmt/shared/appsvcs/declare" -d $AS3_BODY
# curl -k -X POST https://localhost:8100$AS3_URL_POST?async=true -u $CREDS -d @$AS3_BODY
#
# rm -f /config/cloud/do1.json
# rm -f /config/cloud/do2.json
# rm -f /config/cloud/as3.json
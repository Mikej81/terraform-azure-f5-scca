#!/bin/bash
#
# vars
#
admin_username='${uname}'
admin_password='${upassword}'
CREDS="$admin_username:$admin_password"
DO_URL='${DO_onboard_URL}'
DO_FN=$(basename "$DO_URL")
AS3_URL='${AS3_URL}'
AS3_FN=$(basename "$AS3_URL")
LOG_FILE=${onboard_log}
#atc="f5-declarative-onboarding f5-appsvcs-extension f5-telemetry-streaming"
atc="f5-declarative-onboarding f5-appsvcs-extension"
# constants
mgmt_port=`tmsh list sys httpd ssl-port | grep ssl-port | sed 's/ssl-port //;s/ //g'`
authUrl="/mgmt/shared/authn/login"
rpmInstallUrl="/mgmt/shared/iapp/package-management-tasks"
rpmFilePath="/var/config/rest/downloads"
# do
doUrl="/mgmt/shared/declarative-onboarding"
doCheckUrl="/mgmt/shared/declarative-onboarding/info"
doTaskUrl="/shared/declarative-onboarding/task"
# as3
as3Url="/mgmt/shared/appsvcs/declare"
as3CheckUrl="/mgmt/shared/appsvcs/info"
# ts
tsUrl="/mgmt/shared/telemetry/declare"
tsCheckUrl="/mgmt/shared/telemetry/info" 
# declaration content
cat > /config/do1.json <<EOF
${DO1_Document}
EOF
cat > /config/do2.json <<EOF
${DO2_Document}
EOF
cat > /config/as3.json <<EOF
${AS3_Document}
EOF

DO_BODY_01="/config/do1.json"
DO_BODY_02="/config/do2.json"
AS3_BODY="/config/as3.json"

DO_URL_POST="/mgmt/shared/declarative-onboarding"
AS3_URL_POST="/mgmt/shared/appsvcs/declare"
# BIG-IPS ONBOARD SCRIPT


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

# download latest atc tools

for tool in $atc
do
    
    echo "downloading $tool"
    files=$(/usr/bin/curl -sk --interface mgmt https://api.github.com/repos/F5Networks/$tool/releases/latest | jq -r '.assets[] | select(.name | contains (".rpm")) | .browser_download_url')
    for file in $files
    do
    echo "download: $file"
    name=$(basename $file )
    result=$(/usr/bin/curl -Lsk  $file -o /var/config/rest/downloads/$name)
    done
done

# install atc tools
rpms=$(find $rpmFilePath -name "*.rpm" -type f)
for rpm in $rpms
do
  filename=$(basename $rpm)
  echo "installing $filename"
  postBody="{\"operation\":\"INSTALL\",\"packageFilePath\":\"$rpmFilePath/$filename\"}"
  install=$(restcurl -u $CREDS -X POST -d $postBody $rpmInstallUrl | jq -r .id )
  while true
  do
    status=$(restcurl -u $CREDS $rpmInstallUrl/$install | jq -r .status)
    case $status in 
        FINISHED)
            # finished
            echo " rpm: $filename task: $install status: $status"
            break
            ;;
        STARTED)
            # started
            echo " rpm: $filename task: $install status: $status"
            ;;
        RUNNING)
            # running
            echo " rpm: $filename task: $install status: $status"
            ;;
        FAILED)
            # failed
            error=$(restcurl -u $CREDS $rpmInstallUrl/$install | jq .errorMessage)
            echo "failed $filename task: $install error: $error"
            break
            ;;
        *)
            # other
            debug=$(restcurl -u $CREDS $rpmInstallUrl/$install | jq .)
            echo "failed $filename task: $install error: $debug"
            break
            ;;
        esac
    sleep 2
    done
done
function checkDO() {
    # Check DO Ready
    CNT=0
    while true
    do
    doStatus=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .[].result.status)
    if [[ $doStatus == "OK" ]]; then
        version=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .[].version)
        echo "Declarative Onboarding $version online "
        break
    else
        echo "Status $doStatus"
        break
    fi
    sleep 10
    done
}
function checkAS3() {
    # Check AS3 Ready
    CNT=0
    while true
    do
    as3Status=$(curl -i -u $CREDS http://localhost:8100$as3CheckUrl | grep HTTP | awk '{print $2}')
    if [[ $as3Status == "200" ]]; then
        version=$(restcurl -u $CREDS -X GET $as3CheckUrl | jq -r .version)
        echo "As3 $version online "
        break
    else
        echo "Status $as3Status"
        break
    fi
    sleep 10
    done
}
function checkTS() {
    # Check TS Ready
    CNT=0
    while true
    do
    tsStatus=$(curl -i -u $CREDS http://localhost:8100$tsCheckUrl | grep HTTP | awk '{print $2}')
    if [[ $tsStatus == "200" ]]; then
        version=$(restcurl -u $CREDS -X GET $tsCheckUrl | jq -r .version)
        echo "Telemetry Streaming $version online "
        break
    else
        echo "Status $tsStatus"
        break
    fi
    sleep 10
    done
}
doStatus=$(checkDO)
echo "$doStatus"
as3Status=$(checkAS3)
echo "$as3Status"
# tsStatus=$(checkTS)
# echo "$tsStatus"
function waitDO() {
        CNT=0
        while [ $CNT -le 4 ]
            do
            status=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
            echo "waiting... $task status: $status"
            if [ $status == "FINISHED" ]; then
                echo "FINISHED"
                break
            elif [ $status == "RUNNING" ]; then
                echo "Status: $status  Still Waiting..."
                sleep 30
                CNT=$[$CNT+1]
            elif [ $status == "OK" ]; then
                echo "OK"
                break
            else
                echo "OTHER"
                break
            fi
        done
}
function runDO() {
    CNT=0
    while [ $CNT -le 10 ]
        do 
        # make task
        task=$(curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST http://localhost:8100/mgmt/shared/declarative-onboarding -d @/config/$1 | jq -r .id)
        echo "starting task: $task"
        sleep 1
        # check task code
        code=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .code)
        sleep 1
        if  [ "$code" == "null" ] || [ -z "$code" ]; then
            sleep 1
            status=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
            sleep 1
            #FINISHED,STARTED,RUNNING,ROLLING_BACK,FAILED,ERROR,NULL
            case $status in 
            FINISHED)
                # finished
                echo " $task status: $status "
                break
                ;;
            STARTED)
                # started
                echo " $filename status: $status "
                sleep 20
                ;;
            RUNNING)
                # running
                echo "DO status: $status $task"
                CNT=$[$CNT+1]
                sleep 60
                status=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
                if [ $status == "FINISHED" ]; then
                    echo "do done for $task for $1"
                    break
                elif [ $status == "RUNNING" ]; then
                    echo "Status: $status  Not done yet..."
                    sleep 60
                    waitStatus=$(waitDO)
                    if [ $waitStatus == "FINISHED" ]; then
                        break
                    else
                        echo "wait result: $waitStatus"
                    fi
                elif [ $status == "OK" ]; then
                    echo "Done Status code: $status  No change $task"
                    break
                else
                    echo "other $status"
                    CNT=$[$CNT+1]
                fi 
                ;;
            FAILED)
                # failed
                error=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
                echo "failed $task, $error"
                CNT=$[$CNT+1]
                ;;
            ERROR)
                # error
                error=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
                echo "Error $task, $error"
                CNT=$[$CNT+1]
                ;;
            OK)
                # complete no change
                echo "Complete no change status: $status"
                break
                ;;
            *)
                # other
                echo "other: $status"
                debug=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq .)
                echo "debug: $debug"
                error=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
                echo "Other $task, $error"
                CNT=$[$CNT+1]
                sleep 60
                ;;
            esac
        else
            echo "DO code: $code"
            CNT=$[$CNT+1]
        fi
    done
}
# run DO
if [ $1 == 1 ] && [[ "$doStatus" = *"online"* ]]; then 
    echo "running do for 01"
    runDO do1.json
elif [[ "$doStatus" = *"online"* ]]; then
    echo "running do for 02"
    runDO do2.json
else
    echo "DO not online status: $doStatus"
fi

as3Status=$(checkAS3)
echo "$as3Status"

function runAS3 () {
    CNT=0
    while [ $CNT -le 10 ]
        do
        echo "running as3"
        task=$(curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST http://localhost:8100$as3Url?async=true -d @/config/as3.json | jq -r .id)
        status=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$task | jq -r '.results[].message')
        case $status in
        no*change)
            # finished
            echo " $task status: $status "
            break
            ;;
        in*progress)
            # in progress
            echo "Running: $task status: $status "
            sleep 60
            status=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$task | jq -r '.results[].message')
            if [[ $status == * ]]; then
                echo "status: $status"
                break
            fi
            ;;
        Error*)
            # error
            echo "Error: $task status: $status "
            ;;
        
        *)
            # other
            echo "status: $status"
            debug=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$task | jq .)
            echo "debug: $debug"
            error=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$task | jq -r '.results[].message')
            echo "Other: $task, $error"
            CNT=$[$CNT+1]
            ;;
        esac
    done
}

#
# create logging profiles
# network profile
echo  -e 'create cli transaction;
create security log profile local_afm_log ip-intelligence { log-publisher local-db-publisher } network replace-all-with { local_afm_log { filter { log-acl-match-accept enabled log-acl-match-drop enabled log-acl-match-reject enabled log-geo-always enabled log-ip-errors enabled log-tcp-errors enabled log-tcp-events enabled log-translation-fields enabled } publisher local-db-publisher } }
submit cli transaction' | tmsh -q
#
# asm profile
echo  -e 'create cli transaction;
create security log profile local_sec_log application replace-all-with { local_sec_log { filter replace-all-with { log-challenge-failure-requests { values replace-all-with { enabled } } request-type { values replace-all-with { all } } } response-logging illegal } } bot-defense replace-all-with { local_sec_log { filter { log-alarm enabled log-block enabled log-browser enabled log-browser-verification-action enabled log-captcha enabled log-challenge-failure-request enabled log-device-id-collection-request enabled log-honey-pot-page enabled log-malicious-bot enabled log-mobile-application enabled log-none enabled log-rate-limit enabled log-redirect-to-pool enabled log-suspicious-browser enabled log-tcp-reset enabled log-trusted-bot enabled log-unknown enabled log-untrusted-bot enabled } local-publisher /Common/local-db-publisher } };
submit cli transaction' | tmsh -q

# run as3
CNT=0
while true
do
    if [[ $as3Status == *"online"* ]]; then
        echo "running as3"
        runAS3
        break
    elif [ $CNT -le 6 ]; then
        echo "Status code: $as3Status  As3 not ready yet..."
        CNT=$[$CNT+1]
    else
        echo "Status $as3Status"
        break
    fi
done


# remove declarations
# rm -f /config/do1.json
# rm -f /config/do2.json
# rm -f /config/as3.json
#!/bin/bash
#
# vars
#
# get device id for do
deviceId=$1
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
atc="f5-declarative-onboarding f5-appsvcs-extension f5-telemetry-streaming f5-cloud-failover-extension"
# constants
mgmt_port=`tmsh list sys httpd ssl-port | grep ssl-port | sed 's/ssl-port //;s/ //g'`
authUrl="/mgmt/shared/authn/login"
rpmInstallUrl="/mgmt/shared/iapp/package-management-tasks"
rpmFilePath="/var/config/rest/downloads"
# do
doUrl="/mgmt/shared/declarative-onboarding"
doCheckUrl="/mgmt/shared/declarative-onboarding/info"
doTaskUrl="/mgmt/shared/declarative-onboarding/task"
# as3
as3Url="/mgmt/shared/appsvcs/declare"
as3CheckUrl="/mgmt/shared/appsvcs/info"
as3TaskUrl="/mgmt/shared/appsvcs/task/"
# ts
tsUrl="/mgmt/shared/telemetry/declare"
tsCheckUrl="/mgmt/shared/telemetry/info" 
# cloud failover ext
cfUrl="/mgmt/shared/cloud-failover/declare"
cfCheckUrl="/mgmt/shared/cloud-failover/info"
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

startTime=$(date +%s)
echo "timestamp start: $(date)"
function timer () {
    echo "Time Elapsed: $(( ${1} / 3600 ))h $(( (${1} / 60) % 60 ))m $(( ${1} % 60 ))s"
}
# CHECK TO SEE NETWORK IS READY
count=0
while true
do
  STATUS=$(curl -s -k -I example.com | grep HTTP)
  if [[ $STATUS == *"200"* ]]; then
    echo "internet access check passed"
    break
  elif [ $count -le 6 ]; then
    echo "Status code: $STATUS  Not done yet..."
    count=$[$count+1]
  else
    echo "GIVE UP..."
    break
  fi
  sleep 10
done
# azure cloud libs
mkdir  -p /config/cloud/azure
echo  'Y2xpIHNjcmlwdCAvQ29tbW9uL3ZlcmlmeUhhc2ggewpwcm9jIHNjcmlwdDo6cnVuIHt9IHsKICAg
ICAgICBpZiB7W2NhdGNoIHsKICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS1jbG91ZC1saWJzLnRh
ci5neikgNzllZDYzNzg3ZWJhZDE3N2ZiZDA1MmRhMTU3MTA5NTg4NGI3ZDU5OGZlYzQ0NTY4Zjk5
YmI1YWU2NmNkNjYzNWYyZmRkMzVjNWU0ZjU4MmM1ZDQyOTI5ZDY4YTRlMjExNWM4MTgzNDkyMDkz
OWIwYTZkYTBlM2YxNmRhMGFjNjcKICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS1jbG91ZC1saWJz
LWF3cy50YXIuZ3opIDJiOTM0MzA3NDc3ZmFmNzcyZTE1NThhYjM2MzY3MTY5ODEyMTVkNmIxNWYy
YTE4NDc1MDQ3MzkxMWQxZDM4YmZiZDZhMmRjNzk2MTRiMWQxNTc1ZGNlOGYzODI0ZWQ4MDVkYWEz
ZDljYTQ4YzdlOTRjNjY5MmYwM2I5ZTRlZDdhCiAgICAgICAgICAgIHNldCBoYXNoZXMoZjUtY2xv
dWQtbGlicy1henVyZS50YXIuZ3opIGY2ZDEwMzQ3MTgxYTEwMWI5NzQ0NzhjYzdjMGQ0NGM5Yzhj
ZmQ3NzA1YTZiY2NjOWQ0OGIyZThhZjE3NTA2NmY1MjYxMmIyOGU5YTBmYWEyNTc2NzViOWE5Nzk4
MDM5NTJhMzFkOWQwY2YyY2M1ZmYxODIzMWZiYjQyZTc4NmM5CiAgICAgICAgICAgIHNldCBoYXNo
ZXMoZjUtY2xvdWQtbGlicy1nY2UudGFyLmd6KSBhNWNmYWVkMWZlMzNkYTY3N2IzZjEwZGMxYTdj
YTgyZjU3MzlmZjI0ZTQ1ZTkxYjNhOGY3YjA2ZDZiMmUyODBlNWYxZWFmNWZlMmQzMzAwOWIyY2M2
N2MxMGYyZDkwNmFhYjI2Zjk0MmQ1OTFiNjhmYThhN2ZkZGZkNTRhMGVmZQogICAgICAgICAgICBz
ZXQgaGFzaGVzKGY1LWNsb3VkLWxpYnMtb3BlbnN0YWNrLnRhci5neikgNWM4M2ZlNmE5M2E2ZmNl
YjVhMmU4NDM3YjVlZDhjYzlmYWY0YzE2MjFiZmM5ZTZhMDc3OWY2YzIxMzdiNDVlYWI4YWUwZTdl
ZDc0NWM4Y2Y4MjFiOTM3MTI0NWNhMjk3NDljYTBiN2U1NjYzOTQ5ZDc3NDk2Yjg3MjhmNGIwZjkK
ICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS1jbG91ZC1saWJzLWNvbnN1bC50YXIuZ3opIGEzMmFh
YjM5NzA3M2RmOTJjYmJiYTUwNjdlNTgyM2U5YjVmYWZjYTg2MmEyNThiNjBiNmI0MGFhMDk3NWMz
OTg5ZDFlMTEwZjcwNjE3N2IyZmZiZTRkZGU2NTMwNWEyNjBhNTg1NjU5NGNlN2FkNGVmMGM0N2I2
OTRhZTRhNTEzCiAgICAgICAgICAgIHNldCBoYXNoZXMoYXNtLXBvbGljeS1saW51eC50YXIuZ3op
IDYzYjVjMmE1MWNhMDljNDNiZDg5YWYzNzczYmJhYjg3YzcxYTZlN2Y2YWQ5NDEwYjIyOWI0ZTBh
MWM0ODNkNDZmMWE5ZmZmMzlkOTk0NDA0MWIwMmVlOTI2MDcyNDAyNzQxNGRlNTkyZTk5ZjRjMjQ3
NTQxNTMyM2UxOGE3MmUwCiAgICAgICAgICAgIHNldCBoYXNoZXMoZjUuaHR0cC52MS4yLjByYzQu
dG1wbCkgNDdjMTlhODNlYmZjN2JkMWU5ZTljMzVmMzQyNDk0NWVmODY5NGFhNDM3ZWVkZDE3YjZh
Mzg3Nzg4ZDRkYjEzOTZmZWZlNDQ1MTk5YjQ5NzA2NGQ3Njk2N2IwZDUwMjM4MTU0MTkwY2EwYmQ3
Mzk0MTI5OGZjMjU3ZGY0ZGMwMzQKICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS5odHRwLnYxLjIu
MHJjNi50bXBsKSA4MTFiMTRiZmZhYWI1ZWQwMzY1ZjAxMDZiYjVjZTVlNGVjMjIzODU2NTVlYTNh
YzA0ZGUyYTM5YmQ5OTQ0ZjUxZTM3MTQ2MTlkYWU3Y2E0MzY2MmM5NTZiNTIxMjIyODg1OGYwNTky
NjcyYTI1NzlkNGE4Nzc2OTE4NmUyY2JmZQogICAgICAgICAgICBzZXQgaGFzaGVzKGY1Lmh0dHAu
djEuMi4wcmM3LnRtcGwpIDIxZjQxMzM0MmU5YTdhMjgxYTBmMGUxMzAxZTc0NWFhODZhZjIxYTY5
N2QyZTZmZGMyMWRkMjc5NzM0OTM2NjMxZTkyZjM0YmYxYzJkMjUwNGMyMDFmNTZjY2Q3NWM1YzEz
YmFhMmZlNzY1MzIxMzY4OWVjM2M5ZTI3ZGZmNzdkCiAgICAgICAgICAgIHNldCBoYXNoZXMoZjUu
YXdzX2FkdmFuY2VkX2hhLnYxLjMuMHJjMS50bXBsKSA5ZTU1MTQ5YzAxMGMxZDM5NWFiZGFlM2Mz
ZDJjYjgzZWMxM2QzMWVkMzk0MjQ2OTVlODg2ODBjZjNlZDVhMDEzZDYyNmIzMjY3MTFkM2Q0MGVm
MmRmNDZiNzJkNDE0YjRjYjhlNGY0NDVlYTA3MzhkY2JkMjVjNGM4NDNhYzM5ZAogICAgICAgICAg
ICBzZXQgaGFzaGVzKGY1LmF3c19hZHZhbmNlZF9oYS52MS40LjByYzEudG1wbCkgZGUwNjg0NTUy
NTc0MTJhOTQ5ZjFlYWRjY2FlZTg1MDYzNDdlMDRmZDY5YmZiNjQ1MDAxYjc2ZjIwMDEyNzY2OGU0
YTA2YmUyYmJiOTRlMTBmZWZjMjE1Y2ZjMzY2NWIwNzk0NWU2ZDczM2NiZTFhNGZhMWI4OGU4ODE1
OTAzOTYKICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS5hd3NfYWR2YW5jZWRfaGEudjEuNC4wcmMy
LnRtcGwpIDZhYjBiZmZjNDI2ZGY3ZDMxOTEzZjlhNDc0YjFhMDc4NjA0MzVlMzY2YjA3ZDc3YjMy
MDY0YWNmYjI5NTJjMWYyMDdiZWFlZDc3MDEzYTE1ZTQ0ZDgwZDc0ZjMyNTNlN2NmOWZiYmUxMmE5
MGVjNzEyOGRlNmZhY2QwOTdkNjhmCiAgICAgICAgICAgIHNldCBoYXNoZXMoZjUuYXdzX2FkdmFu
Y2VkX2hhLnYxLjQuMHJjMy50bXBsKSAyZjIzMzliNGJjM2EyM2M5Y2ZkNDJhYWUyYTZkZTM5YmEw
NjU4MzY2ZjI1OTg1ZGUyZWE1MzQxMGE3NDVmMGYxOGVlZGM0OTFiMjBmNGE4ZGJhOGRiNDg5NzAw
OTZlMmVmZGNhN2I4ZWZmZmExYTgzYTc4ZTVhYWRmMjE4YjEzNAogICAgICAgICAgICBzZXQgaGFz
aGVzKGY1LmF3c19hZHZhbmNlZF9oYS52MS40LjByYzQudG1wbCkgMjQxOGFjOGIxZjE4ODRjNWMw
OTZjYmFjNmE5NGQ0MDU5YWFhZjA1OTI3YTZhNDUwOGZkMWYyNWI4Y2M2MDc3NDk4ODM5ZmJkZGE4
MTc2ZDJjZjJkMjc0YTI3ZTZhMWRhZTJhMWUzYTBhOTk5MWJjNjVmYzc0ZmMwZDAyY2U5NjMKICAg
ICAgICAgICAgc2V0IGhhc2hlcyhmNS5hd3NfYWR2YW5jZWRfaGEudjEuNC4wcmM1LnRtcGwpIDVl
NTgyMTg3YWUxYTYzMjNlMDk1ZDQxZWRkZDQxMTUxZDZiZDM4ZWI4M2M2MzQ0MTBkNDUyN2EzZDBl
MjQ2YThmYzYyNjg1YWIwODQ5ZGUyYWRlNjJiMDI3NWY1MTI2NGQyZGVhY2NiYzE2Yjc3MzQxN2Y4
NDdhNGExZWE5YmM0CiAgICAgICAgICAgIHNldCBoYXNoZXMoYXNtLXBvbGljeS50YXIuZ3opIDJk
MzllYzYwZDAwNmQwNWQ4YTE1NjdhMWQ4YWFlNzIyNDE5ZThiMDYyYWQ3N2Q2ZDlhMzE2NTI5NzFl
NWU2N2JjNDA0M2Q4MTY3MWJhMmE4YjEyZGQyMjllYTQ2ZDIwNTE0NGY3NTM3NGVkNGNhZTU4Y2Vm
YThmOWFiNjUzM2U2CiAgICAgICAgICAgIHNldCBoYXNoZXMoZGVwbG95X3dhZi5zaCkgMWEzYTNj
NjI3NGFiMDhhN2RjMmNiNzNhZWRjOGQyYjJhMjNjZDllMGViMDZhMmUxNTM0YjM2MzJmMjUwZjFk
ODk3MDU2ZjIxOWQ1YjM1ZDNlZWQxMjA3MDI2ZTg5OTg5Zjc1NDg0MGZkOTI5NjljNTE1YWU0ZDgy
OTIxNGZiNzQKICAgICAgICAgICAgc2V0IGhhc2hlcyhmNS5wb2xpY3lfY3JlYXRvci50bXBsKSAw
NjUzOWUwOGQxMTVlZmFmZTU1YWE1MDdlY2I0ZTQ0M2U4M2JkYjFmNTgyNWE5NTE0OTU0ZWY2Y2E1
NmQyNDBlZDAwYzdiNWQ2N2JkOGY2N2I4MTVlZTlkZDQ2NDUxOTg0NzAxZDA1OGM4OWRhZTI0MzRj
ODk3MTVkMzc1YTYyMAogICAgICAgICAgICBzZXQgaGFzaGVzKGY1LnNlcnZpY2VfZGlzY292ZXJ5
LnRtcGwpIDQ4MTFhOTUzNzJkMWRiZGJiNGY2MmY4YmNjNDhkNGJjOTE5ZmE0OTJjZGEwMTJjODFl
M2EyZmU2M2Q3OTY2Y2MzNmJhODY3N2VkMDQ5YTgxNGE5MzA0NzMyMzRmMzAwZDNmOGJjZWQyYjBk
YjYzMTc2ZDUyYWM5OTY0MGNlODFiCiAgICAgICAgICAgIHNldCBoYXNoZXMoZjUuY2xvdWRfbG9n
Z2VyLnYxLjAuMC50bXBsKSA2NGEwZWQzYjVlMzJhMDM3YmE0ZTcxZDQ2MDM4NWZlOGI1ZTFhZWNj
MjdkYzBlODUxNGI1MTE4NjM5NTJlNDE5YTg5ZjRhMmE0MzMyNmFiYjU0M2JiYTliYzM0Mzc2YWZh
MTE0Y2VkYTk1MGQyYzNiZDA4ZGFiNzM1ZmY1YWQyMAogICAgICAgICAgICBzZXQgaGFzaGVzKGY1
LWFwcHN2Y3MtMy41LjEtNS5ub2FyY2gucnBtKSBiYTcxYzZlMWM1MmQwYzcwNzdjZGIyNWE1ODcw
OWI4ZmI3YzM3YjM0NDE4YTgzMzhiYmY2NzY2ODMzOTY3NmQyMDhjMWE0ZmVmNGU1NDcwYzE1MmFh
Yzg0MDIwYjRjY2I4MDc0Y2UzODdkZTI0YmUzMzk3MTEyNTZjMGZhNzhjOAoKICAgICAgICAgICAg
c2V0IGZpbGVfcGF0aCBbbGluZGV4ICR0bXNoOjphcmd2IDFdCiAgICAgICAgICAgIHNldCBmaWxl
X25hbWUgW2ZpbGUgdGFpbCAkZmlsZV9wYXRoXQoKICAgICAgICAgICAgaWYgeyFbaW5mbyBleGlz
dHMgaGFzaGVzKCRmaWxlX25hbWUpXX0gewogICAgICAgICAgICAgICAgdG1zaDo6bG9nIGVyciAi
Tm8gaGFzaCBmb3VuZCBmb3IgJGZpbGVfbmFtZSIKICAgICAgICAgICAgICAgIGV4aXQgMQogICAg
ICAgICAgICB9CgogICAgICAgICAgICBzZXQgZXhwZWN0ZWRfaGFzaCAkaGFzaGVzKCRmaWxlX25h
bWUpCiAgICAgICAgICAgIHNldCBjb21wdXRlZF9oYXNoIFtsaW5kZXggW2V4ZWMgL3Vzci9iaW4v
b3BlbnNzbCBkZ3N0IC1yIC1zaGE1MTIgJGZpbGVfcGF0aF0gMF0KICAgICAgICAgICAgaWYgeyAk
ZXhwZWN0ZWRfaGFzaCBlcSAkY29tcHV0ZWRfaGFzaCB9IHsKICAgICAgICAgICAgICAgIGV4aXQg
MAogICAgICAgICAgICB9CiAgICAgICAgICAgIHRtc2g6OmxvZyBlcnIgIkhhc2ggZG9lcyBub3Qg
bWF0Y2ggZm9yICRmaWxlX3BhdGgiCiAgICAgICAgICAgIGV4aXQgMQogICAgICAgIH1dfSB7CiAg
ICAgICAgICAgIHRtc2g6OmxvZyBlcnIge1VuZXhwZWN0ZWQgZXJyb3IgaW4gdmVyaWZ5SGFzaH0K
ICAgICAgICAgICAgZXhpdCAxCiAgICAgICAgfQogICAgfQogICAgc2NyaXB0LXNpZ25hdHVyZSBT
UzZQQVIydmNLOE95K1pxL0FmOGJXUzZtajNpcG9SZ05Wa3pibmY1OXdVby84bVR6V0Z1VlRGMkgx
WVNYRFJqVzhnSm1aZklRck9hc3YwMUF5cWp6bDhJWjVBUTVhQlFkMk9LVFpOQ3Bzb2FsVFgxaWFy
NERzODJZZEo4WjBFdVd3eTlVQnljbEZZb3VNNHdNbUd0czVOcURpYTZXK2tBVWNUSnhPa2N4a3p1
dXJVWFlhVlIzWXg2c1daWnlOVEkzbVVxWjg0VEVaWFdqRXcxUWk3UzZ4T0Rtcnl3MnNINUFQV3BB
eFE4SXA2YzhKc3VCbTFCN0EyNGNvdXY5YWVkZW9DYk5aZG1DUGpNZldHMXZCRFZScXZvdTBTUWQ4
a2JIYSszNkxia3pOcXlYV0xhbUszSFRZSkFOOUJNVXgrc3lYRWM0Ri9zSmdwS2VIS0dIRm93WWc9
PQogICAgc2lnbmluZy1rZXkgL0NvbW1vbi9mNS1pcnVsZQp9CgoK' | base64 -d > /config/verifyHash
cat  <<EOF > /config/installCloudLibs.sh
#!/bin/bash
echo  about to execute
checks=0
while [ $checks -lt 120 ]; do echo checking mcpd
    tmsh -a show sys mcp-state field-fmt | grep -q running
   if [ $? == 0 ]; then
       echo mcpd ready
       break
   fi
   echo mcpd not ready yet
   let checks=checks+1
   sleep 10
done 
echo  loading verifyHash script
if ! tmsh load sys config merge file /config/verifyHash; then
   echo cannot validate signature of /config/verifyHash
   exit
fi 
echo  loaded verifyHash
filesToVerify="/config/cloud/f5-cloud-libs.tar.gz /config/cloud/f5-cloud-libs-azure.tar.gz /config/cloud/f5.service_discovery.tmpl"
#declare  -a filesToVerify=('/config/cloud/f5-cloud-libs.tar.gz' '/config/cloud/f5-cloud-libs-azure.tar.gz' '/config/cloud/f5.service_discovery.tmpl')
for fileToVerify in $filesToVerify
do
   echo verifying "$fileToVerify"
   if ! tmsh run cli script verifyHash "$fileToVerify"; then
       echo "$fileToVerify" is not valid
       exit 1
   fi
   echo verified "$fileToVerify"
done 
mkdir  -p /config/cloud/azure/node_modules/@f5devcentral
echo  expanding f5-cloud-libs.tar.gz\n
tar xvfz /config/cloud/f5-cloud-libs.tar.gz -C /config/cloud/azure/node_modules/@f5devcentral
echo  expanding f5-cloud-libs-azure.tar.gz
tar xvfz /config/cloud/f5-cloud-libs-azure.tar.gz -C /config/cloud/azure/node_modules/@f5devcentral
echo  cloud libs install complete
touch /config/cloud/cloudLibsReady
EOF

curl -s -f --retry 20 -o /config/cloud/f5-cloud-libs.tar.gz https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs/v4.13.5/f5-cloud-libs.tar.gz
curl -s -f --retry 20 -o /config/cloud/f5-cloud-libs-azure.tar.gz https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs-azure/v2.12.0/f5-cloud-libs-azure.tar.gz
curl -s -f --retry 20 -o /config/cloud/f5.service_discovery.tmpl https://cdn.f5.com/product/cloudsolutions/iapps/common/f5-service-discovery/v2.3.2/f5.service_discovery.tmpl

chmod 755 /config/verifyHash
chmod 755 /config/installCloudLibs.sh
mkdir  -p /var/log/cloud/azure
touch /config/cloud/azure/FIRST_BOOT_COMPLETE
nohup /config/installCloudLibs.sh >> /var/log/cloud/azure/install.log < /dev/null

# download latest atc tools
toolsList=$(cat -<<EOF
{
  "tools": [
      {
        "name": "f5-declarative-onboarding",
        "version": "${doVersion}",
        "url": "${doExternalDeclarationUrl}"
      },
      {
        "name": "f5-appsvcs-extension",
        "version": "${as3Version}",
        "url": "${as3ExternalDeclarationUrl}"
      },
      {
        "name": "f5-telemetry-streaming",
        "version": "${tsVersion}",
        "url": "${tsExternalDeclarationUrl}"
      },
      {
        "name": "f5-cloud-failover-extension",
        "version": "${cfVersion}",
        "url": "${cfExternalDeclarationUrl}"
      }
  ]
}
EOF
)
function getAtc () {
atc=$(echo $toolsList | jq -r .tools[].name)
for tool in $atc
do
    version=$(echo $toolsList | jq -r ".tools[]| select(.name| contains (\"$tool\")).version")
    if [ $version == "latest" ]; then
        path=''
    else
        path='tags/v'
    fi
    echo "downloading $tool, $version"
    if [ $tool == "f5-cloud-failover-extension" ]; then
        files=$(/usr/bin/curl -sk --interface mgmt https://api.github.com/repos/f5devcentral/$tool/releases/$path$version | jq -r '.assets[] | select(.name | contains (".rpm")) | .browser_download_url')
    else
        files=$(/usr/bin/curl -sk --interface mgmt https://api.github.com/repos/F5Networks/$tool/releases/$path$version | jq -r '.assets[] | select(.name | contains (".rpm")) | .browser_download_url')
    fi
    for file in $files
    do
    echo "download: $file"
    name=$(basename $file )
    # make download dir
    mkdir -p /var/config/rest/downloads
    result=$(/usr/bin/curl -Lsk  $file -o /var/config/rest/downloads/$name)
    done
done
}
getAtc

# install atc tools
rpms=$(find $rpmFilePath -name "*.rpm" -type f)
for rpm in $rpms
do
  filename=$(basename $rpm)
  echo "installing $filename"
  if [ -f $rpmFilePath/$filename ]; then
     postBody="{\"operation\":\"INSTALL\",\"packageFilePath\":\"$rpmFilePath/$filename\"}"
     while true
     do
        iappApiStatus=$(curl -i -u $CREDS  http://localhost:8100$rpmInstallUrl | grep HTTP | awk '{print $2}')
        case $iappApiStatus in 
            404)
                echo "api not ready status: $iappApiStatus"
                sleep 2
                ;;
            200)
                echo "api ready starting install task $filename"
                install=$(restcurl -u $CREDS -X POST -d $postBody $rpmInstallUrl | jq -r .id )
                break
                ;;
              *)
                echo "other error status: $iappApiStatus"
                debug=$(restcurl -u $CREDS $rpmInstallUrl)
                echo "ipp install debug: $debug"
                ;;
        esac
    done
  else
    echo " file: $filename not found"
  fi 
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
            debug=$(restcurl -u $CREDS $rpmInstallUrl/$install | jq . )
            echo "failed $filename task: $install error: $debug"
            ;;
        esac
    sleep 2
    done
done
function getDoStatus() {
    task=$1
    doStatusType=$(restcurl -u $CREDS -X GET $doTaskUrl/$task | jq -r type )
    if [ "$doStatusType" == "object" ]; then
        doStatus=$(restcurl -u $CREDS -X GET $doTaskUrl/$task | jq -r .result.status)
        echo $doStatus
    elif [ "$doStatusType" == "array" ]; then
        doStatus=$(restcurl -u $CREDS -X GET $doTaskUrl/$task | jq -r .[].result.status)
        echo $doStatus
    else
        echo "unknown type:$doStatusType"
    fi
}
function checkDO() {
    # Check DO Ready
    count=0
    while [ $count -le 4 ]
    do
    #doStatus=$(curl -i -u $CREDS http://localhost:8100$doCheckUrl | grep HTTP | awk '{print $2}')
    doStatusType=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r type )
    if [ "$doStatusType" == "object" ]; then
        doStatus=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .code)
        if [ $? == 1 ]; then
            doStatus=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .result.code)
        fi
    elif [ "$doStatusType" == "array" ]; then
        doStatus=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .[].result.code)
    else
        echo "unknown type:$doStatusType"
    fi
    echo "status $doStatus"
    if [[ $doStatus == "200" ]]; then
        #version=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .version)
        version=$(restcurl -u $CREDS -X GET $doCheckUrl | jq -r .[].version)
        echo "Declarative Onboarding $version online "
        break
    elif [[ $doStatus == "404" ]]; then
        echo "DO Status: $doStatus"
        bigstart restart restnoded
        sleep 60
        bigstart status restnoded | grep running
        status=$?
        echo "restnoded:$status"
    else
        echo "DO Status $doStatus"
        count=$[$count+1]
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
function checkAS3() {
    # Check AS3 Ready
    count=0
    while [ $count -le 4 ]
    do
    #as3Status=$(curl -i -u $CREDS http://localhost:8100$as3CheckUrl | grep HTTP | awk '{print $2}')
    as3Status=$(restcurl -u $CREDS -X GET $as3CheckUrl | jq -r .code)
    if  [ "$as3Status" == "null" ] || [ -z "$as3Status" ]; then
        type=$(restcurl -u $CREDS -X GET $as3CheckUrl | jq -r type )
        if [ "$type" == "object" ]; then
            as3Status="200"
        fi
    fi
    if [[ $as3Status == "200" ]]; then
        version=$(restcurl -u $CREDS -X GET $as3CheckUrl | jq -r .version)
        echo "As3 $version online "
        break
    elif [[ $as3Status == "404" ]]; then
        echo "AS3 Status $as3Status"
        bigstart restart restnoded
        sleep 60
        bigstart status restnoded | grep running
        status=$?
        echo "restnoded:$status"
    else
        echo "AS3 Status $as3Status"
        count=$[$count+1]
    fi
    sleep 10
    done
}
function checkTS() {
    # Check TS Ready
    count=0
    while [ $count -le 4 ]
    do
    tsStatus=$(curl -si -u $CREDS http://localhost:8100$tsCheckUrl | grep HTTP | awk '{print $2}')
    if [[ $tsStatus == "200" ]]; then
        version=$(restcurl -u $CREDS -X GET $tsCheckUrl | jq -r .version)
        echo "Telemetry Streaming $version online "
        break
    else
        echo "TS Status $tsStatus"
        count=$[$count+1]
    fi
    sleep 10
    done
}
function checkCF() {
    # Check CF Ready
    count=0
    while [ $count -le 4 ]
    do
    cfStatus=$(curl -si -u $CREDS http://localhost:8100$cfCheckUrl | grep HTTP | awk '{print $2}')
    if [[ $cfStatus == "200" ]]; then
        version=$(restcurl -u $CREDS -X GET $cfCheckUrl | jq -r .version)
        echo "Cloud failover $version online "
        break
    else
        echo "Cloud Failover Status $tsStatus"
        count=$[$count+1]
    fi
    sleep 10
    done
}
function runDO() {
    count=0
    while [ $count -le 4 ]
        do 
        # make task
        task=$(curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST http://localhost:8100$doUrl -d @/config/$1 | jq -r .id)
        taskId=$(echo $task)
        echo "starting DO task: $taskId"
        sleep 1
        count=$[$count+1]
        # check task code
        while true
        do
            code=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .code)
            sleep 1
            if  [ "$code" == "null" ] || [ -z "$code" ]; then
                status=$(restcurl -u $CREDS /mgmt/shared/declarative-onboarding/task/$task | jq -r .result.status)
                sleep 1
                # 200,202,422,400,404,500
                echo "DO: $task response:$code"
                sleep 1
                status=$(getDoStatus $taskId)
                sleep 1
                #FINISHED,STARTED,RUNNING,ROLLING_BACK,FAILED,ERROR,NULL
                case $status in 
                FINISHED)
                    # finished
                    echo " $taskId status: $status "
                    # bigstart start dhclient
                    break 2
                    ;;
                STARTED)
                    # started
                    echo " $filename status: $status "
                    sleep 30
                    ;;
                RUNNING)
                    # running
                    echo "DO Status: $status task: $taskId Not done yet..."
                    sleep 30
                    ;;
                FAILED)
                    # failed
                    error=$(getDoStatus $taskId)
                    echo "failed $taskId, $error"
                    #count=$[$count+1]
                    break
                    ;;
                ERROR)
                    # error
                    error=$(getDoStatus $taskId)
                    echo "Error $taskId, $error"
                    #count=$[$count+1]
                    break
                    ;;
                ROLLING_BACK)
                    # Rolling back
                    echo "Rolling back failed status: $status task: $taskId"
                    break
                    ;;
                OK)
                    # complete no change
                    echo "Complete no change status: $status task: $taskId"
                    break 2
                    ;;
                *)
                    # other
                    echo "other: $status"
                    debug=$(restcurl -u $CREDS $doTaskUrl/$taskId | jq .)
                    echo "debug: $debug"
                    error=$(getDoStatus $taskId)
                    echo "Other $taskId, $error"
                    # count=$[$count+1]
                    sleep 30
                    ;;
                esac
            else
                echo "DO status code: $code"
                debug=$(restcurl -u $CREDS $doTaskUrl/$taskId | jq .)
                echo "debug do code: $debug"
                # count=$[$count+1]
            fi
        done
    done
}
# mgmt
echo "set management"
echo  -e "create cli transaction;
modify sys global-settings mgmt-dhcp disabled;
submit cli transaction" | tmsh -q
tmsh save /sys config

# run DO
count=0
while [ $count -le 4 ]
    do
        doStatus=$(checkDO)
        echo "DO check status: $doStatus"
    if [ $deviceId == 1 ] && [[ "$doStatus" = *"online"* ]]; then 
        echo "running do for id:$deviceId"
        bigstart stop dhclient
        runDO do1.json
        if [ "$?" == 0 ]; then
            echo "done with do"
            bigstart start dhclient
            results=$(restcurl -u $CREDS -X GET $doTaskUrl | jq '.[] | .id, .result')
            echo "do results: $results"
            break
        fi
    elif [ $deviceId == 2 ] && [[ "$doStatus" = *"online"* ]]; then 
        echo "running do for id:$deviceId"
        bigstart stop dhclient
        runDO do2.json
        if [ "$?" == 0 ]; then
            echo "done with do"
            bigstart start dhclient
            results=$(restcurl -u $CREDS -X GET $doTaskUrl | jq '.[] | .id, .result')
            echo "do results: $results"
            break
        fi
    elif [ $count -le 2 ]; then
        echo "Status code: $doStatus  DO not ready yet..."
        count=$[$count+1]
        sleep 30
    else
        echo "DO not online status: $doStatus"
        break
    fi
done
function runAS3 () {
    count=0
    while [ $count -le 1 ]
        do
            # make task
            task=$(curl -s -u $CREDS -H "Content-Type: Application/json" -H 'Expect:' -X POST http://localhost:8100$as3Url?async=true -d @/config/as3.json | jq -r .id)
            taskId=$(echo $task)
            echo "starting as3 task: $taskId"
            sleep 1
            count=$[$count+1]
            # check task code
        while true
        do
            #status=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$taskId | jq -r '.results[].message')
            # some weirdness with rest curl
            #   {
            #     "code": 200,
            #     "message": "success",
            #     "lineCount": 19,
            #     "host": "localhost",
            #     "tenant": "Common",
            #     "runTime": 15532
            #   }
            # get values
            status=$(restcurl -s -u $CREDS $as3TaskUrl/$taskId | jq ".items[] | select(.id | contains (\"$taskId\")) | .results")
            # codes=$(echo "$status" | jq .[].code)
            messages=$(echo "$status" | jq -r .[].message)
            tenants=$(echo "$status" | jq .[].tenant)
            # # push to arrays
            # codesArray=()
            # for code in $codes;do
            #     codesArray+=($code)
            # done
            # messagesArray=()
            # for message in $messages;do
            #     echo "$message"
            #     messagesArray+=($message)
            # done
            # tenantsArray=()
            # for tenant in $tenants;do
            #     tenantsArray+=($tenant)
            # done
            # # check responses
            # n=0
            # for code in $codesArray;do
            #     if [[ $code = "200" ]]; then
            #         echo $code, $tenantsArray,$messagesArray
            #         n=$[$n+1]
            #     else
            #         echo $code, $tenantsArray,$messagesArray
            #         #break 2
            #         n=$[$n+1]
            #     fi
            # done
            # unset n
            case $messages in
            *Error*)
                # error
                echo -e "Error: $taskId status: $messages tenants: $tenants "
                break
                ;;
            *failed*)
                # failed
                echo -e "failed: $taskId status: $messages tenants: $tenants "
                break
                ;;
            *success*)
                # successful!
                echo -e "success: $taskId status: $messages tenants: $tenants "
                break 3
                ;;
            no*change)
                # finished
                echo -e "no change: $taskId status: $messages tenants: $tenants "
                break 3
                ;;
            in*progress)
                # in progress
                echo -e "Running: $taskId status: $messages tenants: $tenants "
                sleep 60
                ;;
            *)
            # other
            echo "status: $messages"
            debug=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$taskId | jq .)
            echo "debug: $debug"
            error=$(curl -s -u $CREDS http://localhost:8100/mgmt/shared/appsvcs/task/$taskId | jq -r '.results[].message')
            echo "Other: $taskId, $error"
            ;;
            esac
        done
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

#  run as3
count=0
while [ $count -le 4 ]
do
    as3Status=$(checkAS3)
    echo "AS3 check status: $as3Status"
    if [[ $as3Status == *"online"* ]]; then
        if [ $deviceId == 1 ]; then
            echo "running as3"
            runAS3
            echo "done with as3"
            results=$(restcurl -u $CREDS $as3TaskUrl | jq '.items[] | .id, .results')
            echo "as3 results: $results"
            break
        else
            echo "Not posting as3 device $deviceid not primary"
            break
        fi
    elif [ $count -le 2 ]; then
        echo "Status code: $as3Status  As3 not ready yet..."
        count=$[$count+1]
    else
        echo "As3 API Status $as3Status"
        break
    fi
done
#
#
# cleanup
## remove declarations
# rm -f /config/do1.json
# rm -f /config/do2.json
# rm -f /config/as3.json
## disable/replace default admin account
# echo  -e "create cli transaction;
# modify /sys db systemauth.primaryadminuser value $admin_username;
# submit cli transaction" | tmsh -q
tmsh save sys config
echo "timestamp end: $(date)"
echo "setup complete $(timer "$(($(date +%s) - $startTime))")"
#!/bin/bash

source 'auth.cfg with token(s)'

repoName=$1
repoRelease=$2
region=$3
env=$4
repoNameTrim=`echo $repoName | cut -d':' -f2 | cut -d'/' -f2 | sed 's/.git//g'`
repoOwner=`echo $repoName | cut -d':' -f2 | cut -d'/' -f1`
logDir='log directory here'

payload_root='query RepoFiles{
repository(owner: \"'$repoOwner'\", name: \"'$repoNameTrim'\") {
 object(expression: \"'$repoRelease':create/aws/\") {
   ... on Tree {
     entries {
       name
        }
      }
    }
  }
}'

payloadFrmt_root="$(echo $payload_root)"

payload='query RepoFiles{
repository(owner: \"'$repoOwner'\", name: \"'$repoNameTrim'\") {
 object(expression: \"'$repoRelease':create/aws/'$region'/'$env'/\") {
   ... on Tree {
     entries {
       name
        }
      }
    }
  }
}'

payloadFrmt="$(echo $payload)"

logretention=20
loglist=$(ls -l $logDir/multiselect_json_create/logs/ | grep .log | awk '{print $9}' | wc -l)

if [ ! -d $logDir/multiselect_json_create/logs ]; then
  mkdir $logDir/multiselect_json_create/logs
fi

if [ $loglist -gt $logretention ]
then

 delcount=`expr $loglist - $logretention`
 find $logDir/multiselect_json_create/logs/ -type f -printf '%T+ %p\n' | sort | head -n $delcount | awk '{print $2}' | sed 's/[^\]*logs[^\]//' | xargs -I {} rm $logDir/multiselect_json_create/logs/{}

fi

##curl root create/aws dir and check for jsons
display_root=`curl \
-s -H "Authorization: bearer $authToken" \
-X POST -d "{ \"query\": \"$payloadFrmt_root\"}" https://api.github.com/graphql \
| jq -r -e '.data.repository.object.entries[].name' 2> /dev/null | grep .json`

##curl via dynamic dir variables
display_dyn=`curl \
-s -H "Authorization: bearer $authToken" \
-X POST -d "{ \"query\": \"$payloadFrmt\"}" https://api.github.com/graphql \
| jq -r -e '.data.repository.object.entries[].name' 2> /dev/null | grep .json`

if [ ! -z "$display_root" ]; then echo "$display_root"; else echo "$display_dyn"; fi

exitStatus=$?

if [ $exitStatus -ne 0 ] 
then
 
 timestamp=$(date +"%FT%H%M%S")

 curl -s -I \
 -H "Authorization: bearer $authToken" \
 https://api.github.factset.com/graphql > /'add directory here'/multiselect_json_create/logs/cURLheader_$timestamp.log

else

exit 0

fi


#!/bin/bash

#Set variables
#Domoticz Server Settings
domoticzserver="*******************"
domoticzusername="**********************"
domoticzpassword="**********************"
username360="*********************"
password360="*********************"

function bearer {
echo "$(date +%s) INFO: requesting access token"
bearer_id=$(curl -s -X POST -H "Authorization: Basic cFJFcXVnYWJSZXRyZTRFc3RldGhlcnVmcmVQdW1hbUV4dWNyRUh1YzptM2ZydXBSZXRSZXN3ZXJFQ2hBUHJFOTZxYWtFZHI0Vg==" -F "grant_type=password" -F "username=$username360" -F "password=$password360" https://api.life360.com/v3/oauth2/token.json | grep -Po '(?<="access_token":")\w*')
}

function circles () {
echo "$(date +%s) INFO: requesting circles."
read -a circles_id <<<$(curl -s -X GET -H "Authorization: Bearer $1" https://api.life360.com/v3/circles.json | grep -Po '(?<="id":")[\w-]*')
}

function members () {
members=$(curl -s -X GET -H "Authorization: Bearer $1" https://api.life360.com/v3/circles/$2)
echo "$(date +%s) INFO: requesting members"
#echo $members
}

function domoticzrequest () {
#echo $(curl -s -u domoticzusername:domoticzpassword -X GET $1)
domoticzmessage=$(curl -s -u domoticzusername:domoticzpassword -X GET $1)
}

bearer
circles $bearer_id

#Main Loop
#while :
#do

#Check if circle id is valid. If not request new token.
if [ -z "$circles_id" ]; then
bearer
circles $bearer_id
fi

#Loop through circle ids
for i in "${circles_id[0]}" # @ isareti 0 yapildi sadece Family grubu olsun diye
do

#request member list
members $bearer_id $i

#Check if member array is valid. If not request new token
if [ -z "$members" ]; then
bearer
circles $bearer_id
members $bearer_id $i
fi

members_id=$(echo $members | jq '.members[].id')
IFS=$'\n' read -rd '' -a members_array <<<"$members_id"
count=0
for i in "${members_array[@]}"
do
    firstName=$(echo $members | jq .members[$count].firstName)
    lastName=$(echo $members | jq .members[$count].lastName)
    latitude=$(echo $members | jq .members[$count].location.latitude)
    longitude=$(echo $members | jq .members[$count].location.longitude)
    accuracy=$(echo $members | jq .members[$count].location.accuracy)
    battery=$(echo $members | jq .members[$count].location.battery)
    locationname=$(echo $members | jq .members[$count].location.name)
	echo $firstName . " is " . $locationname
	if [ "$locationname" = "\"Thuis"\" ]; then 
		locationname="On"
    else
		locationname="Off"
    fi
#	echo "$locationname"	
#	echo "$firstName"	
# Change your name here to Life360 Full First name
	if [ "$firstName" = "\"Ron"\" ]; then 
	#Change the following XX to IDX of your Edwin_Presence Switch
	    passaddress="http://$domoticzserver/json.htm?type=command&param=switchlight&idx=30&switchcmd=$locationname"
	    checkaddress="http://$domoticzserver/json.htm?type=devices&rid=30"
	echo "Ron Thuis"
	fi	
	if [ "$firstName" = "\"Bianca"\" ]; then 
	#Change the following XX to IDX of your Edwin_Presence Switch
	    passaddress="http://$domoticzserver/json.htm?type=command&param=switchlight&idx=29&switchcmd=$locationname"
	    checkaddress="http://$domoticzserver/json.htm?type=devices&rid=29"
	echo "Bianca Thuis"
	fi

  domoticzrequest $checkaddress
	#echo "parse result" . $domoticzmessage
  presence_status=$(jq -r '.result[0].Data' <<< "$domoticzmessage")	
	#echo $checkaddress
	echo $presence_status . $locationname

  if [ "$locationname" != "$presence_status" ]; then
      echo $presence_status
      domoticzrequest $passaddress
  fi
	count=$(($count+1))
done
done
#sleep $timeout
#done

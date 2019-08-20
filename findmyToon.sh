#!/usr/bin/env bash
### BEGIN INFO
# Description:       This script will find a device by its mac address and update the UV accordingly
### END INFO

# Do NOT "set -e"

#Crontab schedule
#*/5 * * * * /home/pi/findToon.sh > /home/pi/findToon.log

#OudeToon (staat nu op zolder)
#toonMAC=6c:71:d9:3c:29:4e 
#NieuweToon
toonMAC="74:c6:3b:50:4a:eb"
UVToonIP="UV_ToonIP"



SUBNET=$(ip route show | awk '/24 dev/ {print $1}' | head -n1)

printf "Scanning subnet $SUBNET...\n"
#Scan entire subnet
nmap $SUBNET -sn -sC 

sleep 20
#fetch arp table and insert IP into variable
toonIP=$(arp -n | grep ${toonMAC} | awk '{print $1}')

printf "For MAC $toonMAC I've found the ip $toonIP\n"
printf "Setting variable using curl http://192.168.0.90:10080/json.htm?type=command&param=updateuservariable&vname=${UVToonIP}&vtype=2&vvalue=${toonIP}`n`"

curl "http://192.168.0.90:10080/json.htm?type=command&param=updateuservariable&vname=${UVToonIP}&vtype=2&vvalue=${toonIP}"

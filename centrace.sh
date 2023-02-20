#!/bin/sh

#Filename:    centrace.sh
#Description: Shell script to run traceroute and then pcap analyser scripts provided by centrace
#             Prerequisties:-
#             sudo -s
#             source ./venv/bin/activate
#              
#Author:      21030005@lums.edu.pk

if [ $# -lt 3 ]
then
  echo "Please check arguments: <censored domain> <uncensored domain> <remote endpoint>"
  exit 1
fi

CENSORED_DOMAIN=$1
UNCENSORED_DOMAIN=$2
REMOTE_ENDPOINT=$3
HTTPS=$4

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
DIRECTORY_NAME="Test_"$CENSORED_DOMAIN"_"$UNCENSORED_DOMAIN"_"$REMOTE_ENDPOINT"_"$DATE



echo "Creating testing directory"
mkdir $DIRECTORY_NAME

echo "Executing traceroute.py"
python traceroute.py -c $CENSORED_DOMAIN -u $UNCENSORED_DOMAIN -s $REMOTE_ENDPOINT -p -pd $DIRECTORY_NAME/ -o $DIRECTORY_NAME/traceroute_output.csv -rv pyasn_utils/ipasn_db_file -an pyasn_utils/asn_file.json -q --iprr -l $DIRECTORY_NAME/log.txt -r 5 -R 120 -m 2 $HTTPS -cr 2 -mi 3 -v 

if [ $? -ne 0 ]
then
  echo "traceroute.py failed, check log"
  exit 1
fi

echo "Executing pcap_parse.py"
python pcap_parse.py --dir ./$DIRECTORY_NAME/ -rv pyasn_utils/ipasn_db_file -an pyasn_utils/asn_file.json -o ./$DIRECTORY_NAME/pcap_output.csv --summary

if [ $? -ne 0 ]
then
  echo "pcap_parse.py failed, check log"
  exit 1
fi

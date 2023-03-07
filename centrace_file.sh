#!/bin/sh

#Filename:    centrace.sh
#Description: Shell script to run traceroute and then pcap analyser scripts provided by centrace
#             Prerequisties:-
#             sudo -s
#             source ./venv/bin/activate
#              
#Author:      21030005@lums.edu.pk

if [ $# -lt 1 ]
then
  echo "Please check arguments: <input file name>"
  exit 1
fi

INPUT_FILE=$1
HTTPS=$2

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
DIRECTORY_NAME="Test_"$DATE


echo "Flushing iptables"
iptables -F
echo "Droping outbound packets with RST flag set"
iptables -A OUTPUT -p tcp --tcp-flags ALL RST -j DROP
echo "Droping outbound packets with RST and ACK flags set"
iptables -A OUTPUT -p tcp --tcp-flags ALL RST,ACK -j DROP

#iptables -L -v

echo "Creating testing directory"
mkdir $DIRECTORY_NAME

echo "Executing traceroute.py"
python traceroute.py -f $INPUT_FILE -p -pd $DIRECTORY_NAME/ -o $DIRECTORY_NAME/traceroute_output.csv -rv pyasn_utils/ipasn_db_file -an pyasn_utils/asn_file.json -q -l $DIRECTORY_NAME/log.txt -r 5 -R 120 -m 2 $HTTPS -cr 5 -mi 11 -v 

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

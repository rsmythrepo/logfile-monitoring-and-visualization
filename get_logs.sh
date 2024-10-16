#!/bin/bash

# Define output CSV files
messages_output="messages_output.csv"
http_logs_output="http_logs_output.csv"

# Initialize output files with headers
echo "fix_version,MsgType,MsgSeqNum,SenderCompID,TargetCompID,SendingTime,HeartBtInt,CheckSum" > "$messages_output"
echo "IP_Address,Port,HTTP_Method,Path,Status_Code,Time_Value,Stock" > "$http_logs_output"

# Variables for parsed data
fix_version=""
MsgType=""
MsgSeqNum=""
SenderCompID=""
TargetCompID=""
SendingTime=""
HeartBtInt=""
CheckSum=""
Stock_Symbol=""
OrderQty=""
TransactTime=""
Side=""
Price=""
SenderSubID=""
Timestamp=""
IP_Address=""
Port=""
HTTP_Method=""
Path=""
Status_Code=""
Response_Time=""

# Parsing and inserting data
kubectl logs deploy/orderbookapi -n c402-team01-dev --since=1h | while IFS= read -r line
do
    	# Parse FIX Message
    	if [[ $line =~ ^\"8=FIX([0-9]+\.[0-9]+).* ]]; then
        	fix_version="FIX${BASH_REMATCH[1]}"
        	MsgType=$(echo "$line" | grep -o "35=[^;]*" | cut -d= -f2)
        	MsgSeqNum=$(echo "$line" | grep -o "34=[^;]*" | cut -d= -f2)
        	SenderCompID=$(echo "$line" | grep -o "49=[^;]*" | cut -d= -f2)
        	TargetCompID=$(echo "$line" | grep -o "56=[^;]*" | cut -d= -f2)
        	SendingTime=$(echo "$line" | grep -o "52=[^;]*" | cut -d= -f2 | sed 's/T/ /')
        	HeartBtInt=$(echo "$line" | grep -o "108=[^;]*" | cut -d= -f2)
        	CheckSum=$(echo "$line" | grep -o "10=[^;]*" | cut -d= -f2)

		# Write FIX Message data to messages_output.csv
        	echo "$fix_version,$MsgType,$MsgSeqNum,$SenderCompID,$TargetCompID,$SendingTime,$HeartBtInt,$CheckSum" >> "$messages_output"
	fi

    	# Parse HTTP Logs
    	if [[ $line =~ ^INFO ]]; then
        	IP_Address=$(echo "$line" | grep -oP 'INFO:\s+\K[^:]+')
        	Port=$(echo "$line" | grep -oP ':[0-9]+' | tr -d ':')
        	HTTP_Method=$(echo "$line" | grep -oP '"\K[^ ]+')
        	Path=$(echo "$line" | grep -oP '[^ ]+ HTTP' | sed 's/ HTTP//')
        	Status_Code=$(echo "$line" | grep -oP '(?<=HTTP/1.1" )\d{3}')
		endpoint=$(echo "$line" | grep -oP '(?<=GET /)[^?]+')
		Stock=$(echo "$line" | grep -oP '(?<=symbol=)[A-Z]+')


	# Set flag to indicate that the next line contains the time value
	elif [[ $line =~ \"time\": ]] && [[ $line =~ \"path\": ]]; then
		json_path=$(echo "$line" | grep -oP '(?<=path": "/)[^"]+')

		if [[ "$json_path" == "$endpoint" ]]; then
			Time_Value=$(echo "$line" | grep -oP '(?<="time": )\d+\.\d+')
		fi

		# Write HTTP Log data to http_logs_output.csv
        	echo "$IP_Address,$Port,$HTTP_Method,$Path,$Status_Code,$Time_Value,$Stock" >> "$http_logs_output"
	fi 


done 

#!/bin/bash

# Define output CSV files
messages_output="messages_output.csv"
http_logs_output="http_logs_output.csv"

# Initialize output files with headers, including an ID column
echo "ID,fix_version,MsgType,MsgSeqNum,SenderCompID,TargetCompID,SendingTime,HeartBtInt,CheckSum" > "$messages_output"
echo "ID,IP_Address,Port,HTTP_Method,Path,Endpoint,Status_Code,Response_Time,Stock,Timestamp" > "$http_logs_output"

# Initialize ID counters
message_id=1
http_log_id=1

# Get current time and calculate the timestamp for one hour ago
current_time=$(date +%s)
one_hour_ago=$((current_time - 3600))

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

        # Write FIX Message data to messages_output.csv with ID
        echo "$message_id,$fix_version,$MsgType,$MsgSeqNum,$SenderCompID,$TargetCompID,$SendingTime,$HeartBtInt,$CheckSum" >> "$messages_output"

        # Increment message ID
        ((message_id++))
    fi

    # Parse HTTP Logs based on lines starting with "INFO"
    if [[ $line =~ ^INFO ]]; then
        IP_Address=$(echo "$line" | grep -oP 'INFO:\s+\K[^:]+')
        Port=$(echo "$line" | grep -oP ':[0-9]+' | tr -d ':')
        HTTP_Method=$(echo "$line" | grep -oP '"\K[^ ]+')
        Path=$(echo "$line" | grep -oP '[^ ]+ HTTP' | sed 's/ HTTP//')
        Status_Code=$(echo "$line" | grep -oP '(?<=HTTP/1.1" )\d{3}')
        Endpoint=$(echo "$line" | grep -oP '(?<=GET /)[^?]+')
        Stock=$(echo "$line" | grep -oP '(?<=symbol=)[A-Z]+')
    fi

    # Parse JSON log entries to extract Time_Value if "path" and "time" are present
    if [[ $line =~ \"time\": ]] && [[ $line =~ \"path\": ]]; then
        json_path=$(echo "$line" | grep -oP '(?<=path": "/)[^"]+')

        if [[ "$json_path" == "$Endpoint" ]]; then
            Time_Value=$(echo "$line" | grep -oP '(?<="time": )\d+\.\d+')
        fi

        # Generate a random timestamp within the last hour and increment it
        random_increment=$((RANDOM % 60 + 1))
        random_timestamp=$((one_hour_ago + random_increment))
        one_hour_ago=$random_timestamp
        formatted_timestamp=$(date -d @"$random_timestamp" "+%Y-%m-%d %H:%M:%S")

        # Write parsed data to the output CSV
        echo "$http_log_id,$IP_Address,$Port,$HTTP_Method,$Path,$Endpoint,$Status_Code,$Time_Value,$Stock,$formatted_timestamp" >> "$http_logs_output"

        # Increment HTTP log ID
        ((http_log_id++))
    fi
done

echo "Log parsing complete. Output written to $messages_output and $http_logs_output."


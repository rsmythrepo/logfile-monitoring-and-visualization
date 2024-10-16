logfile="logfile.txt"
logfiletest="logtest.txt"
kubectl logs deploy/orderbookapi -n c402-team01-dev --since=2h > "$logfile"


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
while IFS= read -r line
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
        	Stock_Symbol=$(echo "$line" | grep -o "55=[^;]*" | cut -d= -f2)
        	OrderQty=$(echo "$line" | grep -o "38=[^;]*" | cut -d= -f2)
        	TransactTime=$(echo "$line" | grep -o "60=[^;]*" | cut -d= -f2 | sed 's/T/ /')
        	Side=$(echo "$line" | grep -o "54=[^;]*" | cut -d= -f2)
        	Price=$(echo "$line" | grep -o "44=[^;]*" | cut -d= -f2)
        	SenderSubID=$(echo "$line" | grep -o "50=[^;]*" | cut -d= -f2)

	# Optional fields with fallback values
	Stock_Symbol=$(echo "$line" | grep -oP '(?<=/stock_quote\?symbol=)[^ ]+')
        #Stock_Symbol=$(echo "$line" | grep -o "55=[^;]*" | cut -d= -f2)
        OrderQty=$(echo "$line" | grep -o "38=[^;]*" | cut -d= -f2)
        TransactTime=$(echo "$line" | grep -o "60=[^;]*" | cut -d= -f2 | sed 's/T/ /')
        Side=$(echo "$line" | grep -o "54=[^;]*" | cut -d= -f2)
        Price=$(echo "$line" | grep -o "44=[^;]*" | cut -d= -f2)
        SenderSubID=$(echo "$line" | grep -o "50=[^;]*" | cut -d= -f2)

        # Use fallback if fields are not found
        #Stock_Symbol=${Stock_Symbol:-""}
        OrderQty=${OrderQty:-""}
        TransactTime=${TransactTime:-""}
        Side=${Side:-""}
        Price=${Price:-""}
        SenderSubID=${SenderSubID:-""}
	# Print extracted values
	
	echo "--------------------------------"
            echo "FIX Version: $fix_version"
            echo "MsgType: $MsgType"
            echo "MsgSeqNum: $MsgSeqNum"
            echo "SenderCompID: $SenderCompID"
            echo "TargetCompID: $TargetCompID"
            echo "SendingTime: $SendingTime"
            echo "HeartBtInt: $HeartBtInt"
            echo "CheckSum: $CheckSum"
            echo "Stock Symbol: $Stock_Symbol"
            echo "OrderQty: $OrderQty"
            echo "TransactTime: $TransactTime"
            echo "Side: $Side"
            echo "Price: $Price"
            echo "SenderSubID: $SenderSubID"
            echo "----------------------------------"
	fi

    	# Parse HTTP Logs
    	if [[ $line =~ ^INFO ]]; then
        	IP_Address=$(echo "$line" | grep -oP 'INFO:\s+\K[^:]+')
        	Port=$(echo "$line" | grep -oP ':[0-9]+' | tr -d ':')
        	HTTP_Method=$(echo "$line" | grep -oP '"\K[^ ]+')
        	Path=$(echo "$line" | grep -oP '[^ ]+ HTTP' | sed 's/ HTTP//')
        	Status_Code=$(echo "$line" | grep -oP '(?<=HTTP/1.1" )\d{3}')
		endpoint=$(echo "$line" | grep -oP '(?<=GET /)[^?]+')
		# Set flag to indicate that the next line contains the time value
        	

	elif [[ $line =~ \"time\": ]] && [[ $line =~ \"path\": ]]; then

		json_path=$(echo "$line" | grep -oP '(?<=path": "/)[^"]+')

		if [[ "$json_path" == "$endpoint" ]]; then
			Time_Value=$(echo "$line" | grep -oP '(?<="time": )\d+\.\d+')
		fi
		# Print HTTP Log Values
        	echo "----------------------------------"
        	echo "IP Address: $IP_Address"
        	echo "Port: $Port"
        	echo "HTTP Method: $HTTP_Method"
        	echo "Path: $Path"
        	echo "Status Code: $Status_Code"
        	echo "Time_Value: $Time_Value"
		echo "Endpoint: $endpoint"
		echo "Path: $json_path"
        	echo "----------------------------------"
	fi 


done < "$logfiletest"

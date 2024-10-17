#!/bin/bash

# Set MySQL credentials
DB_CONTAINER_NAME="mysql9_project3"
DB_NAME="fix_data"
DB_USER="root"
DB_PASSWORD="root"

# Define CSV file paths
HTTP_LOGS_CSV="http_logs_output.csv"
MESSAGES_CSV="messages_output.csv"

# Function to insert HTTP logs into the database
insert_http_logs() {
    echo "Inserting HTTP logs into the database..."
    
    # Read the CSV file and skip the header
    tail -n +2 "$HTTP_LOGS_CSV" | while IFS=',' read -r IP_Address Port HTTP_Method Path Status_Code Time_Value Stock; do
        # Prepare and execute the insert statement
        docker exec -i "$DB_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" <<EOF
        INSERT INTO HTTP_Log (Timestamp, IP_Address, Port, HTTP_Method, Path, Status_Code, Response_Time, Stock_Symbol)
        VALUES (NOW(), '$IP_Address', $Port, '$HTTP_Method', '$Path', '$Status_Code', ${Time_Value:-NULL}, '${Stock:-NULL}');
EOF
        echo "Inserted: $IP_Address, $Port, $HTTP_Method, $Path, $Status_Code, $Time_Value, $Stock"
    done
}

# Function to insert messages into the database
insert_messages() {
    echo "Inserting messages into the database..."
    
    # Read the CSV file and skip the header
    tail -n +2 "$MESSAGES_CSV" | while IFS=',' read -r fix_version MsgType MsgSeqNum SenderCompID TargetCompID SendingTime HeartBtInt CheckSum; do
        # Prepare and execute the insert statement
        docker exec -i "$DB_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" <<EOF
        INSERT INTO Order_Message (fix_version, MsgType, MsgSeqNum, SenderCompID, TargetCompID, SendingTime, CheckSum)
        VALUES ('$fix_version', '$MsgType', $MsgSeqNum, '$SenderCompID', '$TargetCompID', '$SendingTime', '$CheckSum');
EOF
        echo "Inserted: $fix_version, $MsgType, $MsgSeqNum, $SenderCompID, $TargetCompID, $SendingTime, $CheckSum"
    done
}

# Run the insertion functions
insert_http_logs
insert_messages

echo "Data insertion complete."


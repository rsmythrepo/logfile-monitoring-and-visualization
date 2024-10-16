#!/bin/bash

# Docker MySQL configuration
MYSQL_CONTAINER_NAME="mysql_container"
DB_NAME="fix_data"
DB_USER="user"
DB_PASSWORD="password"

# Function to insert data into the Order_Message table
insert_order_message() {
    local fix_version="$1"
    local MsgType="$2"
    local MsgSeqNum="$3"
    local SenderCompID="$4"
    local TargetCompID="$5"
    local SendingTime="$6"
    local CheckSum="$7"
    local Stock_Symbol="$8"
    local OrderQty="$9"
    local TransactTime="${10}"
    local Side="${11}"
    local Price="${12}"
    local SenderSubID="${13}"

    docker exec -i "$MYSQL_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" <<EOF
    INSERT INTO Order_Message (fix_version, MsgType, MsgSeqNum, SenderCompID, TargetCompID, SendingTime, CheckSum, Stock_Symbol, OrderQty, TransactTime, Side, Price, SenderSubID)
    VALUES ('$fix_version', '$MsgType', '$MsgSeqNum', '$SenderCompID', '$TargetCompID', '$SendingTime', '$CheckSum', '$Stock_Symbol', '$OrderQty', '$TransactTime', '$Side', '$Price', '$SenderSubID');
EOF
}

# Function to insert data into the Heartbeat_Message table
insert_heartbeat_message() {
    local fix_version="$1"
    local MsgType="$2"
    local MsgSeqNum="$3"
    local SenderCompID="$4"
    local TargetCompID="$5"
    local SendingTime="$6"
    local CheckSum="$7"

    docker exec -i "$MYSQL_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" <<EOF
    INSERT INTO Heartbeat_Message (fix_version, MsgType, MsgSeqNum, SenderCompID, TargetCompID, SendingTime, CheckSum)
    VALUES ('$fix_version', '$MsgType', '$MsgSeqNum', '$SenderCompID', '$TargetCompID', '$SendingTime', '$CheckSum');
EOF
}

# Function to insert data into the HTTP_Log table
insert_http_log() {
    local IP_Address="$1"
    local Port="$2"
    local HTTP_Method="$3"
    local Path="$4"
    local Status_Code="$5"
    local Response_Time="$6"
    local Stock_Symbol="$7"

    docker exec -i "$MYSQL_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" <<EOF
    INSERT INTO HTTP_Log (IP_Address, Port, HTTP_Method, Path, Status_Code, Response_Time, Stock_Symbol)
    VALUES ('$IP_Address', '$Port', '$HTTP_Method', '$Path', '$Status_Code', '$Response_Time', '$Stock_Symbol');
EOF
}

# Function to process the Order_Message CSV file
process_order_message_csv() {
    local csv_file="$1"

    # Skip the header
    tail -n +2 "$csv_file" | while IFS=, read -r fix_version MsgType MsgSeqNum SenderCompID TargetCompID SendingTime CheckSum Stock_Symbol OrderQty TransactTime Side Price SenderSubID; do
        insert_order_message "$fix_version" "$MsgType" "$MsgSeqNum" "$SenderCompID" "$TargetCompID" "$SendingTime" "$CheckSum" "$Stock_Symbol" "$OrderQty" "$TransactTime" "$Side" "$Price" "$SenderSubID"
    done
}

# Function to process the Heartbeat_Message CSV file
process_heartbeat_message_csv() {
    local csv_file="$1"

    # Skip the header
    tail -n +2 "$csv_file" | while IFS=, read -r fix_version MsgType MsgSeqNum SenderCompID TargetCompID SendingTime CheckSum; do
        insert_heartbeat_message "$fix_version" "$MsgType" "$MsgSeqNum" "$SenderCompID" "$TargetCompID" "$SendingTime" "$CheckSum"
    done
}

# Function to process the HTTP_Log CSV file
process_http_log_csv() {
    local csv_file="$1"

    # Skip the header
    tail -n +2 "$csv_file" | while IFS=, read -r IP_Address Port HTTP_Method Path Status_Code Response_Time Stock_Symbol; do
        insert_http_log "$IP_Address" "$Port" "$HTTP_Method" "$Path" "$Status_Code" "$Response_Time" "$Stock_Symbol"
    done
}

# Main script to detect and process different CSV files automatically
process_csv_files() {
    for csv_file in *.csv; do
        case "$csv_file" in
            *order_message*.csv)
                echo "Processing Order_Message CSV: $csv_file"
                process_order_message_csv "$csv_file"
                ;;
            *heartbeat_message*.csv)
                echo "Processing Heartbeat_Message CSV: $csv_file"
                process_heartbeat_message_csv "$csv_file"
                ;;
            *http_log*.csv)
                echo "Processing HTTP_Log CSV: $csv_file"
                process_http_log_csv "$csv_file"
                ;;
            *)
                echo "Skipping unrecognized CSV file: $csv_file"
                ;;
        esac
    done
}

# Call the main function to process CSV files
process_csv_files

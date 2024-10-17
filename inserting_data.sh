#!/bin/bash

# Set MySQL credentials
DB_CONTAINER_NAME="mysql9_project3"
DB_NAME="fixdata"
DB_USER="root"
DB_PASSWORD="root"

# Function to escape special characters in SQL and handle empty values
escape_sql() {
    local value="$1"
    if [ -z "$value" ]; then
        echo "NULL"
    else
        echo "'$(echo "$value" | sed "s/'/\\\'/g")'"
    fi
}

# Insert or update data from http_logs_output.csv
echo "Inserting/updating data from http_logs_output.csv..."
while IFS=',' read -r id ip_address port http_method path endpoint status_code response_time stock timestamp
do
    # Skip the header row
    if [ "$id" != "ID" ]; then
        # Escape special characters and handle empty fields
        ip_address=$(escape_sql "$ip_address")
        port=$(escape_sql "$port")
        http_method=$(escape_sql "$http_method")
        path=$(escape_sql "$path")
        endpoint=$(escape_sql "$endpoint")
        status_code=$(escape_sql "$status_code")
        response_time=$(escape_sql "$response_time")
        stock=$(escape_sql "$stock")
        timestamp=$(escape_sql "$timestamp")

        # Insert or update HTTP_Log table
        docker exec -i "$DB_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" <<EOF
        USE $DB_NAME;
        INSERT INTO HTTP_Log (HTTP_id, IP_Address, Port, HTTP_Method, Path, Endpoint, Status_Code, Response_Time, Stock_Symbol, Timestamp)
        VALUES ($id, $ip_address, $port, $http_method, $path, $endpoint, $status_code, $response_time, $stock, $timestamp)
        ON DUPLICATE KEY UPDATE
        IP_Address = VALUES(IP_Address),
        Port = VALUES(Port),
        HTTP_Method = VALUES(HTTP_Method),
        Path = VALUES(Path),
        Endpoint = VALUES(Endpoint),
        Status_Code = VALUES(Status_Code),
        Response_Time = VALUES(Response_Time),
        Stock_Symbol = VALUES(Stock_Symbol),
        Timestamp = VALUES(Timestamp);
EOF
    fi
done < http_logs_output.csv

# Insert or update data from messages_output.csv
echo "Inserting/updating data from messages_output.csv..."
while IFS=',' read -r id fix_version msgtype msgseqnum sendercompid targetcompid sendingtime heartbtint checksum
do
    # Skip the header row
    if [ "$id" != "ID" ]; then
        # Escape special characters and handle empty fields
        fix_version=$(escape_sql "$fix_version")
        msgtype=$(escape_sql "$msgtype")
        msgseqnum=$(escape_sql "$msgseqnum")
        sendercompid=$(escape_sql "$sendercompid")
        targetcompid=$(escape_sql "$targetcompid")
        sendingtime=$(escape_sql "$sendingtime")
        heartbtint=$(escape_sql "$heartbtint")
        checksum=$(escape_sql "$checksum")

        # Insert or update Heartbeat_Message table
        docker exec -i "$DB_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" <<EOF
        USE $DB_NAME;
        INSERT INTO Heartbeat_Message (Heartbeat_id, fix_version, MsgType, MsgSeqNum, SenderCompID, TargetCompID, SendingTime, HeartBtInt, CheckSum)
        VALUES ($id, $fix_version, $msgtype, $msgseqnum, $sendercompid, $targetcompid, $sendingtime, $heartbtint, $checksum)
        ON DUPLICATE KEY UPDATE
        fix_version = VALUES(fix_version),
        MsgType = VALUES(MsgType),
        MsgSeqNum = VALUES(MsgSeqNum),
        SenderCompID = VALUES(SenderCompID),
        TargetCompID = VALUES(TargetCompID),
        SendingTime = VALUES(SendingTime),
        HeartBtInt = VALUES(HeartBtInt),
        CheckSum = VALUES(CheckSum);
EOF
    fi
done < messages_output.csv

# Insert or update data from orders_data.csv
echo "Inserting/updating data from orders_data.csv..."
while IFS=',' read -r order_id http_id transacttime side user_id
do
    # Skip the header row
    if [ "$order_id" != "Order_id" ]; then
        # Escape special characters and handle empty fields
        http_id=$(escape_sql "$http_id")
        transacttime=$(escape_sql "$transacttime")
        side=$(escape_sql "$side")
        user_id=$(escape_sql "$user_id")

        # Check if the referenced HTTP_id exists in the HTTP_Log table
        http_id_exists=$(docker exec -i "$DB_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" -N -e "SELECT COUNT(*) FROM $DB_NAME.HTTP_Log WHERE HTTP_id = $http_id;")

        if [ "$http_id_exists" -eq "1" ]; then
            # Insert or update Order table
            docker exec -i "$DB_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" <<EOF
            USE $DB_NAME;
            INSERT INTO \`Order\` (Order_id, http_id, TransactTime, Side, User_ID)
            VALUES ($order_id, $http_id, $transacttime, $side, $user_id)
            ON DUPLICATE KEY UPDATE
            http_id = VALUES(http_id),
            TransactTime = VALUES(TransactTime),
            Side = VALUES(Side),
            User_ID = VALUES(User_ID);
EOF
        else
            echo "Warning: Skipping Order with Order_id $order_id because HTTP_id $http_id does not exist in HTTP_Log table."
        fi
    fi
done < orders_data.csv

echo "Data insertion/update complete."


#!/bin/bash

# Set MySQL credentials
DB_CONTAINER_NAME="mysql9_project3"
DB_NAME="fix_data"
DB_USER="root"
DB_PASSWORD="root"

# Prepare MySQL database and tables in the container
docker exec -i "$DB_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" <<EOF
-- Create the database if it does not exist
CREATE DATABASE IF NOT EXISTS $DB_NAME;
USE $DB_NAME;

-- Drop existing tables
DROP TABLE IF EXISTS FIX_Messages;
DROP TABLE IF EXISTS HTTP_Logs;
DROP TABLE IF EXISTS Heartbeat_Messages;
DROP TABLE IF EXISTS FIX_HTTP_Link;

-- Create tables
CREATE TABLE FIX_Messages (
    fix_id INT AUTO_INCREMENT PRIMARY KEY,
    fix_version VARCHAR(10),
    MsgType VARCHAR(20),
    MsgSeqNum INT,
    SenderCompID VARCHAR(20),
    TargetCompID VARCHAR(20),
    SendingTime DATETIME,
    CheckSum VARCHAR(10),
    Stock_Symbol VARCHAR(10),
    OrderQty INT,
    TransactTime DATETIME,
    Side VARCHAR(5),
    Price DECIMAL(10,2),
    SenderSubID VARCHAR(20),
    ClOrdID VARCHAR(30)
);

CREATE TABLE HTTP_Logs (
    http_id INT AUTO_INCREMENT PRIMARY KEY,
    Timestamp DATETIME,
    IP_Address VARCHAR(20),
    Port INT,
    HTTP_Method VARCHAR(10),
    Path VARCHAR(100),
    Status_Code VARCHAR(10),
    Response_Time DECIMAL(10,8),
    Stock_Symbol VARCHAR(10)
);

CREATE TABLE Heartbeat_Messages (
    fix_id INT AUTO_INCREMENT PRIMARY KEY,
    fix_version VARCHAR(10),
    MsgType VARCHAR(20),
    MsgSeqNum INT,
    SenderCompID VARCHAR(20),
    TargetCompID VARCHAR(20),
    SendingTime DATETIME,
    HeartBtInt INT,
    CheckSum VARCHAR(10)
);

CREATE TABLE FIX_HTTP_Link (
    link_id INT AUTO_INCREMENT PRIMARY KEY,
    fix_id INT,
    http_id INT,
    FOREIGN KEY(fix_id) REFERENCES FIX_Messages(fix_id),
    FOREIGN KEY(http_id) REFERENCES HTTP_Logs(http_id)
);
EOF


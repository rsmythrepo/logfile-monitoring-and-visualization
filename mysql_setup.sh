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

-- Disable foreign key checks to drop existing tables
SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS \`Order\`;
DROP TABLE IF EXISTS HTTP_Log;
DROP TABLE IF EXISTS Heartbeat_Message;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Create 'HTTP_Log' table first
CREATE TABLE HTTP_Log (
    HTTP_id INT AUTO_INCREMENT PRIMARY KEY,
    IP_Address VARCHAR(20),
    Port INT,
    HTTP_Method VARCHAR(10),
    Path VARCHAR(100),
    Endpoint VARCHAR(10),
    Status_Code VARCHAR(10),
    Response_Time DECIMAL(10,8),
    Stock_Symbol VARCHAR(10),
    Timestamp DATETIME
);

-- Create 'Heartbeat_Message' table with proper columns
CREATE TABLE Heartbeat_Message (
    Heartbeat_id INT AUTO_INCREMENT PRIMARY KEY,
    fix_id INT,
    http_id INT,
    -- Add any other columns you need for Heartbeat_Message here
    -- For example:
    Message TEXT,
    Timestamp DATETIME
);

-- Create 'Order' table which references 'HTTP_Log'
CREATE TABLE \`Order\` (
    Order_id INT AUTO_INCREMENT PRIMARY KEY,
    http_id INT,
    TransactTime DATETIME,
    Side VARCHAR(5),
    User_ID VARCHAR(20),
    FOREIGN KEY (http_id) REFERENCES HTTP_Log(HTTP_id)
);

EOF

echo "MySQL setup complete."


# Show databases in the MySQL container
docker exec -i "$DB_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "SHOW DATABASES;"

# Show table descriptions individually
docker exec -i "$DB_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME; DESC \`Order\`;"
docker exec -i "$DB_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME; DESC HTTP_Log;"
docker exec -i "$DB_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME; DESC Heartbeat_Message;"
docker exec -i "$DB_CONTAINER_NAME" mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME; DESC Message_HTTP_Link;"



#!/bin/bash

# Step 1: Get logs for the past hour
kubectl logs orderbookapi-749556c9f9-xw9ff -n c402-team01-dev -c orderbookapi --since=1h > logfile.txt

# Step 2: Count log types
heartbeats=$(grep -c "heartbeats" logfile.txt)
ExecutionReports=$(grep -c "ExecutionReports" logfile.txt)
canceled=$(grep -c "canceled" logfile.txt)

# Step 3: Create the aggregated log file
echo "heartbeats=$heartbeats" > apilogs-aggregated
echo "ExecutionReports=$ExecutionReports" >> apilogs-aggregated
echo "canceled=$canceled" >> apilogs-aggregated


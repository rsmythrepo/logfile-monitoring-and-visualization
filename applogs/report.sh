#!/bin/bash

kubectl logs orderbookapi-749556c9f9-xw9ff -n c402-team01-dev -c orderbookapi --since=1h > logfile.txt

heartbeats=$(grep -c "heartbeats" logfile.txt)
ExecutionReports=$(grep -c "ExecutionReports" logfile.txt)
canceled=$(grep -c "canceled" logfile.txt)

total_logs=$(wc -l < logfile.txt)
NotHeartBeats=$((total_logs - heartbeats))

DBWarnings=$(grep -c "WARNING" logfile.txt)  # Adjust "WARNING" to match your log format

GOOG=$(grep -c "GOOG" logfile.txt)
AAPL=$(grep -c "AAPL" logfile.txt)

BUY=$(grep -c "buy" logfile.txt)  # Adjust "buy" to match your log format
SELL=$(grep -c "sell" logfile.txt)  # Adjust "sell" to match your log format

unique_stocks=$(grep -iEo '"stock": "[a-zA-Z]{0,}"' logfile.txt | sort -u | wc -l)

echo "Stock Count:" >> apilogs-aggregated
grep -iEo '"stock": "[a-zA-Z]{0,}"' logfile.txt | sort | uniq -c | awk '{print $2"="$1}' >> apilogs-aggregated

{
    echo "heartbeats=$heartbeats"
    echo "ExecutionReports=$ExecutionReports"
    echo "canceled=$canceled"
    echo "NotHeartBeats=$NotHeartBeats"
    echo "DBWarnings=$DBWarnings"
    echo "GOOG=$GOOG"
    echo "AAPL=$AAPL"
    echo "BUY=$BUY"
    echo "SELL=$SELL"
    echo "UniqueStocks=$unique_stocks"
} >> apilogs-aggregated

cat apilogs-aggregated


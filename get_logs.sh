logfile="apilogs.$(date +"%d-%m-%Y:%H:%M:%S")"
kubectl logs deploy/orderbookapi -n c402-team01-dev --since=2h > "$logfile"

# Response information
# response time 
# httpsstatuscode
heartbeats=$(grep -c '"MsgType": "Heartbeat"' "$logfile")
NotHeartBeats=$(grep -vc '"MsgType": "Heartbeat"' "$logfile")

# Stock information
goog=$(grep -i "GOOG" "$logfile" | wc -l)
tesla=$(grep -i "TSLA" "$logfile" | wc -l)
buy=$(grep -o '"side": "buy"' "$logfile" | wc -l)
sell=$(grep -i "sell" "$logfile" | wc -l)
uniqstocks=$(grep -iEo '"stock": "[a-z]{1,}"' "$logfile" | sort | uniq | wc -l)
eachstock=$(grep -iEo '"stock": "[a-z]{1,}"' "$logfile" | sort | uniq -c )

echo "heartbeats= $heartbeats" > apilogs-aggregated
echo "NotHeartBeats= $NotHeartBeats" >> apilogs-aggregated

echo "GOOG= $goog" >> apilogs-aggregated
echo "TSLA= $tesla" >> apilogs-aggregated
echo "BUY= $buy" >> apilogs-aggregated
echo "SELL= $sell" >> apilogs-aggregated

echo "UniqueStocks= $uniqstocks" >> apilogs-aggregated
echo "EachStockAmount=" >> apilogs-aggregated
echo $eachstock >> apilogs-aggregated

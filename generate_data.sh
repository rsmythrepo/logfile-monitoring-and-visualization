#!/bin/bash

# Set input and output file names
INPUT_FILE="http_logs_output.csv"
OUTPUT_FILE="orders_data.csv"

# Write the CSV header to the output file
echo "Order_id,Order_http_id,TransactTime,Side,User_ID" > $OUTPUT_FILE

# Initialize order ID
order_id=1

# Loop through each line in the input file, skipping the header
tail -n +2 "$INPUT_FILE" | while IFS=',' read -r id ip_address port http_method path endpoint status_code response_time stock timestamp; do
    # Check if the row has a stock symbol (non-empty) and the endpoint is 'trade'
    if [[ -n "$stock" ]]; then
        # Assign Side based on a random choice of "buy" or "sell"
        side=$([ $((RANDOM % 2)) -eq 0 ] && echo "buy" || echo "sell")

        # Generate a user ID
        user_id="user_$((RANDOM % 10000 + 1))"

        # Write the order data to the output file
        echo "$order_id,$id,$timestamp,$side,$user_id" >> $OUTPUT_FILE

        # Increment order_id for the next entry
        ((order_id++))
    fi
done

echo "Order data generated in $OUTPUT_FILE based on rows with stock symbols."

#!/bin/bash
 
URL="https://automation.atlassian.com/pro/hooks/<your_webhook>"
 
my_hostname=$(hostname)
architecture=$(uname -p)
MESSAGE=NULL
SUMMARY=NULL
if [ "$architecture" == "arm" ]; then
    output=$(system_profiler SPPowerDataType | grep -A3 -B7 "Power")
    max_capacity=$(echo "$output" | awk -F': ' '/Maximum Capacity/ {print $2}' | tr -d '%')
    if [ "$max_capacity" -lt 60 ]; then #Condition for sending the report of Apple Silicon report, change the value to your liking 
        MESSAGE="$my_hostname's battery health is $max_capacity%.\n Please contact the user and check if replacement is needed."
        SUMMARY="Laptop battery condition report - $my_hostname - macOS - Apple Silicon"
    fi
else
    status=$(system_profiler SPPowerDataType | grep "Condition" | awk '{print $2}')
    if [ "$status" != "Normal" ]; then
        MESSAGE="$my_hostname's battery status is $status.\n Please contact the user and check if replacement is needed."
        SUMMARY="Laptop battery condition report - $my_hostname - macOS - Intel"
    fi
fi
 
json_payload="{
            \"summary\": \"$SUMMARY\",
            \"description\": \"$MESSAGE\"
        }"
 
if [ "$MESSAGE" != "NULL" ]; then
    curl -X POST -H 'Content-Type: application/json' -d "$json_payload" "$URL"
     > /dev/null
fi
#!/bin/bash

# Define the JSON data (replace with your actual JSON source)
json_data=$(curl -s https://devops.spinbet.com/)
output_filename='pipeline_job_summary.csv'

# Print header row
if [[ -z $(grep -i "Status,Reason,Occurrences" $output_filename) ]]; then
    echo "Status,Reason,Occurrences" > $output_filename
fi

# Loop through each JSON object
for item in $(echo $json_data | jq -r '.[] | [ .status, .reason, .occurrences ] | @csv' ); do
    # Parse the json data into variables
    parsed_value=$(echo $item | sed 's/"//g')
    stat=$(echo $parsed_value | awk -F ',' '{print $1}')
    reason=$(echo $parsed_value | awk -F ',' '{print $2}')
    occurrences=$(echo $parsed_value | awk -F ',' '{print $3}')

    #   Skip "think_it_passed" reason
    if [[ $reason != 'think_it_passed' ]]; then

    #  Search for existing status entry (ignoring case)
        existing_status=$(grep -i "$stat" $output_filename)

        if [[ ! -z "$existing_status" ]]; then
            existing_reason=$(grep -i "$stat, $reason" $output_filename)
    #  Update occurrences for existing status and reason
            if [[ ! -z "$existing_reason" ]]; then
                new_count=$(echo "$existing_reason" | cut -d ',' -f3 | awk '{print $1 + '$occurrences'}')
                sed -i 's#^'"$stat"','"$reason"',.*$#'"$stat"','"$reason"','"$new_count"'#g' $output_filename
            else
                echo "$stat,$reason,$occurrences" | tee -a $output_filename
            fi
        else
            echo "$stat,$reason,$occurrences" | tee -a $output_filename
        fi
    fi
done

echo "CSV file generated in: $(pwd)/$output_filename"
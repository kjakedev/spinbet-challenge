#!/bin/bash

# Define the api endpoint and if none is provide it will be the default value
api_endpoint=${1:-'https://devops.spinbet.com/'}


# Use curl to test and get the JSON data
curl_response=$(curl -s -o - -w "%{http_code}" "$api_endpoint")
status_code="${curl_response: -3}"
json_data="${curl_response:0:$((${#curl_response} - 3))}"

# Check curl exit status
if [[ $status_code -ne 200 ]]; then
  echo "Error: curl failed to retrieve data from $api_endpoint (status code: $status_code). Exiting script."
  exit 1
fi

# Define the output filename and if none is provide it will be the default value
output_filename=${2:-'pipeline_job_summary'}.csv
output_filename=$(echo "$output_filename" | sed 's/\.csv\.csv/.csv/g')

# Print header row
echo -e "---------------------------------\n"
echo -e "Status,Reason,Occurrences\n"
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
            existing_reason=$(grep -i "$stat,$reason" $output_filename)
    #  Update occurrences for existing status and reason
            if [[ ! -z "$existing_reason" ]]; then
                new_count=$(echo "$existing_reason" | cut -d ',' -f3 | awk '{print $1 + '$occurrences'}')
                sed -i 's#^'"$stat"','"$reason"',.*$#'"$stat"','"$reason"','"$new_count"'#g' $output_filename
                echo -e "$stat,$reason,$new_count\n"
            else
                echo -e "$stat,$reason,$occurrences\n" | tee -a $output_filename
            fi
        else
            echo -e "$stat,$reason,$occurrences\n" | tee -a $output_filename
        fi
    fi
done
echo "---------------------------------"

echo "CSV file generated in: $(pwd)/$output_filename"
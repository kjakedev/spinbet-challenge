#!/bin/bash

# Function to display help
help_function() {
    echo "Usage: $0 [-e api_endpoint] [-o output_csv] [--image image_file]"
    echo ""
    echo "Options:"
    echo "  -e, --api_endpoint   Optional: API endpoint to be used for checking the pipeline statuses"
    echo "  -o, --output         Optional: Output filename for the generated csv file"
    echo "  --image              Optional: Output filename for the generated infographic image file"
    echo "  -h, --help           Display this help message"
}

# Set default values
image_file="pipeline_job_summary.jpg"
api_endpoint="https://devops.spinbet.com/"
output_csv="pipeline_job_summary"

# Parse command-line options and arguments
while [[ "$1" != "" ]]; do
    case $1 in
        -e | --api_endpoint ) shift
                              api_endpoint=$1
                              ;;
        -o | --output )       shift
                              output_csv=$1
                              ;;
        --image )             shift
                              image_file=$1
                              ;;
        -h | --help )         help_function
                              return 0
                              ;;
        * )                   echo "Invalid option: $1"
                              help_function
                              return 1
                              ;;
    esac
    shift
done


# Run the pipeline_aggregate.sh script with provided arguments
pipeline_script="shell-script/pipeline_aggregate.sh"

echo "--------------- $pipeline_script ------------------------"
pipeline_output=$("$pipeline_script" "$api_endpoint" "$output_csv")
echo $pipeline_output
if [ $? -ne 0 ]; then
    echo "Error: pipeline_aggregate.sh failed."
    help_function
    return 1
fi

# Extract the CSV file path from the output
csv_file=$(echo "$pipeline_output" | grep -oP 'CSV file generated in: \K.*')
if [ -z "$csv_file" ]; then
    echo "Error: Failed to extract CSV file path from the output."
    help_function
    return 1
fi

# If the above script ran successfully, run the visualize.py script
python_script="python-visualize/visualize.py"
echo ""
echo "--------------- $python_script ------------------------"
if ! python3 "$python_script" -f "$csv_file" -o "$image_file"; then
    echo "Error: visualize.py failed."
    help_function
    return 1
fi

echo "Scripts executed successfully."

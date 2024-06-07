# Spinbet DevOps Engineer Coding Challenge

This repository provides a tool to visualize CICD workflow pipeline status data from an API endpoint (`https://devops.spinbet.com/`) as a pie chart infographic.

## Components

- `shell-script` folder: Contains the `pipeline_aggregate.sh` script that retrieves data from the API, processes it, and saves it to a CSV file.
- `python-visualize` folder: Contains the `visualize.py` script that generates a pie chart infographic from a CSV file.

## Application Set-up

1. Python Virtual Environment

It's recommended to create a virtual environment to isolate project dependencies. Here's how:
```
python3 -m venv venv

source venv/bin/activate
```
This will create a `venv` folder in your current working directory.

2. Install Dependencies

Install required packages using the requirements.txt file:

```
pip install -r python-visualize/requirements.txt
```

## Running the script

To run the script simply run this command:

```
. ./run.sh

#or

bash ./run.sh

```
This script retrieves data, generates a CSV file, and creates the infographic.

Example outputs are in this repository: `pipeline_job_summary.csv` and `pipeline_job_summary.jpg


## shell-script

Inside the `shell-script` folder is the `pipeline_aggregate.sh` bash script. This script invoke the API and processed the data to output a csv file. The script accepts two optional arguments with default values.

**Arguments:**
- `$1` (**API URL**): Override the default API endpoint (Default value: `https://devops.spinbet.com/`).
- `$2` (**CSV Filename**): Override the default CSV filename (Default value: `pipeline_job_summary`).

**NOTE:** The .csv file extension is automatically appended if no file extension or an invalid is provided.

Example:
```
. ./pipeline_aggregate.sh http://34.117.217.236/ test  # Set custom API URL and filename
```

## python-visualize

Inside the `python-visualize` folder is the python program named `visualize.py`. This program creates a pie chart infographic based from a CSV file that is provided. 

This program only accepts a CSV file in this format:
```
Status,Reason,Occurrences
success,n/a,71
processing,n/a,60
failed,invalid_yaml,48
failed,timeout,47
```

The python program also accepts two optional arguments with default values.

**Arguments**
- `-f` (**CSV File Path**): Specify the path to your CSV file (Default value: `<current working directory>/pipeline_job_summary.csv`).
- `-o` (**Image Output Filename**): Set the desired filename for the image infographic (Default value: `pipeline_job_summary`).

**NOTE:** The .jpg file extension is automatically appended if no file extension or an invalid is provided.

Example:
```
python3 python-visualize/visualize.py -f test.csv -o test_summary
```


## Improvements

- The display of the output of the script could be improved by adding visual identification such as color coding to highlight results in the command line.
- Even with using of the python virtual environment there are still tendencies that the python program would not work. We can resolve this by making a container image and using this image just simply run the container without worrying the setting up of a python virtual environment
- The file outputs of the script could be overwritten many times and data could be inconsistent when an unexpected failure happened in the endpoint. There should be logs or version of the outputs somewhere in the server where this will run to keep track of previous runs and also a backup in case of failures. The logs or outputs should be logrotated to avoid filling up the disk of the server, assuming we are going to use this script frequently.

## Appendix

To deactivate the python virtual environment simply run `deactivate`
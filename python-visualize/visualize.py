import argparse
import pandas as pd
import matplotlib.pyplot as plt
import os
from datetime import date

def create_pie_chart(csv_path, output_filename):
    """
    Creates a pie chart from a CSV file and saves it as a JPG image.

    Args:
        csv_path (str): Path to the CSV file containing data.
        output_filename (str): Desired filename (including .jpg extension) for the pie chart.
    """
    # Check if data file exists
    if not os.path.exists(csv_path):
        print(f"Error: Data file '{csv_path}' does not exist.")
        return

    # Validate output filename extension
    if not output_filename.endswith(".jpg"):
        output_filename += ".jpg"
        print(f"Warning: Output filename '{output_filename}' modified to end with '.jpg'.")

    # Define date today
    today = date.today()

    # Read the CSV file
    df = pd.read_csv(csv_path)

    # Strip any leading/trailing spaces from the column names
    df.columns = df.columns.str.strip()

    # Group by status and sum occurrences
    status_counts = df.groupby('Status')['Occurrences'].sum()

    # Function to format percent labels
    def autopct_format(values):
        def my_format(pct):
            total = sum(values)
            val = int(round(pct*total/100.0))
            return '{v:d}'.format(v=val)
        return my_format

    # Create the main pie chart
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 14))



    ax1.pie(status_counts, labels=[f'{index}' for index, value in status_counts.items()], autopct = autopct_format(status_counts), startangle=90)
    ax1.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
    ax1.set_title(f'Status Occurrences {today}')

    # Filter 'failed' status and group by reason
    failed_df = df[df['Status'] == 'failed']
    reason_counts = failed_df.groupby('Reason')['Occurrences'].sum()

    # Create the pie chart for 'failed' reasons
    ax2.pie(reason_counts, labels=[f'{index}' for index, value in reason_counts.items()], autopct = autopct_format(reason_counts), startangle=90)
    ax2.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
    ax2.set_title(f'Failed Reasons Occurrences {today}')

    # Add total occurrences in the legend for both charts
    total_occurrences = status_counts.sum()
    ax1.legend(title=f'Total Occurrences: {total_occurrences}', loc='upper left')
    ax2.legend(title=f'Total Occurrences: {reason_counts.sum()}', loc='lower left', bbox_to_anchor=(-0.10, -0.15), ncol=1)

    # Save the pie charts as a JPG file
    plt.savefig(output_filename)

    parent_directory = os.path.dirname(os.getcwd())
    print(f'Pie chart saved in: {parent_directory}/{output_filename}')

if __name__ == "__main__":
  # Parse arguments using argparse
  parser = argparse.ArgumentParser(description="Generate pie chart from CSV data")
  parser.add_argument("-f", "--csv_path", default=f'{os.getcwd()}/pipeline_job_summary.csv',
                      help=f'Path to the CSV data file (default: {os.getcwd()}/pipeline_job_summary.csv)')
  parser.add_argument("-o", "--output_filename", default="pipeline_job_summary.jpg",
                      help="Desired filename (including .jpg extension) for the pie chart (default: pipeline_job_summary.jpg)")
  args = parser.parse_args()

  # Call the function with arguments
  create_pie_chart(args.csv_path, args.output_filename)
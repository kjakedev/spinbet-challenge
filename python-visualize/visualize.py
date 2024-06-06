import pandas as pd
import matplotlib.pyplot as plt
import os

# Read the CSV file
df = pd.read_csv("../pipeline_job_summary.csv")

# Strip any leading/trailing spaces from the column names
df.columns = df.columns.str.strip()

# Group by status and sum occurrences
status_counts = df.groupby('Status')['Occurrences'].sum()

# Create the main pie chart
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 14))

ax1.pie(status_counts, labels=[f'{index} ({value})' for index, value in status_counts.items()], startangle=90)
ax1.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
ax1.set_title('Status Occurrences')

# Filter 'failed' status and group by reason
failed_df = df[df['Status'] == 'failed']
reason_counts = failed_df.groupby('Reason')['Occurrences'].sum()

# Create the pie chart for 'failed' reasons
ax2.pie(reason_counts, labels=[f'{index} ({value})' for index, value in reason_counts.items()], startangle=90)
ax2.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle.
ax2.set_title('Failed Reasons Occurrences')

# Add total occurrences in the legend for both charts
total_occurrences = status_counts.sum()
ax1.legend(title=f'Total Occurrences: {total_occurrences}', loc='upper left')
ax2.legend(title=f'Total Occurrences: {reason_counts.sum()}', loc='lower left', bbox_to_anchor=(-0.10, -0.15), ncol=1)

# Save the pie charts as a JPG file
plt.savefig('../pipeline_job_summary.jpg')

parent_directory = os.path.dirname(os.getcwd())
print(f'Pie chart saved in: {parent_directory}/pipeline_job_summary.jpg')


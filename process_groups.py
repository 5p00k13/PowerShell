import subprocess
import csv
import os

# Define file paths
groups_file = 'C:/Temp/all_groups.csv'
output_file = 'C:/Temp/groups_with_member_counts.csv'

# Check if groups_file exists
if not os.path.exists(groups_file):
    print(f"Error: {groups_file} does not exist.")
    exit(1)

# Open the output CSV file for writing
with open(output_file, 'w', newline='') as csvfile:
    fieldnames = ['Email', 'Name', 'Number of Members']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    # Read the list of groups from the CSV file
    with open(groups_file, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            email = row.get('Email')
            name = row.get('Name')
            
            if not email:
                print(f"Skipping row with missing email: {row}")
                continue
            
            # Get the number of members using GAM
            try:
                # Run GAM command to get group members
                result = subprocess.run(['gam', 'print', 'group-members', email], capture_output=True, text=True, check=True)
                
                # Count the number of lines in the output
                lines = result.stdout.splitlines()
                member_count = len(lines) - 1  # Subtract 1 for header line
                
                # Write to the output CSV file
                writer.writerow({'Email': email, 'Name': name, 'Number of Members': member_count})
                
            except subprocess.CalledProcessError as e:
                print(f"Error retrieving members for group {email}: {e}")
                writer.writerow({'Email': email, 'Name': name, 'Number of Members': 'Error'})

print(f"Processing complete. Output saved to {output_file}.")

#!bin/bash

# Number of users that will upload the file
users=$1

# Check if the number of users is provided
if [ -z $users ]; then
  echo "Please provide the number of users that will upload the file"
  exit 1
fi

# Check if the Nextcloud container is running
if ! docker ps | grep -q nextcloud; then
  echo "Nextcloud container is not running"
  exit 1
fi

# Check if the file exists in the test_data directory
if [ ! -f "test_data/average_file_5MB" ]; then
  echo "The file test_data/average_file_5MB does not exist. Please run the create_files.sh script to generate the file"
  exit 1
fi

# Variables
URL="localhost:8080"
file_dir="test_data/average_file_5MB"
file="test_file_5MB"

# Make a copy of the 5MB file and rename it to the file name
cp $file_dir test_data/$file

# Loop through the number of users and upload the 5MB file to Nextcloud
for i in $(seq 1 $users);
do
    username="test_User_$i"
    password="test_Password_$i"
    curl -k -u $username:$password -X PUT -T test_data/$file $URL/remote.php/dav/files/$username/$file
    # Check if the file was uploaded successfully
    if [ $? -eq 0 ]; then
        echo "File $file uploaded successfully by user $username"
    else
        echo "Failed to upload file $file by user $username"
    fi
done
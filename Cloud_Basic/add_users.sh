#!/bin/bash

# Number of new users to add
users=$1

# Check if the number of users is provided
if [ -z $users ]; then
  echo "Please provide the number of users to add"
  exit 1
fi

# Check if the Nextcloud container is running
if ! docker ps | grep -q nextcloud; then
  echo "Nextcloud container is not running"
  exit 1
fi

# Loop through the number of users and add them to the system
for i in $(seq 1 $users);
do
  username="test_User_$i"
  password="test_Password_$i"
  docker exec -e OC_PASS="$password" --user www-data nextcloud /var/www/html/occ user:add --password-from-env "$username"
done

echo "Users added successfully"

# Warning message to update the number of users employed in the locustfile.py script to perform the tests
echo "Please update the number of users in the locustfile.py script to match the number of users added"

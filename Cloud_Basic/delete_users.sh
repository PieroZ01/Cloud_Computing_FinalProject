#!/bin/bash

# Number of users to delete
users=$1

# Check if the number of users is provided
if [ -z $users ]; then
  echo "Please provide the number of users to remove"
  exit 1
fi

# Loop through the number of users and remove them from the system
for i in $(seq 1 $users);
do
  username="test_User_$i"
  docker exec --user www-data nextcloud /var/www/html/occ user:delete "$username"
done

echo "Users removed successfully"

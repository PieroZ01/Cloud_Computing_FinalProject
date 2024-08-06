#!/bin/bash

# Set private storage space per user (default is 512MB)
docker exec --user www-data nextcloud php occ config:app:set files default_quota --value "5 GB"

# Enable encryption
docker exec --user www-data nextcloud /var/www/html/occ app:enable encryption
docker exec --user www-data nextcloud /var/www/html/occ encryption:enable
echo "yes" | docker exec -i --user www-data nextcloud /var/www/html/occ encryption:encrypt-all

# Add locust to the trusted domains
docker exec --user www-data nextcloud /var/www/html/occ config:system:set trusted_domains 1 --value=nextcloud

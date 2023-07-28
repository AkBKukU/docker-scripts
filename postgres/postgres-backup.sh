#!/bin/bash

timestamp="$(date +"%Y-%m-%dT%T")"

# Check which container to access
if [[ "$1" != "" ]]
then
	container_name="$1"
else
	container_name="" # hardcoded container
fi

if [[ "$container_name" == "" ]]
then
	echo "Please specify a database container name as an argument or hard code one in this file"
	exit 1
fi

# Load database access information from enviorinment file
source ./credentials.env

echo "[$timestamp] Start backup of [$container_name]"

# Dump SQL database to file
docker exec -i $container_name pg_dump --dbname=postgresql://$DB_USER:$DB_PASS@$MAP_INTERFACE5432/$DB_NAME > "$timestamp-$container_name-$DB_NAME.sql"

# Archive and compress all files
tar --exclude='images/thumb' -czvf "./$timestamp-$container_name-images.tar.gz" \
"$timestamp-$container_name-$DB_NAME.sql"

# Clean up
if [[ "$?" == "0" ]]
then
	rm "$timestamp-$container_name-$DB_NAME.sql"
else
	echo "Error on archive creation"
fi


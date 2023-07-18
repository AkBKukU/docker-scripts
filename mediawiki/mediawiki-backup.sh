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
docker exec -i $container_name mariadb-dump -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > "$timestamp-$container_name-$MYSQL_DATABASE.sql"

# Archive and compress all files
tar --exclude='images/thumb' -czvf "./$timestamp-$container_name-images.tar.gz" \
images \
extensions \
LocalSettings.php \
favicon.ico credentials.env \
"$timestamp-$container_name-$MYSQL_DATABASE.sql"

# Clean up
if [[ "$?" == "0" ]]
then
	rm "$timestamp-$container_name-$MYSQL_DATABASE.sql"
else
	echo "Error on archive creation"
fi


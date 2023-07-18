#!/bin/bash

timestamp="$(date +"%Y-%m-%dT%T")"

# Check archive file
if [[ "$1" != "" ]]
then
	if [[ "$1" == *.tar.gz ]]
	then
		archive_name="$1"
	else
		echo "[$1] Not a tar.gz file"
		exit 1
	fi
else
	echo "Please provide archive file"
	exit 1
fi

# Check which container to access
if [[ "$2" != "" ]]
then
	container_name="$2"
else
	container_name="" # hardcoded container
fi

if [[ "$container_name" == "" ]]
then
	echo "Please specify a database container name as an argument or hard code one in this file"
	exit 1
fi

# Archive and compress all files
tar -xvf "./$archive_name"

# Load database access information from enviorinment file
source ./credentials.env

echo "[$timestamp] Start restoration of [$container_name]"


# Dump SQL database to file
docker exec -i $container_name mariadb -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -e "DROP DATABASE IF EXISTS $MYSQL_DATABASE;"
docker exec -i $container_name mariadb -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE $MYSQL_DATABASE;"
docker exec -i $container_name mariadb -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < *.sql


# Clean up
if [[ "$?" == "0" ]]
then
	rm *.sql
else
	echo "Error on restoring database"
fi


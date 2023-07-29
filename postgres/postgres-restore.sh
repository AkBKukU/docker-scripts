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


# Check file to restore
if [[ "$2" != "" ]]
then
	restore_name="$2"
else
	restore_name="" # hardcoded container
fi

if [[ "$restore_name" == "" ]]
then
	echo "Please specify a database file name as an argument or hard code one in this file"
	exit 1
fi


# Load database access information from enviorinment file
source ./credentials.env

echo "[$timestamp] Start restore of [$container_name] from ["$restore_name"] to ["$DB_NAME"]"

# Dump SQL database to file
docker exec -i $container_name psql --dbname=postgresql://$DB_USER:$DB_PASS@$MAP_INTERFACE:5432 -c "DROP DATABASE $DB_NAME;"
docker exec -i $container_name psql --dbname=postgresql://$DB_USER:$DB_PASS@$MAP_INTERFACE:5432 -c "CREATE DATABASE $DB_NAME;"
docker exec -i $container_name psql --dbname=postgresql://$DB_USER:$DB_PASS@$MAP_INTERFACE:5432/$DB_NAME < <(zcat "$restore_name")


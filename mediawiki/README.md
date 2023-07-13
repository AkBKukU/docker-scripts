# MediaWiki Docker Setup

I run two mediawiki sites, Caps.Wiki & Wiki.TechTangents, these will have 
identical requirements and may as well be lumped together for maintenance.

These are setup using MariaDB as their backbone and share extensions.

## Updates

### Database
You will need to export and re-import the SQL database for the wikis. You can 
run SQL commands like this:
    
    docker exec -i mysql-container mariadb -uuser -ppassword name_db < data.sql

*Note: `data.sql` in this example is a file on the host system*



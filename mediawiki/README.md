# MediaWiki Docker Setup

Mediawiki is the software that run Wikipedia and is open source and able to be
self hosted to run your own wikis.

Mediawiki has several components critical for Docker purposes, primarily it
requires a database like MariaDB, which is used here, to work. There are also 
several folders and files you may need to customize and should be put in 
Volumes:

 - `images`: The location of uploaded photos and files
 - `extensions`: Add-ons to the Mediawiki software. The base image ships with 
extensions installed making it complicated to export.
 - `LocalSettings.php`: The primary configuration file for Mediawiki
 - `favicon.ico`: Needed to set a favicon

MariaDB will also need configured to provide access to Mediawiki. This is done
at deployment time with substitute variables. The `credentials.env` file is an
example file you can modify and then load to set the access credentials.

[mediawiki-tt-test.yml](mediawiki-tt-test.yml) is a compose file for setting 
all this up.

## Maintenance

Two scripts have been included for automating backing up and restoring. They 
will archive all the files exported as Volumes as well as the database in a 
tar.gz.

### Backup

To create a backup run `./mediawiki-backup.sh $container_name`. This script 
needs the name of the MariaDB container as a parameter and to be run next to 
the `credentials.env` file to load the user/pass for the database. This will 
use `mariadb-dump` to create an SQL file with the site database and archive it 
with all the other files.

### Restore

Restoring is more complicated. Run `./mediawiki-restore.sh $archive_name
$container_name` in the directory where the Volumes will look for the files. As
part of the restore process this will **DROP DATABASE** for a database with the
name given in the `credentials.env` in the archive, so be sure of what you are
doing. With a valid backup archive this will unpack all of the folders for the 
Volumes.

If this is a new deployment you will need to change the IP address of the 
database in the `LocalSettings.php` file

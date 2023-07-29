# DaVinci Resolve Postgres Server

The video editing software DaVinci Resolve has the option to use a postgres
server to store video projects which when combined with network storage
makes remote video editing a breeze.

# Postgres

In versions of Resolve prior to 18, postgres 9.5.4 was required, with the
release of 18 though postgres 13 is now officially supported.

## Maintenance

Two scripts have been included for automating backing up and restoring. They
will archive all the files exported as Volumes as well as the database in a
tar.gz.

### Backup

To create a backup run `./postgres-backup.sh $container_name`. This script
needs the name of the postgres container as a parameter and to be run next to
the `credentials.env` file to load the user/pass for the database. This will
use `pg_dump` to create an gziped SQL file with the project database in it.

### Restore

Restoring is more complicated. Run `./postgres-restore.sh $container_name
$archive_name. As part of the restore process this will **DROP DATABASE**
for a database with the name given in the `credentials.env` by the script,
so be sure of what you are doing.


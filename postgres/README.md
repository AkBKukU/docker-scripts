# DaVinci Resolve Postgres Server

The video editing software DaVinci Resolve has the option to use a postgres
server to store video projects which when combined with network storage
makes remote video editing a breeze.

# Postgres

In versions of Resolve prior to 18, postgres 9.5.4 was required, with the
release of 18 though postgres 13 is now officially supported. However, from
my testing, postgres 13 *still* does not work. Either with an imported 
database or a new one(meaning upgrades are not a problem). Version 9.5 is the
only one I have ever had work.

As such, I would advise reading the [Wireguard](../WIREGUARD-NGINX.md) setup
page, and mapping the out of date version of Postgres to a VPN tunnel to use 
for connecting to it. As a bonus, you can map file shares through it as well
and have a single, secure, connection for editing.

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


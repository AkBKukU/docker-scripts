# Semantic Wiki Setup

Semantic wiki is a nightmare to install and it CANNOT be done at once with a never used Mediawiki instance. This folder contains two docker compose scripts for a two stage setup process.

## 1. Normal Mediawiki Initialization

Start up the `*-install.yml` compose file with the `*.env` file filled out in the way you will want for the final setup. Go through the normal setup process. Download and save the `LocalSettings.php` file to the `$BIND_DIR`.

## 2. Install SMW

Modify the `LocalSettings.php` file per the [SMW install directions](https://www.semantic-mediawiki.org/wiki/Help:Installation/Using_Composer_with_MediaWiki_1.25%2B). Start the final compose script. Get into the image with `docker exec -it semanticmediawiki /bin/bash`. Run `php maintenance/update.php` and `php extensions/SemanticMediaWiki/maintenance/rebuildData.php -d 50 -v`

After that, it should work. Maybe...

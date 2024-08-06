#!/usr/bin/env bash

# Set file perms
echo "Setting volume file permissions"
chown -R www-data:www-data /var/www/html/images
chmod -R 755 /var/www/html/images
chown -R www-data:www-data /var/www/html/extensions-custom
chmod -R 755 /var/www/html/extensions-custom
chown -R www-data:www-data /var/www/html/LocalSettings.php
chmod -R 755 /var/www/html/LocalSettings.php
chown -R www-data:www-data /var/www/html/favicon.ico
chmod -R 755 /var/www/html/favicon.ico
chown -R www-data:www-data /var/www/html/vendor
chmod -R 755 /var/www/html/vendor

# First boot after setting up base Mediawiki
if [ -f "/var/www/html/LocalSettings.php" ] && [ ! -f /var/www/html/composer.local.json ]; then
    echo '{"require":{"mediawiki/semantic-media-wiki":"^4.2.0"},
    "extra": {"merge-plugin": {"include": ["extensions-custom/*/composer.json"]}}
}' > /var/www/html/composer.local.json
    composer update --no-dev
fi

# Attempt to enable SemanticMediaWiki
if [ -f "/var/www/html/LocalSettings.php" ] && ! grep -q "SemanticMediaWiki" /var/www/html/LocalSettings.php; then
    echo "wfLoadExtension( 'SemanticMediaWiki' );" >> /var/www/html/LocalSettings.php
    echo "enableSemantics( 'LOCALHOST' );" >> /var/www/html/LocalSettings.php
fi

# Update/Install composer plugins
composer update --no-dev

# Upgrade DB
if [ -f "/var/www/html/LocalSettings.php" ]
then
	# NOTE - This does not persist between reboots for some reason
	/usr/local/bin/php /var/www/html/maintenance/update.php
fi


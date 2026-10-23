#!/usr/bin/env bash

# Set file perms
echo "[install-smw.sh] Setting volume file permissions"
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
    echo "[install-smw.sh] First boot after setting up base Mediawiki"
    echo '{"require":{"mediawiki/semantic-media-wiki":"^4.2.0","mediawiki/semantic-result-formats": "~4.2"},
    "extra": {"merge-plugin": {"include": ["extensions-custom/*/composer.json"]}}
}' > /var/www/html/composer.local.json
    composer update --no-dev
fi

# Attempt to enable SemanticMediaWiki
if [ -f "/var/www/html/LocalSettings.php" ] && ! grep -q "SemanticMediaWiki" /var/www/html/LocalSettings.php; then
    echo "[install-smw.sh] Attempt to enable SemanticMediaWiki"
    echo "wfLoadExtension( 'SemanticMediaWiki' );" >> /var/www/html/LocalSettings.php
    echo "enableSemantics( 'LOCALHOST' );" >> /var/www/html/LocalSettings.php
fi

# Mostly for debugging but handle detecting existing SMW setup
if [ ! -f /var/www/html/extensions/SemanticResultFormats/SemanticResultFormats.php ]; then
    echo "[install-smw.sh] SemanticMediaWiki files don't exist, installing..."
    composer update --no-dev
else
    echo "[install-smw.sh] SemanticMediaWiki files exist, assuming existing install"
    # Update/Install composer plugins
    composer update --no-dev
fi


# Upgrade DB
if [ -f "/var/www/html/LocalSettings.php" ]
then
	# NOTE - This does not persist between reboots for some reason and must be re-run on restart
	/usr/local/bin/php /var/www/html/maintenance/update.php
fi


#!/usr/bin/env bash
if [ -f "/var/www/html/LocalSettings.php" ] && [ ! -f /var/www/html/composer.local.json ]; then
    echo '{"require":{"mediawiki/semantic-media-wiki":"^4.2.0"},
    "extra": {"merge-plugin": {"include": ["extensions-custom/*/composer.json"]}}
}' > /var/www/html/composer.local.json
    composer update --no-dev
fi
if [ -f "/var/www/html/LocalSettings.php" ] && ! grep -q "SemanticMediaWiki" /var/www/html/LocalSettings.php; then
    echo "wfLoadExtension( 'SemanticMediaWiki' );" >> /var/www/html/LocalSettings.php
    echo "enableSemantics( 'LOCALHOST' );" >> /var/www/html/LocalSettings.php
fi

composer update --no-dev
if [ -f "/var/www/html/LocalSettings.php" ]
then
	/usr/local/bin/php /var/www/html/maintenance/update.php
fi

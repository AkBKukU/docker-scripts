#!/usr/bin/env bash
if [ -f "/var/www/html/LocalSettings.php" ] && [ ! -f /var/www/html/composer.local.json ]; then
    echo '{"require":{"mediawiki/semantic-media-wiki":"^4.2.0"}}' > /var/www/html/composer.local.json
    composer update --no-dev
fi
if [ -f "/var/www/html/LocalSettings.php" ] && ! grep -q "SemanticMediaWiki" /var/www/html/LocalSettings.php; then
    echo "wfLoadExtension( 'SemanticMediaWiki' );" >> /var/www/html/LocalSettings.php
    echo "enableSemantics( 'LOCALHOST' );" >> /var/www/html/LocalSettings.php
fi
/usr/local/bin/php /var/www/html/maintenance/update.php

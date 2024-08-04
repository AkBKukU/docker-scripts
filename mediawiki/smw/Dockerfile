FROM mediawiki:1.41

LABEL name="TechTangents' MediaWiki"

ARG PHP_MEMORY_LIMIT="50M"
ARG PHP_POST_MAX_SIZE="50M"
ARG PHP_UPLOAD_MAX_FILESIZE="50M"
ARG MW_BASE_PATH="/var/www/html"
ARG MW_LOCAL_SETTINGS="LocalSettings.php"
ARG MW_COMPOSER_LOCAL="composer.local.json"
ARG SMW_VERSION="^4.2.0"
ARG SMW_WIKI_DOMAIN="example.org"

ENV MW_BASE_PATH="/var/www/html"

# Install additional packages
RUN apt-get update && apt-get install -y \
    unzip \
    libzip-dev

# Install additional extensions
RUN docker-php-ext-install \
    zip

# Enable additional PHP extensions
RUN docker-php-ext-enable \
    zip

# Install Composer (Reference: https://stackoverflow.com/a/58694421)
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Fix PHP stuff (idk what this fixes, it's been too long)
RUN echo -e " \
memory_limit = ${PHP_MEMORY_LIMIT}\n \
post_max_size = ${PHP_POST_MAX_SIZE}\n \
upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE} \
" > /usr/local/etc/php/conf.d/99-Wiki.ini

# Create a script that conditionally installs SMW
COPY <<EOF ${MW_BASE_PATH}/install-smw.sh
#!/usr/bin/env bash
if [ -f "${MW_BASE_PATH}/${MW_LOCAL_SETTINGS}" ] && [ ! -f ${MW_BASE_PATH}/${MW_COMPOSER_LOCAL} ]; then
    echo '{"require":{"mediawiki/semantic-media-wiki":"${SMW_VERSION}"}}' > ${MW_BASE_PATH}/${MW_COMPOSER_LOCAL}
    composer update --no-dev
fi
if [ -f "${MW_BASE_PATH}/${MW_LOCAL_SETTINGS}" ] && ! grep -q "SemanticMediaWiki" ${MW_BASE_PATH}/${MW_LOCAL_SETTINGS}; then
    echo "wfLoadExtension( 'SemanticMediaWiki' );" >> ${MW_BASE_PATH}/${MW_LOCAL_SETTINGS}
    echo "enableSemantics( '${SMW_WIKI_DOMAIN}' );" >> ${MW_BASE_PATH}/${MW_LOCAL_SETTINGS}
fi
/usr/local/bin/php ${MW_BASE_PATH}/maintenance/update.php
EOF

RUN chmod +x ${MW_BASE_PATH}/install-smw.sh

CMD ${MW_BASE_PATH}/install-smw.sh && \
    apache2-foreground

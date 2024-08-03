FROM mediawiki:1.39

LABEL name="TechTangent's MediaWiki"

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


# Install Composer (Reference: https://getcomposer.org/download/)
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" &&\
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# Fix PHP stuff (idk what this fixes, it's been too long)
RUN echo -e "memory_limit = 50M\npost_max_size = 50M\nupload_max_filesize = 50M" > /usr/local/etc/php/conf.d/99-Wiki.ini

# Install composer based extensions
# normalized-exception version locked per: https://github.com/SemanticMediaWiki/SemanticMediaWiki/issues/5519#issuecomment-2137684545
# COMPOSER_ALLOW_SUPERUSER=1
# composer config --no-plugins allow-plugins.composer/installers [true|false]
# zordius/lightncandy
RUN cd /var/www/html/ \
    && echo "{}" > composer.local.json \
    && export COMPOSER=composer.local.json \
    && export COMPOSER_ALLOW_SUPERUSER=1 \
    &&  composer config --no-plugins allow-plugins.composer/installers false \
	&& composer update \
	&& composer require wikimedia/at-ease "^2.1" --update-no-dev \
	&& composer require liuggio/statsd-client-bundle --update-no-dev  \
	&& composer require wikimedia/normalized-exception "^1.0" --update-no-dev \
	&& composer require mediawiki/semantic-media-wiki "~4.1.3" --update-no-dev --with-all-dependencies \
 	 && composer require zordius/lightncandy --update-no-dev \
 	&& composer require mediawiki/semantic-result-formats --update-no-dev \
	&& composer update -w


# Need to execute program here, eg.
# CMD ["php-fpm"]

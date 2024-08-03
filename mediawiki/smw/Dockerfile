FROM mediawiki:1.41

LABEL name="TechTangent's MediaWiki"

# Install Composer (Reference: https://getcomposer.org/download/)
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" &&\
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# Fix PHP stuff (idk what this fixes, it's been too long)
RUN echo -e "memory_limit = 50M\npost_max_size = 50M\nupload_max_filesize = 50M" > /usr/local/etc/php/conf.d/99-Wiki.ini

# Install composer based extensions
RUN cd /var/www/html/ \
	&& composer require mediawiki/semantic-media-wiki --update-no-dev \
	&& composer require mediawiki/semantic-result-formats --update-no-dev \
	&& composer require mediawiki/semantic-compound-queries --update-no-dev \
	&& composer require professional-wiki/id-generator --update-no-dev


# Need to execute program here, eg.
# CMD ["php-fpm"]

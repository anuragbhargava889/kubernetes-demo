FROM php:8.1-apache

# 1. Install development packages and clean up apt cache.
RUN apt-get update && apt-get install -y \
    curl \
    g++ \
    git \
    libbz2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libicu-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libpng-dev \
    libreadline-dev \
    libxml2-dev \
    libgd-dev \
    libonig-dev \
    jpegoptim optipng pngquant gifsicle \
    libzip-dev \
    sudo \
    netcat-traditional \
    iputils-ping \
    telnet \
    unzip \
    cron \
    zip \
    openssh-server && echo "root:Docker!" | chpasswd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*  \
    && apt-get autoremove --purge -y  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 2. Apache configs + document root.
ARG APACHE_SERVER_NAME
RUN echo "ServerName $APACHE_SERVER_NAME" >> /etc/apache2/apache2.conf

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
ENV APACHE_LOG_DIR=/var/log
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 3. mod_rewrite for URL rewrite and mod_headers for .htaccess extra headers like Access-Control-Allow-Origin-
RUN a2enmod rewrite headers

# 4. Start with base PHP config, then add extensions.
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
RUN sed -i -e "s/^ *memory_limit.*/memory_limit = -1/g" "$PHP_INI_DIR/php.ini"
RUN sed -i -e "s/^ *max_execution_time.*/max_execution_time = 360000/g" "$PHP_INI_DIR/php.ini"
RUN sed -i -e "s/^ *upload_max_filesize.*/upload_max_filesize = 1024M/g" "$PHP_INI_DIR/php.ini"
RUN sed -i -e "s/^ *post_max_size.*/post_max_size = 1024M/g" "$PHP_INI_DIR/php.ini"
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg && docker-php-ext-install \
    bcmath \
    bz2 \
    calendar \
    iconv \
    intl \
    opcache \
    pdo \
    pdo_mysql \
    sockets \
    gd \
    zip

# 5. Composer setting.
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 6. We need a user with the same UID/GID as the host user
# so when we execute CLI commands, all the host file's permissions and ownership remain intact.
# Otherwise commands from inside the container would create root-owned files and directories.
ARG uid
RUN useradd -G www-data,root -u $uid -d /home/devuser devuser && \
    mkdir -p /home/devuser/.composer && \
    chown -R devuser:devuser /home/devuser

# 8. Copy apache config file and create mount folder for images.
COPY ./apache-config/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY ./run-migration.sh /tmp
RUN chmod a+x /tmp/run-migration.sh

# 9. Copy files
WORKDIR /var/www/html
COPY . .
RUN chown -R devuser:www-data /var/www/html && \
    chown -R devuser:www-data /var/www/html/storage && \
    chmod -R 0777 /var/www/html/storage && \
    mkdir -p /var/www/html/public/uploads && \
    chmod -R 0777 /var/www/html/public/uploads

#10. Composer install and clear config and expose port
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN set -eux && \
    composer install --optimize-autoloader
EXPOSE 80 443
ENTRYPOINT ["/tmp/run-migration.sh"]
CMD ["apache2-foreground"]


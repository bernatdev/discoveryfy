#Based on:
# https://github.com/MilesChou/docker-phalcon
# https://github.com/npulidom/alpine-nginx-php/blob/master/Dockerfile
# https://github.com/npulidom/alpine-phalcon/blob/master/Dockerfile
# https://github.com/phalcon/vokuro/blob/master/resources/Dockerfile
# https://hub.docker.com/r/kiksaus/kikdev/dockerfile

# Build arguments
ARG OS_TIMEZONE="Europe/Andorra"
ARG PHP_VERSION=7.4
ARG PHP_VARIANT=-fpm-alpine
# https://medium.com/@chamilad/lets-make-your-docker-image-better-than-90-of-existing-ones-8b1e5de950d
# --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
# --build-arg BUILD_VERSION=$(date -u +'%Y%m%d')
# https://github.com/thibaultdelor/testAutobuildHooks/blob/master/hooks/build
#ARG BUILD_DATE
ARG BUILD_VERSION="20200715"

# Based on official PHP image with Phalcon ( php:7.4-fpm-alpine + Phalcon + Psr )
FROM mileschou/phalcon:${PHP_VERSION}${PHP_VARIANT}

# OS alpine 3.11
#FROM nginx:1.19-alpine

# Alpine & nginx version
RUN cat /etc/os-release | grep PRETTY_NAME
# && nginx -v

LABEL maintainer="Leninux <leninux@fabri.cat>" \
      description="Discoveryfy Backend"

#LABEL org.opencontainers.image.created="${BUILD_DATE}" \
#      org.opencontainers.image.authors="Leninux"
#      org.opencontainers.image.url="https://github.com/weart/discoveryfy"
#      org.opencontainers.image.documentation="https://api.discoveryfy.fabri.cat/docs"
#      org.opencontainers.image.version="${BUILD_VERSION}"
#      org.opencontainers.image.licenses="GPL-3.0"

# Environment vars
#ENV OS_TIMEZONE=$OS_TIMEZONE
#ENV FCGI_CONNECT=/var/run/php-fpm.sock \
#	PHP_FPM_PM=dynamic \
#	PHP_FPM_PM_MAX_CHILDREN=5 \
#	PHP_FPM_PM_START_SERVERS=2 \
#	PHP_FPM_PM_MIN_SPARE_SERVERS=1 \
#	PHP_FPM_PM_MAX_SPARE_SERVERS=3 \
#	PHP_FPM_PM_PROCESS_IDLE_TIMEOUT=10 \
#	PHP_FPM_PM_MAX_REQUESTS=0 \
##	PHP_FPM_ACCESS_FORMAT %R - %u %t \\\"%m %r\\\" %s

# Install docker help scripts
#COPY src/php/utils/docker/ /usr/local/bin/
#COPY src/php/utils/install-* /usr/local/bin/

ENV APP_ENV=production \
	APP_DEBUG=false \
	APP_URL=https://api.discoveryfy.fabri.cat \
	APP_BASE_URI=/ \
	APP_SUPPORT_EMAIL=user@dom.ain \
	APP_TIMEZONE=UTC \
	APP_VERSION=${BUILD_VERSION} \
	PRIVATE_KEY=/tmp/jwt.pem \
	PRIVATE_KEY_PASSWORD=pass \
	SESSION_TTL=86400 \
#	LOG_FILENAME=api.log \
#	LOG_PATH=logs/ \
#	LOG_FORMAT="[%datetime%] %channel%.%level_name%: %message%" \
#	LOG_FORMAT_DATE=Y-m-d\TH:i:sP \
#	LOG_CHANNEL=api \
	TOKEN_ISS=dom.ain \
	TOKEN_AUDIENCE=client.dom.ain \
	TOKEN_NOT_BEFORE=10 \
	TOKEN_EXPIRATION=86400 \
	REDIS_HOST=discoveryfy_redis \
	CACHE_PREFIX=api_cache_ \
	CACHE_LIFETIME=86400 \
	MYSQL_HOST=discoveryfy_sql \
	MYSQL_DATABASE=discoveryfy \
	MYSQL_USER=user \
	MYSQL_PASSWORD=pass \
	INFLUXDB_HOST=discoveryfy_monitor \
	INFLUXDB_DATABASE=discoveryfy \
	INFLUXDB_USER=user \
	INFLUXDB_PASSWORD=pass \
	SEED_ROOT_USER=user \
	SEED_ROOT_PASS=pass \
	SEED_ROOT_MAIL=user@dom.ain

# Define /etc/localtime && /etc/timezone
#RUN apk update && apk add tzdata
#RUN cp /usr/share/zoneinfo/$OS_TIMEZONE /etc/localtime && echo $OS_TIMEZONE > /etc/timezone && date
# Remove other timezones
#RUN apk del tzdata

RUN apk update && apk add --no-cache \
#	wget \
	curl \
#	git \
#	php-gd \
#	php-fpm
# Redis
#	php-pdo \
#	php-redis \
# MySQL
#	php-mysql \
# ZIP
	libzip-dev \
#	php-zlib \
# Already installed / https://github.com/jbboehr/php-psr
#	php-phalcon \
#	php-psr \
#	&& rm -rf /var/cache/apk/*  \
# https://github.com/mlocati/docker-php-extension-installer
# ZIP & pcntl
	&& docker-php-ext-configure pcntl --enable-pcntl \
#	&& docker-php-ext-configure zip --with-libzip=/usr/include \
	&& pecl install redis \
	&& docker-php-ext-install \
#	curl \
#	redis \
#	mysqli \
	pdo_mysql \
	zip \
	pcntl \
	&& docker-php-ext-enable \
	redis

# set www-data group (82 is the standard uid/gid for www-data in Alpine)
#RUN set -x; \
#	addgroup -g 82 -S www-data; \
#	adduser -u 82 -D -S -G www-data www-data && exit 0; exit 1
# Add vmuser user & group
RUN set -x; \
	addgroup -g 922 -S vmuser; \
	adduser -u 666 -D -S -G vmuser vmuser && exit 0; exit 1
#	adduser --disabled-password --no-create-home --shell /sbin/nologin --uid 666 --ingroup vmuser vmuser

# Create a symlink to the recommended production configuration
# ref: https://github.com/docker-library/docs/tree/master/php#configuration
RUN ln -s $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

# Use nginx custom configuration files
# Done in docker-nginx-entrypoint
#RUN rm /etc/nginx/conf.d/default.conf
#COPY /var/www/storage/nginx/nginx.conf /etc/nginx/nginx.conf
#COPY /var/www/storage/nginx/vhost.conf /etc/nginx/sites-enabled/default
#COPY /var/www/storage/nginx/php-fpm.conf /etc/php7/php-fpm.d/www.conf

USER www-data

WORKDIR /var/www
RUN rm ./html
COPY --chown=www-data:www-data ./api/bin ./bin
COPY --chown=www-data:www-data ./api/config ./config
COPY --chown=www-data:www-data ./api/discoveryfy ./discoveryfy
COPY --chown=www-data:www-data ./api/phalcon-api ./phalcon-api
COPY --chown=www-data:www-data ./api/public ./public
COPY --chown=www-data:www-data ./api/vendor ./vendor
#RUN mkdir -p ./vendor
#COPY --chown=www-data:www-data ./tests ./tests
COPY --chown=www-data:www-data ./api/composer.json ./api/composer.lock ./
COPY --chown=www-data:www-data ./api/.htaccess ./api/index.html ./api/phinx.php ./
#COPY --chown=www-data:www-data codeception.yml psalm.xml.dist ./
# Avoid reading .env file in each request in prod
#COPY --chown=www-data:www-data ./api/.env.prod ./.env
COPY --chown=www-data:www-data ./api/storage/db/migrations ./db_migrations
COPY --chown=www-data:www-data ./api/storage/db/seeds ./db_seeds

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin:/var/www/vendor/bin"
RUN set -eux; \
	composer install --prefer-dist --no-scripts --no-progress --no-suggest; \
	composer clear-cache; \
	composer dump-autoload --classmap-authoritative --no-dev

#ENTRYPOINT ["/var/www/storage/nginx/docker-nginx-entrypoint"]
ENTRYPOINT ["docker-php-entrypoint"]
EXPOSE 9000

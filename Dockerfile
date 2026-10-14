# syntax=docker/dockerfile:1

# ---- base: PHP-FPM with the extensions Laravel needs ----
FROM php:8.4-fpm-alpine AS base

RUN apk add --no-cache icu-dev libzip-dev \
 && docker-php-ext-install pdo_mysql intl zip bcmath opcache

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# ---- dev: the project folder is bind-mounted by docker-compose.yml ----
FROM base AS dev

# ---- prod: code and dependencies baked into the image ----
FROM base AS prod

COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Install dependencies first so this layer is cached until composer.lock changes.
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction

COPY . .
RUN composer dump-autoload --optimize --no-dev \
 && chown -R www-data:www-data storage bootstrap/cache

USER www-data

# Laravel Docker Starter

[![CI](https://github.com/Mominde92/laravel-docker-starter/actions/workflows/ci.yml/badge.svg)](https://github.com/Mominde92/laravel-docker-starter/actions/workflows/ci.yml)
![PHP](https://img.shields.io/badge/PHP-8.4-777BB4?logo=php&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-1.27-009639?logo=nginx&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.4-4479A1?logo=mysql&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)

A small, production-minded Docker Compose setup for Laravel: **Nginx + PHP-FPM 8.4 + MySQL 8.4**.
Drop it into any Laravel project and get the same environment on every laptop and server.

Every push is tested in CI: a fresh Laravel app is created, the stack is started, migrations run,
the home page must answer `200` through Nginx, `/.env` must be blocked, and the production image must build.

## What you get

| File | Purpose |
|---|---|
| `Dockerfile` | Multi-stage image: `dev` (code mounted from your machine) and `prod` (code + optimized autoloader baked in, runs as `www-data`). |
| `docker-compose.yml` | `app` (PHP-FPM), `web` (Nginx) and `db` (MySQL with a healthcheck, so PHP starts only when the database is ready). |
| `docker/nginx/default.conf` | Serves `public/` only, passes PHP to FPM, hides dot-files such as `.env` and `.git`. |
| `docker/php/opcache.ini` | OPcache tuned for production images. |
| `Makefile` | Short commands for daily work. |

## Quick start

Copy `Dockerfile`, `docker-compose.yml`, `.dockerignore`, `Makefile` and the `docker/` folder into your Laravel project, then set the database in `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
```

```bash
make install     # build, start, composer install, key:generate, migrate
```

Open http://localhost:8080. Without `make`:

```bash
docker compose up -d --build --wait
docker compose exec app composer install
docker compose exec app chown -R www-data:www-data storage bootstrap/cache
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate
```

## Daily commands

```bash
make up          # start
make down        # stop
make shell       # shell inside the PHP container
make migrate     # run migrations
make test        # php artisan test
make logs        # follow logs
```

## Things that trip people up

- **`DB_HOST=127.0.0.1` does not work.** Inside a container that address is the container itself. Use the service name `db`.
- **`DB_USERNAME` cannot be `root`.** The MySQL image creates `DB_USERNAME` as a normal user; the root password is `DB_ROOT_PASSWORD`.
- **"Permission denied" in `storage/`.** PHP-FPM runs as `www-data`; run `make perms` once.
- **Port 8080 is taken.** Set `APP_PORT=8081` in `.env`.

## Production

```bash
make prod-image   # docker build --target prod -t laravel-app:prod .
```

The `prod` stage installs dependencies without dev packages, copies the code into the image, optimizes the autoloader and drops root.
For a real deployment also:

- build the image in CI and deploy a tagged version, so servers run exactly what was tested;
- keep secrets out of the image (environment variables or Docker secrets, never a committed `.env`);
- run `php artisan config:cache route:cache view:cache` on start;
- do not publish the MySQL port, and back up the `dbdata` volume.

A step-by-step explanation of this setup is on my blog: [Dockerizing a Laravel app with Docker Compose](https://moumen-dev.com/blog/docker-compose-laravel/).

## Author

**Moamen Derine**, Senior Full Stack Developer & DevOps Engineer in Dubai.
[moumen-dev.com](https://moumen-dev.com) · [LinkedIn](https://www.linkedin.com/in/momin-derine/)

## License

[MIT](LICENSE)

.PHONY: up down restart logs shell install migrate test perms prod-image

up:            ## Start the stack in the background
	docker compose up -d --build --wait

down:          ## Stop the stack
	docker compose down

restart: down up

logs:          ## Follow all logs
	docker compose logs -f

shell:         ## Open a shell in the PHP container
	docker compose exec app sh

install: up perms  ## First run: dependencies, app key, database
	docker compose exec app composer install
	docker compose exec app php artisan key:generate
	docker compose exec app php artisan migrate

migrate:
	docker compose exec app php artisan migrate

test:
	docker compose exec app php artisan test

perms:         ## Let PHP-FPM (www-data) write to storage and cache
	docker compose exec app chown -R www-data:www-data storage bootstrap/cache

prod-image:    ## Build the production image
	docker build --target prod -t laravel-app:prod .

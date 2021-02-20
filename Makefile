#
# php-makefile
#
# Creates a new composer-managed PHP project in a subdirectory called "webroot".
#
# REQUIREMENTS: 
#   * working "docker" CLI
#   * GNU Make
#
# USAGE:
#
#   # Initialize a new PHP 8.0.2 project
#   $ export PHP_VERSION=8.0.2
#   $ export PHP_PORT=8888
#   $ make cinit
#   $ vim composer.json  # add packages
#   $ make cupdate
#   $ make cinstall
#   $ make serve
#   # Browse to http://localhost/phpinfo.php
#
#   # Arbitrary composer commnads: Get the composer version
#   $ make cdo ARGS="-V"
#

PHP_VERSION ?= 8.0.2
PHP_PORT ?= 8888

.PHONY: cinit cinstall cdo cupdate serve

cinit:
	@echo "-> php-makefile"
	@echo "->"
	@echo "-> Initializing PHP project with php-$(PHP_VERSION)"
	@echo "-> Will fail if webroot/ already exists"
	@mkdir -m 777 webroot
	@docker run --rm --interactive --tty \
		--volume $(shell pwd)/webroot:/app:rw \
		--user $(shell id -u):$(shell id -g) \
		composer:latest -n -v --ansi \
			--name=organization/project \
			--description="Sample project by Organization" \
			--author="Some One <someone@somewhere.com>" \
			--homepage="https://example.somewhere.com/" \
			--license=NONE \
			--type=project \
			init
	@chmod 755 webroot
	@echo '<? phpinfo() ?>' > webroot/phpinfo.php
	@echo 'Writing /phpinfo.php'
	@echo '<html><body><h1>php-makefile placeholder index</h1></body></html>' > webroot/index.html
	@echo 'Writing /index.php'
	@echo
	@echo 'Run "make serve" and visit /phpinfo.php'

cupdate:
	@mkdir -p -m 777 webroot
	@docker run --rm --interactive --tty \
		--volume $(shell pwd)/webroot:/app:rw \
		--user $(shell id -u):$(shell id -g) \
		composer:latest -n -v --ansi update $(ARGS)
	@chmod 755 webroot

cinstall:
	@chmod 777 webroot
	@docker run --rm --interactive --tty \
		--volume $(shell pwd)/webroot:/app:rw \
		--user $(shell id -u):$(shell id -g) \
		composer:latest -n -v --ansi \
			install
	@chmod 755 webroot

cdo:
	@mkdir -p -m 777 webroot
	@docker run --rm --interactive --tty \
		--volume $(shell pwd)/webroot:/app:rw \
		--user $(shell id -u):$(shell id -g) \
		composer:latest -n -v --ansi $(ARGS)
	@chmod 755 webroot

serve:
	docker run -p $(PHP_PORT):80 \
		--volume $(shell pwd)/webroot:/var/www/html:ro \
		php:$(PHP_VERSION)-apache


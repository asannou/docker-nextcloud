IMAGE := asannou/nextcloud
PROXY_IMAGE := asannou/nextcloud-sharing-only-proxy
NAME := nextcloud
PROXY_NAME := nextcloud-proxy
PORT := 8000
SHARING_PORT := 80
ROOT := /var/www/nextcloud
# www-data
UID := 33

up: web proxy

proxy: web
	docker run -d --name $(PROXY_NAME) -p $(PORT):$(PORT) -p $(SHARING_PORT):$(SHARING_PORT) --link $(NAME) $(PROXY_IMAGE)

web: volumes
	docker run -d --name $(NAME) -v $(CURDIR)/config.php:$(ROOT)/config/config.php -v $(CURDIR)/data:$(ROOT)/data $(IMAGE)

volumes: config.php data
	chown $(UID):root $+

config.php:
	touch $@

data:
	mkdir -p $@

down:
	docker rm -f $(PROXY_NAME) $(NAME)

build:
	docker build -t $(IMAGE) . && docker build -t $(PROXY_IMAGE) proxy

.PHONY: up proxy web volumes down build

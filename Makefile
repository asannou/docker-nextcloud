IMAGE := asannou/nextcloud
PROXY_IMAGE := asannou/nextcloud-sharing-only-proxy
NAME := nextcloud
PROXY_NAME := nextcloud-proxy
PORT := 8000
SHARING_PORT := 80
ROOT := /var/www/nextcloud

up: proxy-fail2ban web

proxy-fail2ban: proxy
	docker exec $(PROXY_NAME) service fail2ban start

proxy: web
	docker run -d --cap-add=NET_ADMIN --name $(PROXY_NAME) -p $(PORT):$(PORT) -p $(SHARING_PORT):$(SHARING_PORT) --link $(NAME) $(PROXY_IMAGE)

web: volumes
	docker run -d --name $(NAME) -v $(CURDIR)/config.php:$(ROOT)/config/config.php -v $(CURDIR)/data:$(ROOT)/data $(IMAGE)

volumes: config.php data

config.php:
	touch $@

data:
	mkdir -p $@

down:
	docker rm -f $(PROXY_NAME) $(NAME)

build: image proxy-image

image:
	docker build -t $(IMAGE) .

proxy-image:
	docker build -t $(PROXY_IMAGE) proxy

pull:
	docker pull $(IMAGE) && docker pull $(PROXY_IMAGE)

.PHONY: up proxy-fail2ban proxy web volumes down build image proxy-image pull


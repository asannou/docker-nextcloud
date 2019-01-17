IMAGE := asannou/nextcloud:14-strict
PROXY_IMAGE := asannou/nextcloud-sharing-only-proxy:14-strict
NAME := nextcloud
PROXY_NAME := nextcloud-proxy
PORT := 8000
SHARING_PORT := 80

up: proxy web

proxy: web
	docker run -d --cap-add=NET_ADMIN --name $(PROXY_NAME) -p $(PORT):$(PORT) -p $(SHARING_PORT):$(SHARING_PORT) --link $(NAME) $(PROXY_IMAGE)

web:
	docker run -d --name $(NAME) -v $(CURDIR)/volume:/volume $(IMAGE)

down:
	docker rm -f $(PROXY_NAME) $(NAME)

build: image proxy-image

image:
	docker build -t $(IMAGE) .

proxy-image:
	docker build -t $(PROXY_IMAGE) proxy

pull:
	docker pull $(IMAGE) && docker pull $(PROXY_IMAGE)

.PHONY: up proxy web down build image proxy-image pull


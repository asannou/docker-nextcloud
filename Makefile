include .env

IMAGE_TAG := $(DOCKER_NEXTCLOUD_IMAGE_VERSION)$(DOCKER_NEXTCLOUD_IMAGE_BRANCH)
IMAGE := asannou/nextcloud:$(IMAGE_TAG)
PROXY_IMAGE := asannou/nextcloud-sharing-only-proxy:$(IMAGE_TAG)
NAME := nextcloud
PROXY_NAME := nextcloud-proxy
PORT := 8000
SHARING_PORT := 80

up: proxy web

proxy: web
	docker run -d --name $(PROXY_NAME) -p $(PORT):$(PORT) -p $(SHARING_PORT):$(SHARING_PORT) --link $(NAME) $(PROXY_IMAGE)

web:
	docker run -d --name $(NAME) -v $(CURDIR)/volume:/volume -v $(CURDIR)/volume/$(NAME):/var/www/html $(IMAGE)

down:
	docker rm -f $(PROXY_NAME) $(NAME)

build: image proxy-image

image:
	docker build -t $(IMAGE) --build-arg version=$(DOCKER_NEXTCLOUD_IMAGE_VERSION) .

proxy-image:
	docker build -t $(PROXY_IMAGE) proxy

pull:
	docker pull $(IMAGE) && docker pull $(PROXY_IMAGE)

push:
	docker push $(IMAGE) && docker push $(PROXY_IMAGE)

.PHONY: up proxy web down build image proxy-image pull


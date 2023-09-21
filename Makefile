include .env

IMAGE_TAG := $(DOCKER_NEXTCLOUD_IMAGE_VERSION)$(DOCKER_NEXTCLOUD_IMAGE_BRANCH)
IMAGE := asannou/nextcloud:$(IMAGE_TAG)
PROXY_IMAGE := asannou/nextcloud-sharing-only-proxy:$(IMAGE_TAG)
ANTIVIRUS_IMAGE := clamav/clamav:stable_base
NAME := nextcloud
PROXY_NAME := nextcloud-proxy
ANTIVIRUS_NAME := clamav
PORT := 8000
SHARING_PORT := 80

up: proxy web antivirus

proxy: web
	docker run -d --name $(PROXY_NAME) -p $(PORT):$(PORT) -p $(SHARING_PORT):$(SHARING_PORT) --link $(NAME) $(PROXY_IMAGE)

web: antivirus
	docker run -d --name $(NAME) -v $(CURDIR)/volume:/volume -v $(CURDIR)/volume/$(NAME):/var/www/html -e FORCE_MAINTENANCE_MODE_OFF --link $(ANTIVIRUS_NAME) $(IMAGE)

antivirus:
	docker run -d --name $(ANTIVIRUS_NAME) -v $(CURDIR)/volume/clamav/virus_db/:/var/lib/clamav/ $(ANTIVIRUS_IMAGE)

down:
	docker rm -f $(PROXY_NAME) $(NAME) $(ANTIVIRUS_NAME)

build: image proxy-image

image:
	docker build -t $(IMAGE) --build-arg version=$(DOCKER_NEXTCLOUD_IMAGE_VERSION) .

proxy-image:
	docker build -t $(PROXY_IMAGE) proxy

pull:
	docker pull $(IMAGE) && docker pull $(PROXY_IMAGE) && docker pull $(ANTIVIRUS_IMAGE)

push:
	docker push $(IMAGE) && docker push $(PROXY_IMAGE)

.PHONY: up proxy web antivirus down build image proxy-image pull


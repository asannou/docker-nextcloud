
```
$ sudo docker run -d --name nextcloud -v $(pwd)/volume:/volume asannou/nextcloud:15
$ sudo docker run -d --cap-add=NET_ADMIN --name nextcloud-proxy -p 8000:8000 -p 80:80 --link nextcloud asannou/nextcloud-sharing-only-proxy:15
```

or

```
$ git clone https://github.com/asannou/docker-nextcloud.git
$ cd docker-nextcloud
$ sudo make up
```

or

```
$ git clone https://github.com/asannou/docker-nextcloud.git
$ cd docker-nextcloud
$ sudo docker-compose up -d
```

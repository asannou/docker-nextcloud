
```
$ sudo docker run -d --name nextcloud -v $(pwd)/volume:/volume asannou/nextcloud:15-bigfile
$ sudo docker run -d --cap-add=NET_ADMIN --name nextcloud-proxy -p 8000:8000 -p 80:80 --link nextcloud asannou/nextcloud-sharing-only-proxy:15-bigfile
```

or

```
$ sudo make up
```

or

```
$ sudo docker-compose up -d
```

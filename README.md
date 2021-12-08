
```
$ sudo docker run -d --name nextcloud -v $(pwd)/volume:/volume asannou/nextcloud:21-strict
$ sudo docker run -d --name nextcloud-proxy -p 8000:8000 -p 80:80 --link nextcloud asannou/nextcloud-sharing-only-proxy:21-strict
```

or

```
$ sudo make up
```

or

```
$ sudo docker-compose up -d
```

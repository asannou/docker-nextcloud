
```
$ sudo docker run -d --name nextcloud -v $(pwd)/volume:/volume asannou/nextcloud:26
$ sudo docker run -d --name nextcloud-proxy -p 8000:8000 -p 80:80 --link nextcloud asannou/nextcloud-sharing-only-proxy:26
```

or

```
$ sudo make up
```

or

```
$ sudo docker-compose up -d
```


```
$ touch /path/to/config.php
$ docker run -d -P -v /path/to/config.php:/var/www/nextcloud/config/config.php -v /path/to/data:/var/www/nextcloud/data --name nextcloud asannou/nextcloud
```

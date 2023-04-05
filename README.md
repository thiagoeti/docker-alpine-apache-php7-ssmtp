# Docker - Alpine - Apache / PHP and SSMTP

Container to run PHP.

Create **data**.

```console
mkdir "/data"
mkdir "/data/www"
```

Create **log**.

```console
mkdir "/data/log"
mkdir "/data/log/www"
mkdir "/data/log/apache"
mkdir "/data/log/www/app-php7-ssmtp"
```

Create repository for **app**.

```console
mkdir "/data/www/app-php7-ssmtp"
mkdir "/data/www/app-php7-ssmtp/log"
```

Configure **SMTP**.

```console
root=postmaster
mailhub=email-ssl.com.br:587
FromLineOverride=YES
rewriteDomain=email.com
AuthUser=user@email.com
AuthPass=***
hostname=email.com
UseTLS=YES
UseSTARTTLS=YES
```

> Important: **./ssmtp/ssmtp.conf** configuration sendmail.

#### Dockerfile

File *dockerfile* for mount machine.

```dockerfile
# so
FROM alpine:latest

# by
MAINTAINER Thiago Silva - thiagoeti@gmail.com

# repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> "/etc/apk/repositories"

# update
RUN apk --no-cache update && apk --no-cache upgrade

# bash
RUN apk add bash

# ssmtp
RUN apk add ssmtp
COPY ./ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf

# apache
RUN apk add apache2 && \
	apk add apache2-utils && \
	apk add libxml2-dev && \
	sed -i '/LoadModule rewrite_module/s/^#//g' /etc/apache2/httpd.conf && \
	sed -i '/LoadModule expires_module/s/^#//g' /etc/apache2/httpd.conf && \
	sed -i '/LoadModule deflate_module/s/^#//g' /etc/apache2/httpd.conf && \
	sed -i 's#AllowOverride [Nn]one#AllowOverride All#' /etc/apache2/httpd.conf && \
	sed -i 's#Options Indexes FollowSymLinks#Options -Indexes#' /etc/apache2/httpd.conf && \
	sed -i 's#ServerAdmin you@example.com#ServerAdmin thiagoeti@gmail.com#' /etc/apache2/httpd.conf
COPY ./apache/git.conf /etc/apache2/conf.d/git.conf
COPY ./apache/general.conf /etc/apache2/conf.d/general.conf

# php
RUN apk add php7 && \
	apk add php7-apache2 && \
	apk add php7-common && \
	apk add php7-opcache && \
	apk add php7-fpm && \
	apk add php7-session && \
	apk add php7-openssl && \
	apk add php7-mysqli && \
	apk add php7-mysqlnd && \
	apk add php7-pgsql && \
	apk add php7-pdo && \
	apk add php7-pdo_mysql && \
	apk add php7-pdo_pgsql && \
	apk add php7-pdo_sqlite && \
	apk add php7-sockets && \
	apk add php7-curl && \
	apk add php7-ftp && \
	apk add php7-json && \
	apk add php7-gd && \
	apk add php7-iconv && \
	apk add php7-soap && \
	apk add php7-xml && \
	apk add php7-xmlwriter && \
	apk add php7-xmlreader && \
	apk add php7-simplexml && \
	apk add php7-dom && \
	apk add php7-xsl && \
	apk add php7-fileinfo && \
	apk add php7-zip && \
	apk add php7-zlib && \
	apk add php7-mbstring && \
	apk add php7-tokenizer && \
	apk add php7-ctype && \
	apk add php7-phar

# clear
RUN rm -rfv /var/cache/apk/*

# ports
EXPOSE 80 443

# www
RUN mkdir /data && \
	mkdir /data/log && \
	mkdir /data/public && \
	rm -rfv /var/www/localhost/htdocs && \
	ln -fs /data/public /var/www/localhost/htdocs

# work
WORKDIR /data

# start httpd
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]
```

## Build Machine

```console
docker build --no-cache -t "alpine-apache-php7-ssmtp" "/data/container/alpine-apache-php7-ssmtp/."
```

### APP

Copy script for test APP.

```console
cp -rfv "/data/container/alpine-apache-php7-ssmtp/_app/" "/data/www/app-php7-ssmtp"
```

Run container APP.

```console
docker run --name "app-php7-ssmtp" \
	-p 7001:80 \
	-v "/etc/hosts":"/etc/hosts" \
	-v "/data/log/apache/app-php7-ssmtp":"/var/log/apache2" \
	-v "/data/log/www/app-php7-ssmtp":"/data/log" \
	-v "/data/www/app-php7-ssmtp":"/data" \
	--restart=always \
	-d "alpine-apache-php7-ssmtp":"latest"
```

> Important: **/etc/hosts** shared to configuration all server.

Attach container.

```console
docker attach "app-php7-ssmtp"
docker exec -it "app-php7-ssmtp" "/bin/bash"
```

Run in container.

```console
docker exec -d "app-php7-ssmtp" "/bin/bash" php -v
```

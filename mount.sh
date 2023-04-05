#!/bin/sh

# data
mkdir "/data"
mkdir "/data/www"

# log
mkdir "/data/log"
mkdir "/data/log/www"
mkdir "/data/log/apache"
mkdir "/data/log/www/app-php7-ssmtp"

# app
mkdir "/data/www/app-php7-ssmtp"
mkdir "/data/www/app-php7-ssmtp/log"

# drop
docker rmi -f "alpine-apache-php7-ssmtp"

# build
docker build --no-cache -t "alpine-apache-php7-ssmtp" "/data/container/alpine-apache-php7-ssmtp/."

# test
rm -rfv "/data/www/app-php7-ssmtp"
cp -rfv "/data/container/alpine-apache-php7-ssmtp/_app/" "/data/www/app-php7-ssmtp"

# drop
docker rm -f "app-php7-ssmtp"

# run -> app
docker run --name "app-php7-ssmtp" \
	-p 7002:80 \
	-v "/etc/hosts":"/etc/hosts" \
	-v "/data/log/apache/app-php7-ssmtp":"/var/log/apache2" \
	-v "/data/log/www/app-php7-ssmtp":"/data/log" \
	-v "/data/www/app-php7-ssmtp":"/data" \
	--restart=always \
	-d "alpine-apache-php7-ssmtp":"latest"

# attach
docker attach "app-php7-ssmtp"
docker exec -it "app-php7-ssmtp" "/bin/bash"

# start
docker start "app-php7-ssmtp"

# app

docker exec -d "app-php7-ssmtp" "/bin/bash" php -v

#

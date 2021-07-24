#!/bin/sh

curl -sL https://deb.nodesource.com/setup_16.x \
     | sudo /bin/bash - \
    || exit 1

sudo apt-get -y install nodejs \
    || exit 2

node --version \
    || exit 3

exit 0

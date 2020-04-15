#!/bin/bash

vector --config /etc/vector/vector.toml -vv &
/etc/init.d/nginx start

tail -f /var/log/nginx/access.log -f /var/log/nginx/error.log -f /var/log/vector.log
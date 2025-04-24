#!/bin/sh
# Replace environment variables in nginx config
envsubst '$ALB_DNS' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Start nginx
exec "$@"

#!/bin/sh

# Replace environment variables in the Nginx configuration
envsubst '$ALB_DNS' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Execute CMD
exec "$@"

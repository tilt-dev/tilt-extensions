#!/bin/sh

port="${PORT:-8080}"
echo "Serving files on port $port"
busybox httpd -f -p "$port"

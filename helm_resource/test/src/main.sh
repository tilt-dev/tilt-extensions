#!/bin/sh

echo "Serving files on port 80"
busybox httpd -f -p 80

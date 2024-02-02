#!/bin/sh

echo "Serving files on sport 8000"
busybox httpd -f -p 8000

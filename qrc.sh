#!/usr/bin/env bash
# Desc: QR Code generator for links
# requirements: qrencode
# Author: Chad Estoup--Streiff 

# Check if qrencode exists
if ! command -v qrencode &> /dev/null
then
    echo "qrencode could not be found"
    exit
fi

# Check if url is set
if [ $# -eq 0 ]
then
    qrencode -o /tmp/qrcode.png "$(xclip -o)"
else
    qrencode -o /tmp/qrcode.png "$1"
fi

xdg-open /tmp/qrcode.png
cp /tmp/qrcode.png ./qrcode.png
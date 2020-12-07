#!/bin/sh

if [ -s /root/root.key ]
then
    return 1
else
    return 0
fi


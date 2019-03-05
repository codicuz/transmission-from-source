#!/bin/bash

if [ -f /trans/config/settings.json ]; then
  echo "Symbolic link exists"
else
  echo "Symbolic link not exist. Creating..."
  ln -s /opt/transmission/settings.json /trans/config/settings.json
  echo "Symbolic link created."
fi

/opt/transmission/bin/transmission-daemon -f -T -t -u ${ADM_USER} -v ${ADM_PASSWD} -c /trans/watch --incomplete-dir /trans/incomplete -w /trans/complete -g /trans/config
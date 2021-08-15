#!/bin/sh

#while true; do sleep 60; done

# Allow other containers to stabilise
sleep 20

cd /app

echo "starting cron"
service cron start

if [ ! -f noflask ]; then
  echo "starting gunicorn"
  export PYTHONUNBUFFERED=1
  exec gunicorn -b :5000 --timeout 300 --limit-request-line 0 --worker-class gthread --keep-alive 5 --workers=2 --graceful-timeout 900 --access-logfile /config/log/access.log --error-logfile /config/log/error.log --capture-output --log-level debug app:app 
fi

while true; do sleep 60; done


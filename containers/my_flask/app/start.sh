#!/bin/sh

#while true; do sleep 60; done

# Allow other containers to stabilise
sleep 20

cd /app

echo "starting cron"
service cron start

echo "updating reference files"
./update_imgt.sh


if [ ! -f /ogre/attachments/noflask ]; then
echo "migrating database"

  if [ ! -f migrations/README ]; then
    echo "creating migrations database"
    rm -rf migrations
    flask db init
  fi
  flask db migrate
  flask db upgrade

  echo "starting gunicorn"
  export PYTHONUNBUFFERED=1
  exec gunicorn -b :5000 --timeout 300 --limit-request-line 0 --worker-class gthread --keep-alive 5 --workers=2 --graceful-timeout 900 --access-logfile /config/log/access.log --error-logfile /config/log/error.log --capture-output --log-level debug app:app --pid /app/gunicorn.pid
fi

while true; do sleep 60; done




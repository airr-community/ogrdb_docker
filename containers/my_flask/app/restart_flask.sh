kill -HUP `cat /app/gunicorn.pid`

slug=ogrdb-restart
/usr/local/bin/python /app/healthchecks.py $slug success
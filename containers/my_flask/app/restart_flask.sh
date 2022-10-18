kill -HUP `cat /app/gunicorn.pid`

slug=ogrdb-restart
python /app/healthchecks.py $slug success
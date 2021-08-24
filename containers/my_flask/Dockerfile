FROM python:3

MAINTAINER William Lees william@lees.org.uk

RUN \ 
  rm -rf /app && \
  apt-get update && \
  apt-get -y install cron && \
  apt-get -y install vim && \
  apt-get -y install telnet && \
  apt-get -y install git && \
  apt-get -y install dos2unix && \
  apt-get -y install mariadb-client && \
  git clone https://github.com/airr-community/ogrdb.git /app && \
  mv /app/migrations /app/migrations.old && \
  mkdir -p /config/migrations && \
  ln -s /config/migrations /app/migrations
COPY app/* /app/
COPY app/cronjobs /etc/crontabs/root

RUN \
  pip install -r /app/requirements.txt && \
  pip install gunicorn && \
  chmod +x /app/start.sh && \
  chmod +x /app/do_backup.sh && \
  chmod +x /app/rotate.sh && \
  mkdir -p /backup/backup.daily && \
  mkdir -p /backup/backup.weekly && \
  mkdir -p /backup/backup.monthly && \
  cp /app/track_imgt_config.yaml /app/imgt/. && \
  cp /app/IMGT_REF*.* /app/static/docs/. && \
  cp /app/igpdb.fasta /app/static/docs/. && \
  cp /app/vdjbase.fasta /app/static/docs/. && \
  mkdir /app/imgt/imgt_files && \
  crontab /app/cronjobs
 
CMD ["/app/start.sh"]

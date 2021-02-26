# WSGI service environment

FROM ubuntu:18.04

# Set locale (i.e. for psql client_encoding)
RUN apt-get update && apt-get install -y locales \
    && locale-gen en_US.UTF-8
ENV LANG en_US.utf8

RUN apt-get update && apt-get install -y uwsgi uwsgi-plugin-python3 python3-pip && \
    pip3 install --no-cache --upgrade pip

ENV SERVICE_MOUNTPOINT='/'
# http://uwsgi-docs.readthedocs.io/en/latest/Options.html#buffer-size
ENV REQ_HEADER_BUFFER_SIZE=12288
ENV UWSGI_PROCESSES=1
ENV UWSGI_THREADS=4
ENV UWSGI_EXTRA=""

STOPSIGNAL SIGINT

ENTRYPOINT uwsgi --http-socket :9090 --buffer-size $REQ_HEADER_BUFFER_SIZE --processes $UWSGI_PROCESSES \
    --threads $UWSGI_THREADS $UWSGI_EXTRA --plugins python3 --protocol uwsgi --wsgi-disable-file-wrapper \
    --uid www-data --gid www-data --master --chdir /srv/qwc_service --mount $SERVICE_MOUNTPOINT=server:app \
    --manage-script-name

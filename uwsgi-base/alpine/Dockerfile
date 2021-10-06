# WSGI service environment

FROM alpine:3.13

RUN apk add --no-cache --update shadow python3 py3-pip uwsgi uwsgi-python3 && \
    pip3 install --no-cache --upgrade pip

# -> pip 21.2.4 from /usr/lib/python3.8/site-packages/pip (python 3.8)
# Alpine package has pip 20.3.4
# On alpine:3.9.5 we had
# pip 21.1 from /usr/lib/python3.6/site-packages/pip (python 3.6)

RUN usermod -u 32 xfs && \
    groupmod -g 32 xfs && \
    addgroup -g 33 -S www-data && \
    adduser -u 33 -D -S -h /var/www -s /sbin/nologin -G www-data www-data

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

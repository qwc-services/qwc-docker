# WSGI service environment

FROM alpine:3.9.5

RUN apk add --no-cache --update python3 uwsgi uwsgi-python3 && \
    pip3 install --no-cache --upgrade pip

ARG SERVICE_MOUNTPOINT='/'
RUN echo uwsgi --http-socket :9090 --plugins python3 --protocol uwsgi --wsgi-disable-file-wrapper --uid www-data --gid www-data --master --chdir /srv/qwc_service --mount qwc_service_MOUNTPOINT=server:app --manage-script-name >/docker-entrypoint.sh

ENTRYPOINT ["sh", "/docker-entrypoint.sh"]

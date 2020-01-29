# WSGI service environment

FROM alpine:3.9.5

RUN apk add --no-cache --update python3 uwsgi uwsgi-python3 && \
    pip3 install --no-cache --upgrade pip


ADD pg_service.conf /var/www/.pg_service.conf
ARG DB_USER=qwc_service
ARG DB_PASSWORD=qwc_service
RUN sed -i -e "s/^user=qwc_service/user=$DB_USER/" -e "s/^password=qwc_service/password=$DB_PASSWORD/" /var/www/.pg_service.conf

ARG SERVICE_MOUNTPOINT='/'

RUN addgroup -S www-data \
	&& adduser -D -S -h /var/cache/www-data -s /sbin/nologin -G www-data www-data

RUN echo uwsgi --http-socket :9090 --plugins python3 --protocol uwsgi --wsgi-disable-file-wrapper \
    --uid www-data --gid www-data --master --chdir /srv/qwc_service \
    --mount qwc_service_MOUNTPOINT=server:app --manage-script-name >/docker-entrypoint.sh

ENTRYPOINT ["sh", "/docker-entrypoint.sh"]

# WSGI service environment

FROM ubuntu:16.04

RUN apt-get update && apt-get upgrade -y

# Set locale (i.e. for psql client_encoding)
RUN apt-get update && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# uwsgi
RUN apt-get update && apt-get install -y uwsgi uwsgi-plugin-python3 python3-pip git

ARG SERVICE
ARG GIT_REPO=https://github.com/qwc-services/${SERVICE}.git
ARG SERVICE_DIR=/srv/$SERVICE
RUN cd /srv && git clone $GIT_REPO
# Set GIT_VERSION to force git fetch
ARG GIT_VERSION=master
RUN cd /srv/$SERVICE && git fetch && git checkout -b docker $GIT_VERSION
RUN pip3 install --no-cache-dir -r /srv/$SERVICE/requirements.txt

ADD pg_service.conf /var/www/.pg_service.conf
ARG DB_USER=qwc_service
ARG DB_PASSWORD=qwc_service
RUN sed -i -e "s/^user=qwc_service/user=$DB_USER/" -e "s/^password=qwc_service/password=$DB_PASSWORD/" /var/www/.pg_service.conf

# Install service packages
ARG SERVICE_PACKAGES=''
RUN if [ -n "$SERVICE_PACKAGES" ]; then apt-get update && apt-get install -y $SERVICE_PACKAGES; else true; fi

ARG SERVICE_MOUNTPOINT='/'
RUN echo uwsgi --http-socket :9090 --plugins python3 --protocol uwsgi --wsgi-disable-file-wrapper --uid www-data --gid www-data --master --chdir /srv/$SERVICE --mount $SERVICE_MOUNTPOINT=server:app --manage-script-name >/docker-entrypoint.sh

ENV FLASK_DEBUG=0
ENTRYPOINT ["sh", "/docker-entrypoint.sh"]

# Clean up downloaded packages
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

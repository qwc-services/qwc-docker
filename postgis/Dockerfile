# QWC Services base DB
#
# https://hub.docker.com/r/camptocamp/postgres/
# based on
# https://hub.docker.com/_/postgres:13
# based on Debian buster
#
# gdal 3 (in buster) does not work with postgres >= 12
# https://github.com/OSGeo/gdal/issues/1692
#
FROM camptocamp/postgres:11-postgis-3

#RUN localedef -i de_CH -c -f UTF-8 -A /usr/share/locale/locale.alias de_CH.UTF-8
#ENV LANG de_CH.utf8

RUN apt-get update

RUN apt-get update && \
    apt-get install --no-install-recommends -y git python3-pip python3-psycopg2 curl gdal-bin
RUN pip3 install --upgrade pip

# get qwc-config-db for migrations
ARG GIT_REPO=https://github.com/qwc-services/qwc-config-db.git
RUN cd /tmp/ && git clone $GIT_REPO qwc-config-db
# Set ALEMBIC_VERSION to force git pull
ARG ALEMBIC_VERSION=head
RUN cd /tmp/qwc-config-db/ && git pull
# psycopg2-binary 2.9 is not available for Python 3.5
RUN sed --in-place 's/psycopg2-binary==2.9.1/psycopg2-binary==2.8.6/' /tmp/qwc-config-db/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/qwc-config-db/requirements.txt

# setup connection service for migrations
COPY pg_service.conf /tmp/.pg_service.conf
ENV PGSERVICEFILE /tmp/.pg_service.conf

# setup database
RUN curl -o /tmp/demo_geodata.gpkg -L https://github.com/pka/mvt-benchmark/raw/master/data/mvtbench.gpkg
COPY setup-db.sh /docker-entrypoint-initdb.d/0_setup-db.sh
COPY run-migrations.sh /docker-entrypoint-initdb.d/1_run-migrations.sh
COPY setup-demo-data.sh /docker-entrypoint-initdb.d/2_setup-demo-data.sh
RUN chmod +x /docker-entrypoint-initdb.d/*.sh
RUN cp -a /usr/local/bin/docker-entrypoint.sh /tmp/docker-entrypoint.sh
# we do not want to execute postgres *after* /docker-entrypoint-initdb.d
# scripts have been executed. Thus we patch the docker-entrypoint.sh
# script to comment the exec out.
RUN sed --in-place 's/^\t*exec "$@"//' /tmp/docker-entrypoint.sh
ENV PGDATA /var/lib/postgresql/docker
ENV POSTGRES_PASSWORD U6ZqsEdBmrER
RUN gosu postgres bash /tmp/docker-entrypoint.sh postgres

# QWC Services development DB
#
# https://hub.docker.com/_/postgres/

# update to Debian stretch for GDAL 2.1 packages
# use postgres image on Debian stretch instead of using image from https://hub.docker.com/r/camptocamp/postgres/ on Debian jessie
# cf. https://github.com/camptocamp/docker-postgres/blob/master/9.6/Dockerfile
# --- FROM camptocamp/postgres -------------------------------------------------

FROM postgres:9.6.9

RUN apt-get update \
  && for POSTGIS_VERSION in 2.3; do \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    postgresql-contrib-$PG_MAJOR=$PG_VERSION \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts \
    postgresql-$PG_MAJOR-pgrouting; \
    done \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# allow the container to be started with `--user`
RUN chmod g=u /etc/passwd \
&& sed -i '/# allow the container to be started with `--user`/a if ! whoami &> /dev/null; then\n\tif [ -w /etc/passwd ]; then\n\t\techo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd\n\tfi\nfi' /usr/local/bin/docker-entrypoint.sh

# --- END camptocamp/postgres --------------------------------------------------

#RUN localedef -i de_CH -c -f UTF-8 -A /usr/share/locale/locale.alias de_CH.UTF-8
#ENV LANG de_CH.utf8

RUN apt-get update && apt-get install -y git python3-pip python3-psycopg2 curl gdal-bin
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
RUN head -n -1 /usr/local/bin/docker-entrypoint.sh >/tmp/docker-entrypoint.sh
ENV PGDATA /var/lib/postgresql/docker
ENV POSTGRES_PASSWORD U6ZqsEdBmrER
RUN gosu postgres bash /tmp/docker-entrypoint.sh postgres

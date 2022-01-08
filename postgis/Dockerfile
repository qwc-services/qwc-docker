# QWC Services base DB
FROM postgres:13

ENV DEBIAN_FRONTEND=noninteractive

ENV PG_MAJOR=13
ENV POSTGIS_VERSION=3

RUN apt-get update && apt-get upgrade -y
RUN apt-get install --no-install-recommends -y \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts; \
    apt-get install -y ca-certificates tmux screen curl less && \
    apt-get install -y git python3-pip python3-psycopg2 curl gdal-bin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#RUN localedef -i de_CH -c -f UTF-8 -A /usr/share/locale/locale.alias de_CH.UTF-8
#ENV LANG de_CH.utf8

RUN pip3 install --upgrade pip

# get qwc-config-db for migrations
ARG GIT_REPO=https://github.com/qwc-services/qwc-config-db.git
RUN cd /tmp/ && git clone $GIT_REPO qwc-config-db
# Set ALEMBIC_VERSION to force git pull
ARG ALEMBIC_VERSION=head
RUN cd /tmp/qwc-config-db/ && git pull
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

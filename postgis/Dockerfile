# QWC Services development DB
#
# https://hub.docker.com/_/postgres/

FROM camptocamp/postgres

RUN localedef -i de_CH -c -f UTF-8 -A /usr/share/locale/locale.alias de_CH.UTF-8
ENV LANG de_CH.utf8

RUN apt-get update && apt-get install -y git python3-pip python3-psycopg2
RUN pip3 install --upgrade pip

# get qwc-config-db for migrations
ARG GIT_REPO=https://github.com/qwc-services/qwc-config-db.git
RUN cd /tmp/ && git clone $GIT_REPO qwc-config-db
# Set ALEMBIC_VERSION to force git pull
ARG ALEMBIC_VERSION=56846d9f2753
RUN cd /tmp/qwc-config-db/ && git pull
RUN pip3 install --no-cache-dir -r /tmp/qwc-config-db/requirements.txt

# setup connection service for migrations
COPY pg_service.conf /tmp/.pg_service.conf
ENV PGSERVICEFILE /tmp/.pg_service.conf

# setup database
COPY setup-db.sh /docker-entrypoint-initdb.d/0_setup-db.sh
COPY run-migrations.sh /docker-entrypoint-initdb.d/1_run-migrations.sh
COPY setup-demo-data.sh /docker-entrypoint-initdb.d/2_setup-demo-data.sh
RUN chmod +x /docker-entrypoint-initdb.d/*.sh
RUN head -n -1 /usr/local/bin/docker-entrypoint.sh >/tmp/docker-entrypoint.sh
ENV PGDATA /var/lib/postgresql/docker
ENV POSTGRES_PASSWORD U6ZqsEdBmrER
RUN gosu postgres bash /tmp/docker-entrypoint.sh postgres

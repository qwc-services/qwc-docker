[![CI](https://github.com/qwc-services/qwc-docker/actions/workflows/uwsgi-base.yml/badge.svg)](https://github.com/qwc-services/qwc-docker/actions)
[![docker](https://img.shields.io/docker/v/sourcepole/qwc-uwsgi-base?label=qwc-uwsgi-base%20image&sort=semver)](https://hub.docker.com/r/sourcepole/qwc-uwsgi-base)
[![docker](https://img.shields.io/docker/v/sourcepole/qwc-qgis-server?label=qwc-qgis-server%20image&sort=semver)](https://hub.docker.com/r/sourcepole/qwc-qgis-server)

Docker containers for QWC Services
==================================

Docker installation
-------------------

* Docker: https://docs.docker.com/engine/install/
* docker-compose: (https://docs.docker.com/compose/install/)


Quick start
-----------

See [QWC Services Core](https://github.com/qwc-services/qwc-services-core#quick-start)


Usage
-----

Set JWT secret:

    python3 -c 'import secrets; print("JWT_SECRET_KEY=\"%s\"" % secrets.token_hex(48))' >.env

Start all containers:

    docker-compose up -d

Follow log output:

    docker-compose logs -f

Open map viewer:

    http://localhost:8088/

Connect to config DB:

    psql "service=qwc_configdb"

Stop all containers:

    docker-compose down

Update a single containers:

    # docker-compose pull <container name>
    docker-compose pull qwc-map-viewer

Update PostGIS container to ConfigDB migration `ALEMBIC_VERSION` (**NOTE**: Overwrites current database):

    docker-compose build --build-arg ALEMBIC_VERSION=c77774920e5b qwc-postgis


Containers:

* `qwc-admin-gui`: Admin GUI (http://localhost:8088/qwc_admin/)
* `qwc-api-gateway`: API Gateway, forwards requests to individual services (http://localhost:8088)
* `qwc-auth-service`: Authentication service with local user database (default users: `admin:admin`, `demo:demo`) (http://localhost:8088/auth/login)
* `qwc-data-service`: Data edit using GeoJSON (http://localhost:8088/api/v1/data/api)
* `qwc-map-viewer`: QWC2 map viewer (http://localhost:8088)
* `qwc-ogc-service`: Proxy for WMS/WFS requests filtered by permissions, calls QGIS Server (http://localhost:8088/ows/api)
* `qwc-postgis:` QWC ConfigDB and Demo PostGIS GeoDB (user: `qwc_admin:qwc_admin`) (localhost:5439)
* `qwc-qgis-server`: QGIS Server (http://localhost:8001/ows/qwc_demo)


Health checks for Kubernetes
----------------------------

Health checks are a simple way to let the system know if an instance of the app is working or not working. If an instance of the app is not working, then other services should not access it or send a request to it. Instead, requests should be sent to another instance of the app that is ready, or retried at a later time. The system should also bring the app back to a healthy state.

### Readyness:

Readiness probes are designed to let Kubernetes know when the app is ready to serve traffic. Kubernetes makes sure the readiness probe passes before allowing a service to send traffic to the pod. If a readiness probe starts to fail, Kubernetes stops sending traffic to the pod until it passes.

**Check is available at: /ready**

Example check:

* Return ok, if web service is initialized and running

### Liveness:

**Check is available at: /healthz**

Liveness probes let Kubernetes know if the app is alive or dead. If the app is alive, then Kubernetes leaves it alone. If the app is dead, Kubernetes removes the Pod and starts a new one to replace it.

Example checks:

* Check database connection (Example service: qwc-admin-gui)
* Check if all data files are available and readable (Example service: qwc-elevation-service)


DB connection
-------------

Setup PostgreSQL connection service file `~/.pg_service.conf`
for DB connections from the host machine to PostGIS container:

```
cat >>~/.pg_service.conf <<EOS
[qwc_configdb]
host=localhost
port=5439
dbname=qwc_demo
user=qwc_admin
password=qwc_admin
sslmode=disable

[qwc_geodb]
host=localhost
port=5439
dbname=qwc_demo
user=qwc_service_write
password=qwc_service_write
sslmode=disable

[qwc_webmapping]
host=localhost
port=5439
dbname=qwc_demo
user=qgis_server
password=qgis_server
sslmode=disable
EOS
```

Overwiev which container accesses which volume
----------------------------------------------

An overview of how each container accesses which volume 
can be found [here](docker-volume-matrix.md).

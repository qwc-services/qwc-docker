![Logo](https://github.com/qwc-services/qwc-docker/blob/master/volumes/qwc2/assets/img/qwc-logo.svg?raw=true) Docker containers for QWC Services
==================================

The QWC Services are a collection of microservices enhancing the functionality of the [QGIS Web Client](https://github.com/qgis/qwc2-demo-app), including:

- Authentication and permission control
- Editing
- Fulltext search
- Permalinks/bookmarks
- ...

This repository contains a sample setup for running QWC services with docker.

Documentation
-------------

The documentation is available at [qwc-services.github.io](https://qwc-services.github.io/).

Quick start
-----------

See [qwc-services.github.io/master/QuickStart/](https://qwc-services.github.io/master/QuickStart/).

Versioning
----------

Since February 2023 a new long-term-support branch of QWC2 and its services has been introduced. The respective Docker images are tagged as `vYYYY.x-lts` (i.e. `v2023.0-lts`). This branch will receive bugfix updates for approximately one year. The sample `docker-compose-example.yml` references these images.

The latest versions of QWC2 and its services is available as before, tagged as `vYYYY-MM-DD`.

Health checks for Kubernetes
----------------------------

Health checks are a simple way to let the system know if an instance of the app is working or not working. If an instance of the app is not working, then other services should not access it or send a request to it. Instead, requests should be sent to another instance of the app that is ready, or retried at a later time. The system should also bring the app back to a healthy state.

### Readyness:

Readiness probes are designed to let Kubernetes know when the app is ready to serve traffic. Kubernetes makes sure the readiness probe passes before allowing a service to send traffic to the pod. If a readiness probe starts to fail, Kubernetes stops sending traffic to the pod until it passes.

**Check is available at: `/ready`**

Example check:

* Return ok, if web service is initialized and running

### Liveness:

**Check is available at: `/healthz`**

Liveness probes let Kubernetes know if the app is alive or dead. If the app is alive, then Kubernetes leaves it alone. If the app is dead, Kubernetes removes the Pod and starts a new one to replace it.

Example checks:

* Check database connection (Example service: `qwc-admin-gui`)
* Check if all data files are available and readable (Example service: `qwc-elevation-service`)


Development
-----------

Create a QWC services dir:

    mkdir qwc-services
    cd qwc-services/

Clone the desired service, i.e. the `qwc-config-service`:

    git clone https://github.com/qwc-services/qwc-config-service.git

Configure `docker-compose.yml` to build a local image:

    qwc-config-service:
      # image: docker.io/sourcepole/qwc-config-generator:latest-lts
      build:
        context: ./qwc-services/qwc-config-generator
      ...

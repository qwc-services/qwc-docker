ATTENTION: this overwiew was last updated on 2021-10-06 and might not
reflect the current state of affairs, or in other words: this
overwiev should be updated regularily to keep up with project changes.

Volume-access matrix for all containers and users with direct file access
-------------------------------------------------------------------------

* W - needs write access
* R - needs read access only

| container/U:user            | src -> R/W:dest                                                                                                                                                                                      |
|-----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

|                             | volumes/qgs-resources | `pg_service.conf`                          | volumes/config-in                  | config                          | volumes/qwc2 | volumes/qwc2/assets   | volumes/geodata   |
|-----------------------------|-----------------------|--------------------------------------------|------------------------------------|---------------------------------|--------------|-----------------------|-------------------|
| qwc-postgis                 |                       |                                            |                                    |                                 |              |                       |                   |
| qwc-qgis-server             | R:/data               | `R:/etc/postgresql-common/pg_service.conf` |                                    |                                 |              |                       | R:/geodata        |
| qwc-config-service          | W:/data               | `R:/var/www/.pg_service.conf`              | `R:/srv/qwc_service/config-in`     | `W:/srv/qwc_service/config-out` | W:/qwc2      |                       |                   |
| qwc-ogc-service             |                       |                                            |                                    | `R:/srv/qwc_service/config`     |              |                       |                   |
| qwc-data-service            |                       | `R:/var/www/.pg_service.conf`              |                                    | `R:/srv/qwc_service/config`     |              |                       |                   |
| qwc-fulltext-search-service |                       | `R:/var/www/.pg_service.conf`              |                                    | `R:/srv/qwc_service/config`     |              |                       |                   |
| qwc-map-viewer              |                       |                                            |                                    | `R:/srv/qwc_service/config`     | R:/qwc2 [1]  | R:/qwc2/assets        |                   |
| qwc-admin-gui               | R:/data               | `R:/var/www/.pg_service.conf`              | `W:/srv/qwc_service/config-in` [2] | `                         `     | W:/qwc2      |                       |                   |
| qwc-registration-gui        |                       | `R:/var/www/.pg_service.conf`              |                                    | `                         `     |              |                       |                   |
| qwc-auth-service            |                       | `R:/var/www/.pg_service.conf`              |                                    | `R:/srv/qwc_service/config`     |              |                       |                   |
| qwc-elevation-service       |                       |                                            |                                    | `R:/srv/qwc_service/config`     |              |                       |                   |
| qwc-permalink-service       |                       | `R:/var/www/.pg_service.conf`              |                                    | `R:/srv/qwc_service/config`     |              |                       |                   |
| qwc-feature-info-service    |                       | `R:/var/www/.pg_service.conf`              |                                    | `R:/srv/qwc_service/config`     |              |                       |                   |
| qwc-document-service        |                       |                                            |                                    | `R:/srv/qwc_service/config`     |              |                       |                   |
| qwc-mapinfo-service         |                       | `R:/var/www/.pg_service.conf`              |                                    | `R:/srv/qwc_service/config`     |              |                       |                   |
| qwc-legend-service          |                       |                                            |                                    | `R:/srv/qwc_service/config`     |              |                       |                   |
| U:www-data                  |                       |                                            | W:volumes/config-in [3]            |                                 |              | W:volumes/qwc2/assets | W:volumes/geodata |

[1] When using own viewer build with qwc-map-viewer-base
[2] only writes themesConfig.json (and backups thereof)
[3] also needs write access to `volumes/config-in/default/qgis_projects`

Volumes that are private to only one container and not shared with others
-------------------------------------------------------------------------

qwc-postgis:
| volumes/postgres-data         | W:/var/lib/postgresql/data                |
| volumes/postgres-backup       | W:/var/lib/postgresql/backup              |

jasper-reporting-service:
| volumes/jasper-reports/config | R:/srv/jasper-reporting-service/config:ro |
| volumes/jasper-reports/demo   | R:/srv/jasper-reporting-service/demo:ro   |

qwc-legend-service:
| volumes/legends               | W:/legends                                |

qwc-api-gateway:
| api-gateway/nginx.conf        | R:/etc/nginx/conf.d/default.conf          |
| api-gateway/nginx-common.conf | R:/etc/nginx/nginx-common.conf            |
| api-gateway/cert.crt          | R:/etc/nginx/cert.crt                     |
| api-gateway/cert.key          | R:/etc/nginx/cert.key                     |


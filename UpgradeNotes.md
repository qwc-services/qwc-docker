# Upgrading to qwc-config-generator-v2022.01.12

- `scanned_projects_path_prefix` has been dropped as a config setting. Instead, `qgis_projects_scan_base_dir` must be a directory below `qgis_projects_base_dir`, and the prefix is automatically computed internally.
- `scanned_projects_path_prefix` has been added as a config setting as the output path for preprocessed qgis projects. It must be a directory below `qgis_projects_base_dir` to which the config service is allowed to write.

# Upgrading from qwc service images v2021.x to v2022.01.08 or later

Starting with v2022.01.08, the requirements of all services where updated to use Flask-JWT-Extended 4.3.1.

Flask-JWT-4.x changes the JWT format (see [4.0.0 Breaking Changes](https://flask-jwt-extended.readthedocs.io/en/stable/v4_upgrade_guide/#encoded-jwt-changes-important)), which can result in QWC Services returning a `Missing claim: identity` error message.

To avoid this:
* Change your JWT secret key in `.env`.
* Ensure all services are upgraded to v2022.01.12 or later (if such a version exists). Please omit v2022.01.08 and v2022.01.11.

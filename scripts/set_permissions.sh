#!/bin/bash
# Run this script from $HOME/src/qwc-docker to configure permissions for QWC2 Docker containers
# SELinux commands are skipped if SELinux tools are not installed

# Define UID/GID for QWC2 services (override with environment variables or match SERVICE_UID/SERVICE_GID in docker-compose.yml)
# Example: If docker-compose.yml sets SERVICE_UID: 1010, SERVICE_GID: 1010, run `export QWC_UID=1010 QWC_GID=1010` before this script
QWC_UID=${QWC_UID:-1000}
QWC_GID=${QWC_GID:-1000}

# Check if SELinux tools are available
SELINUX_ENABLED=0
if command -v chcon >/dev/null 2>&1 && command -v semanage >/dev/null 2>&1 && command -v restorecon >/dev/null 2>&1; then
    SELINUX_ENABLED=1
    echo "SELinux tools detected, applying SELinux contexts."
else
    echo "SELinux tools not detected, skipping SELinux commands."
fi

# Configure permissions for the PostgreSQL database volume (qwc-postgis)
if [ $SELINUX_ENABLED -eq 1 ]; then
    # Set SELinux type to svirt_sandbox_file_t recursively for Docker container access
    sudo chcon -Rt svirt_sandbox_file_t ./volumes/db
    # Add persistent SELinux file context rule for all files in ./volumes/db
    sudo semanage fcontext -a -t svirt_sandbox_file_t "./volumes/db(/.*)?"
    # Apply SELinux context to existing files in ./volumes/db
    sudo restorecon -R ./volumes/db
fi
# Set ownership to PostgreSQL user (UID 999) for container compatibility
sudo chown -R 999:999 ./volumes/db
# Set permissions to 700 for security (owner-only access)
sudo chmod -R 700 ./volumes/db

# Configure the NGINX configuration file for the qwc-api-gateway container
if [ $SELINUX_ENABLED -eq 1 ]; then
    # Set SELinux type to svirt_sandbox_file_t for NGINX container access
    sudo chcon -t svirt_sandbox_file_t ./api-gateway/nginx.conf
    # Add persistent SELinux file context rule for nginx.conf
    sudo semanage fcontext -a -t svirt_sandbox_file_t "./api-gateway/nginx.conf"
    # Apply SELinux context to nginx.conf
    sudo restorecon ./api-gateway/nginx.conf
fi
# Set ownership to the current user for local modifications
sudo chown $USER:$USER ./api-gateway/nginx.conf
# Set permissions to 644 (standard for configuration files)
sudo chmod 644 ./api-gateway/nginx.conf

# Configure the configuration volume used by qwc-map-viewer and other services
if [ $SELINUX_ENABLED -eq 1 ]; then
    # Set SELinux type to svirt_sandbox_file_t recursively for container access
    sudo chcon -Rt svirt_sandbox_file_t ./volumes/config
    # Add persistent SELinux file context rule for all files in ./volumes/config
    sudo semanage fcontext -a -t svirt_sandbox_file_t "./volumes/config(/.*)?"
    # Apply SELinux context to existing files in ./volumes/config
    sudo restorecon -R ./volumes/config
fi
# Set ownership to QWC2 service UID/GID (matches SERVICE_UID/SERVICE_GID in docker-compose.yml)
sudo chown -R $QWC_UID:$QWC_GID ./volumes/config
# Set permissions to 755 for container access
sudo chmod -R 755 ./volumes/config

# Configure the PostgreSQL service configuration file used by multiple services
if [ $SELINUX_ENABLED -eq 1 ]; then
    # Set SELinux type to svirt_sandbox_file_t for container access
    sudo chcon -t svirt_sandbox_file_t ./pg_service.conf
    # Add persistent SELinux file context rule for pg_service.conf
    sudo semanage fcontext -a -t svirt_sandbox_file_t "./pg_service.conf"
    # Apply SELinux context to pg_service.conf
    sudo restorecon ./pg_service.conf
fi
# Set ownership to the current user for local editing
sudo chown $USER:$USER ./pg_service.conf
# Set permissions to 644 (standard for configuration files)
sudo chmod 644 ./pg_service.conf

# Configure additional volumes (config-in, qwc2, qgs-resources, attachments, solr/data, solr/configsets)
# Clear Solr data directory to ensure clean state
sudo rm -rf ./volumes/solr/data/*
if [ $SELINUX_ENABLED -eq 1 ]; then
    # Set SELinux type to svirt_sandbox_file_t recursively for all volumes
    sudo chcon -Rt svirt_sandbox_file_t ./volumes
    # Add persistent SELinux file context rule for all files in ./volumes
    sudo semanage fcontext -a -t svirt_sandbox_file_t "./volumes(/.*)?"
    # Apply SELinux context to all files in ./volumes
    sudo restorecon -R ./volumes
fi
# Set ownership to QWC2 service UID/GID for QWC2-related volumes (matches SERVICE_UID/SERVICE_GID in docker-compose.yml)
sudo chown -R $QWC_UID:$QWC_GID ./volumes/config-in ./volumes/qwc2 ./volumes/qgs-resources ./volumes/attachments
# Set permissions to 755 for QWC2-related volumes
sudo chmod -R 755 ./volumes/config-in ./volumes/qwc2 ./volumes/qgs-resources ./volumes/attachments
# Set ownership to Solr user (UID 8983) for Solr volumes
sudo chown -R 8983:8983 ./volumes/solr/data ./volumes/solr/configsets
# Set permissions to 755 for Solr volumes
sudo chmod -R 755 ./volumes/solr/data ./volumes/solr/configsets

# Configure the demo data permissions script for qwc-config-db-migrate
if [ $SELINUX_ENABLED -eq 1 ]; then
    # Set SELinux type to svirt_sandbox_file_t for the script
    sudo chcon -t svirt_sandbox_file_t ./volumes/demo-data/setup-demo-data-permissions.sh
    # Add persistent SELinux file context rule for the script
    sudo semanage fcontext -a -t svirt_sandbox_file_t "./volumes/demo-data/setup-demo-data-permissions.sh"
    # Apply SELinux context to the script
    sudo restorecon ./volumes/demo-data/setup-demo-data-permissions.sh
fi
# Set ownership to QWC2 service UID/GID (matches SERVICE_UID/SERVICE_GID in docker-compose.yml)
sudo chown $QWC_UID:$QWC_GID ./volumes/demo-data/setup-demo-data-permissions.sh
# Set permissions to 755 to make the script executable
sudo chmod 755 ./volumes/demo-data/setup-demo-data-permissions.sh

# Configure SELinux network policies for container connectivity
if [ $SELINUX_ENABLED -eq 1 ]; then
    # Check if container_connect_any boolean exists
    if getsebool container_connect_any >/dev/null 2>&1; then
        # Enable container_connect_any persistently to allow containers to connect to any port
        sudo setsebool -P container_connect_any 1
    else
        # Print a message if the boolean is not defined (e.g., in older SELinux versions)
        echo "Note: container_connect_any boolean not defined, skipping."
    fi
    # Configure ports 5432 (PostgreSQL), 8088 (QWC2 services), and 8983 (Solr)
    for port in 5432 8088 8983; do
        # Check if the port is already defined as http_port_t
        if sudo semanage port -l | grep -q "http_port_t.*$port"; then
            # Modify the port to use http_port_t if it exists
            sudo semanage port -m -t http_port_t -p tcp $port
        else
            # Add the port with http_port_t if it doesn’t exist
            sudo semanage port -a -t http_port_t -p tcp $port
        fi
    done
    # Ensure port 5432 is labeled with postgresql_port_t for PostgreSQL access
    sudo semanage port -m -t postgresql_port_t -p tcp 5432
fi

# Print confirmation and instructions to restart Docker services
echo "Permissions applied. Restart services with:"
# Provide command to apply changes by restarting containers
echo "docker-compose down && docker-compose up -d"
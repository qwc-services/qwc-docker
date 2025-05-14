#!/bin/bash

help() {
   echo 'usage: set_permissions.sh QWC_UID QWC_GID'
   echo '       set_permissions.sh --help'
   echo
   echo '    Run this script from the qwc-docker directory to configure'
   echo '    permissions for QWC2 Docker containers.'
   echo
   echo '    SELinux settings will get applied if SELinux tools are present'
   echo
   echo '    Please make sure that QWC_UID and QWC_GID match match the'
   echo '    SERVICE_UID/SERVICE_GID settings defined in docker-compose.yml'
   echo '    (qwc-docker sets them to 1000:1000 by default)'
   echo

   exit 1
}

[ "$1" == "--help" ] && help
[ "$1" == "" -o "$2" == "" ] && echo "ERROR: You need to set the QWC_UID QWC_GID parameters" >&2 && exit 2

if [ "$(whoami)" != "root" ]; then
    echo "Please run me as root"
    exit 3
fi

QWC_UID="$1"
QWC_GID="$2"

# Ignore SIGPIPE to prevent broken pipe errors
trap '' SIGPIPE

# Check if SELinux tools are available
SELINUX_ENABLED=0
if command -v chcon >/dev/null 2>&1 && command -v semanage >/dev/null 2>&1 && command -v restorecon >/dev/null 2>&1; then
    SELINUX_ENABLED=1
    echo "SELinux tools detected, applying SELinux contexts."
else
    echo "SELinux tools not detected, skipping SELinux commands."
fi

# Function to run SELinux commands with error handling and debug logging
run_selinux_cmd() {
    local cmd="$1"
    echo "Running: $cmd"
    # Redirect all output to prevent pipe breaks
    if ! $cmd > /dev/null 2> /tmp/set_permissions_error.log; then
        echo "Error: Failed to execute '$cmd'"
        echo "Debug output: $(cat /tmp/set_permissions_error.log)"
        exit 1
    fi
}

# Configure permissions for the PostgreSQL database volume (qwc-postgis)
if [ $SELINUX_ENABLED -eq 1 ]; then
    run_selinux_cmd "chcon -Rt svirt_sandbox_file_t ./volumes/db"
    # Add or modify persistent SELinux file context rule
    if semanage fcontext -l | grep -q "^./volumes/db/.*\s.*svirt_sandbox_file_t\s" > /dev/null 2>&1; then
        #echo "Debug: Found context for ./volumes/db/.*"
        run_selinux_cmd "semanage fcontext -m -t svirt_sandbox_file_t './volumes/db/.*'"
    else
        #echo "Debug: No context for ./volumes/db/.*, adding new"
        run_selinux_cmd "semanage fcontext -a -t svirt_sandbox_file_t './volumes/db/.*'"
    fi
    run_selinux_cmd "restorecon -R ./volumes/db"
fi
chown -R 999:999 ./volumes/db
chmod -R 700 ./volumes/db

# Configure the NGINX configuration file for the qwc-api-gateway container
if [ $SELINUX_ENABLED -eq 1 ]; then
    run_selinux_cmd "chcon -t svirt_sandbox_file_t ./api-gateway/nginx.conf"
    # Add or modify persistent SELinux file context rule
    if semanage fcontext -l | grep -q "^./api-gateway/nginx.conf\s.*svirt_sandbox_file_t\s" > /dev/null 2>&1; then
        #echo "Debug: Found context for ./api-gateway/nginx.conf"
        run_selinux_cmd "semanage fcontext -m -t svirt_sandbox_file_t './api-gateway/nginx.conf'"
    else
        #echo "Debug: No context for ./api-gateway/nginx.conf, adding new"
        run_selinux_cmd "semanage fcontext -a -t svirt_sandbox_file_t './api-gateway/nginx.conf'"
    fi
    run_selinux_cmd "restorecon ./api-gateway/nginx.conf"
fi
chown $USER:$USER ./api-gateway/nginx.conf
chmod 644 ./api-gateway/nginx.conf

# Configure the configuration volume used by qwc-map-viewer and other services
if [ $SELINUX_ENABLED -eq 1 ]; then
    run_selinux_cmd "chcon -Rt svirt_sandbox_file_t ./volumes/config"
    # Add or modify persistent SELinux file context rule
    if semanage fcontext -l | grep -q "^./volumes/config/.*\s.*svirt_sandbox_file_t\s" > /dev/null 2>&1; then
        #echo "Debug: Found context for ./volumes/config/.*"
        run_selinux_cmd "semanage fcontext -m -t svirt_sandbox_file_t './volumes/config/.*'"
    else
        #echo "Debug: No context for ./volumes/config/.*, adding new"
        run_selinux_cmd "semanage fcontext -a -t svirt_sandbox_file_t './volumes/config/.*'"
    fi
    run_selinux_cmd "restorecon -R ./volumes/config"
fi
chown -R $QWC_UID:$QWC_GID ./volumes/config

# Configure the PostgreSQL service configuration file used by multiple services
if [ $SELINUX_ENABLED -eq 1 ]; then
    run_selinux_cmd "chcon -t svirt_sandbox_file_t ./pg_service.conf"
    # Add or modify persistent SELinux file context rule
    if semanage fcontext -l | grep -q "^./pg_service.conf\s.*svirt_sandbox_file_t\s" > /dev/null 2>&1; then
        #echo "Debug: Found context for ./pg_service.conf"
        run_selinux_cmd "semanage fcontext -m -t svirt_sandbox_file_t './pg_service.conf'"
    else
        #echo "Debug: No context for ./pg_service.conf, adding new"
        run_selinux_cmd "semanage fcontext -a -t svirt_sandbox_file_t './pg_service.conf'"
    fi
    run_selinux_cmd "restorecon ./pg_service.conf"
fi
chown $USER:$USER ./pg_service.conf
chmod 644 ./pg_service.conf

# Configure additional volumes (config-in, qwc2, qgs-resources, attachments)
if [ $SELINUX_ENABLED -eq 1 ]; then
    run_selinux_cmd "chcon -Rt svirt_sandbox_file_t ./volumes/config-in ./volumes/qwc2 ./volumes/qgs-resources ./volumes/attachments"
    # Add or modify persistent SELinux file context rule
    if semanage fcontext -l | grep -q "^./volumes/config-in/.*\s.*svirt_sandbox_file_t\s" > /dev/null 2>&1; then
        #echo "Debug: Found context for ./volumes/config-in/.*"
        run_selinux_cmd "semanage fcontext -m -t svirt_sandbox_file_t './volumes/config-in/.*'"
    else
        #echo "Debug: No context for ./volumes/config-in/.*, adding new"
        run_selinux_cmd "semanage fcontext -a -t svirt_sandbox_file_t './volumes/config-in/.*'"
    fi
    if semanage fcontext -l | grep -q "^./volumes/qwc2/.*\s.*svirt_sandbox_file_t\s" > /dev/null 2>&1; then
        #echo "Debug: Found context for ./volumes/qwc2/.*"
        run_selinux_cmd "semanage fcontext -m -t svirt_sandbox_file_t './volumes/qwc2/.*'"
    else
        #echo "Debug: No context for ./volumes/qwc2/.*, adding new"
        run_selinux_cmd "semanage fcontext -a -t svirt_sandbox_file_t './volumes/qwc2/.*'"
    fi
    if semanage fcontext -l | grep -q "^./volumes/qgs-resources/.*\s.*svirt_sandbox_file_t\s" > /dev/null 2>&1; then
        #echo "Debug: Found context for ./volumes/qgs-resources/.*"
        run_selinux_cmd "semanage fcontext -m -t svirt_sandbox_file_t './volumes/qgs-resources/.*'"
    else
        #echo "Debug: No context for ./volumes/qgs-resources/.*, adding new"
        run_selinux_cmd "semanage fcontext -a -t svirt_sandbox_file_t './volumes/qgs-resources/.*'"
    fi
    if semanage fcontext -l | grep -q "^./volumes/attachments/.*\s.*svirt_sandbox_file_t\s" > /dev/null 2>&1; then
        #echo "Debug: Found context for ./volumes/attachments/.*"
        run_selinux_cmd "semanage fcontext -m -t svirt_sandbox_file_t './volumes/attachments/.*'"
    else
        #echo "Debug: No context for ./volumes/attachments/.*, adding new"
        run_selinux_cmd "semanage fcontext -a -t svirt_sandbox_file_t './volumes/attachments/.*'"
    fi
    run_selinux_cmd "restorecon -R ./volumes/config-in ./volumes/qwc2 ./volumes/qgs-resources ./volumes/attachments"
fi
chown -R $QWC_UID:$QWC_GID ./volumes/config-in ./volumes/qwc2 ./volumes/qgs-resources ./volumes/attachments

# Configure Solr volumes
if [ $SELINUX_ENABLED -eq 1 ]; then
    run_selinux_cmd "chcon -Rt container_file_t -l s0 ./volumes/solr/data ./volumes/solr/configsets"
    # Add or modify persistent SELinux file context rule
    if semanage fcontext -l | grep -q "^./volumes/solr/data/.*\s.*container_file_t\s" > /dev/null 2>&1; then
        #echo "Debug: Found context for ./volumes/solr/data/.*"
        run_selinux_cmd "semanage fcontext -m -t container_file_t './volumes/solr/data/.*'"
    else
        #echo "Debug: No context for ./volumes/solr/data/.*, adding new"
        run_selinux_cmd "semanage fcontext -a -t container_file_t './volumes/solr/data/.*'"
    fi
    if semanage fcontext -l | grep -q "^./volumes/solr/configsets/.*\s.*container_file_t\s" > /dev/null 2>&1; then
        #echo "Debug: Found context for ./volumes/solr/configsets/.*"
        run_selinux_cmd "semanage fcontext -m -t container_file_t './volumes/solr/configsets/.*'"
    else
        #echo "Debug: No context for ./volumes/solr/configsets/.*, adding new"
        run_selinux_cmd "semanage fcontext -a -t container_file_t './volumes/solr/configsets/.*'"
    fi
    run_selinux_cmd "restorecon -R ./volumes/solr/data ./volumes/solr/configsets"
fi
chown -R 8983:8983 ./volumes/solr/data ./volumes/solr/configsets

# Configure the demo data permissions script for qwc-config-db-migrate
if [ $SELINUX_ENABLED -eq 1 ]; then
    run_selinux_cmd "chcon -t svirt_sandbox_file_t ./volumes/demo-data/setup-demo-data-permissions.sh"
    # Add or modify persistent SELinux file context rule
    if semanage fcontext -l | grep -q "^./volumes/demo-data/setup-demo-data-permissions.sh\s.*svirt_sandbox_file_t\s" > /dev/null 2>&1; then
        #echo "Debug: Found context for ./volumes/demo-data/setup-demo-data-permissions.sh"
        run_selinux_cmd "semanage fcontext -m -t svirt_sandbox_file_t './volumes/demo-data/setup-demo-data-permissions.sh'"
    else
        #echo "Debug: No context for ./volumes/demo-data/setup-demo-data-permissions.sh, adding new"
        run_selinux_cmd "semanage fcontext -a -t svirt_sandbox_file_t './volumes/demo-data/setup-demo-data-permissions.sh'"
    fi
    run_selinux_cmd "restorecon ./volumes/demo-data/setup-demo-data-permissions.sh"
fi
chown $QWC_UID:$QWC_GID ./volumes/demo-data/setup-demo-data-permissions.sh

# Configure SELinux network policies for container connectivity
if [ $SELINUX_ENABLED -eq 1 ]; then
    # Check if container_connect_any boolean exists
    if getsebool container_connect_any >/dev/null 2>&1; then
        run_selinux_cmd "setsebool -P container_connect_any 1"
    else
        echo "Note: container_connect_any boolean not defined, skipping."
    fi
    # Configure ports 5432 (PostgreSQL), 8088 (QWC2 services), and 8983 (Solr)
    for port in 5432 8088 8983; do
        # Check if the port is already defined as http_port_t
        if semanage port -l | grep -q "http_port_t.*$port" > /dev/null 2>&1; then
            run_selinux_cmd "semanage port -m -t http_port_t -p tcp $port"
        else
            run_selinux_cmd "semanage port -a -t http_port_t -p tcp $port"
        fi
    done
    # Ensure port 5432 is labeled with postgresql_port_t for PostgreSQL access
    run_selinux_cmd "semanage port -m -t postgresql_port_t -p tcp 5432"
fi

# Print confirmation and instructions to restart Docker services
echo "Permissions applied. Restart services with:"
echo "docker-compose down && docker-compose up -d"

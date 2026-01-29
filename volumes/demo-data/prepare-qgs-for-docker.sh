#!/bin/bash
set -e

echo "Converting QGIS projects for Docker..."

mkdir -p /data/scan

for qgs_file in /data/*.qgs; do
    if [ -f "$qgs_file" ]; then
        filename=$(basename "$qgs_file")
        
        echo "  Processing $filename..."
        
        sed -e "s/dbname='qwc_services' host=localhost port=5439 user='qwc_admin' password='qwc_admin'/service='qwc_geodb'/g" \
            -e "s/dbname='qwc_services' host=localhost port=5439 user='qwc_admin'/service='qwc_geodb'/g" \
            "$qgs_file" > "/data/scan/$filename"
        
        echo "  ✓ $filename → scan/$filename"
    fi
done

echo "All projects converted!"
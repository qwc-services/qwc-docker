#!/bin/bash
set -e

echo "🔧 Converting QGIS projects for Docker..."

for qgs_file in volumes/qgs-resources/*.qgs; do
    if [ -f "$qgs_file" ]; then
        filename=$(basename "$qgs_file")
        echo "  Processing $filename..."
        
        sed "s/dbname='qwc_services' host=localhost port=5439 user='qwc_admin' password='qwc_admin'/service='qwc_geodb'/g" \
            "$qgs_file" > "volumes/qgs-resources/scan/$filename"
        
        echo " $filename ready for Docker"
    fi
done



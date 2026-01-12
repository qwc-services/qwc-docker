Configuration QWC (QGIS Web Client) avec données custom et initialisation automatique de la base de données.

## Démarrage rapide
```bash
git clone <repo>
cd qwc-docker-gcp
docker-compose up -d
```

Attends ~2 minutes, puis accède à :
- **QWC Web** : http://localhost:8088
- **QWC Admin** : http://localhost:8088/qwc_admin (admin/qwc_admin)


### Tables custom
- `wo_water_network` : 1,637 interventions réseau
- `wo_water_leak_searching` : 13,422 recherches de fuites

Ces tables sont créées et remplies automatiquement au démarrage.

### Projets QGIS
- `interventions.qgs` : Visualisation des couches custom dans QWC


### Connexion PostgreSQL (QGIS Desktop)
```
Host: localhost
Port: 5439
Database: qwc_services
User: qwc_admin
Password: qwc_admin
```

### Modifier un projet QGIS

1. Ouvre `volumes/qgs-resources/scan/interventions.qgs` dans QGIS Desktop
2. Fais tes modifications
3. Sauvegarde (Ctrl+S)
4. Convertis pour Docker :
```bash
   ./volumes/demo-data/prepare-qgs-for-docker.sh
```
5. Commit :
```bash
   git add volumes/qgs-resources/
   git commit -m "Update QGIS project"
```


### Ajouter de nouvelles tables

1. Crée le DDL dans `volumes/demo-data/sql/ddl/ma_nouvelle_table.sql`
2. Crée les INSERT dans `volumes/demo-data/sql/sensitive/ma_nouvelle_table_data.sql`
3. Recrée la base :
```bash
   docker-compose down
   rm -rf volumes/db/*
   docker-compose up -d
```

## Troubleshooting

### Le backup ne se charge pas
Les scripts d'init ne s'exécutent que si la base est vide. Si tu as déjà démarré Docker avant :
```bash
docker-compose down
rm -rf volumes/db/*
docker-compose up -d
```

### Les tables custom n'apparaissent pas dans QGIS
Vérifie les permissions :
```bash
docker-compose exec qwc-postgis psql -U postgres -d qwc_services -c "GRANT SELECT ON ALL TABLES IN SCHEMA qwc_geodb TO qwc_admin;"
```


## 🔒 Sécurité

**Pour la production** :
- Change tous les mots de passe dans `setup-passwords.sh` ?
- Utilise des variables d'environnement (fichier `.env`) 
- Ne commit jamais le dossier `sensitive/` si données réelles

## 📚 Ressources

- [QWC Documentation](https://github.com/qwc-services/qwc-docker)
- [QGIS Server](https://docs.qgis.org/latest/en/docs/server_manual/)
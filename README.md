# Analyse des crises météorologiques en France — Météo France x Metabase

## Présentation du projet

Ce projet a été réalisé dans le cadre du cours de Data Visualisation.

L'objectif est d'analyser les données météorologiques fournies par Météo-France afin d'étudier les précipitations dans plusieurs départements français et d'identifier les tendances ainsi que les épisodes de fortes pluies pouvant être associés à des risques d'inondation.

## Membres du groupe

- Béatrice BEAVOGUI
- Tom JOUSSET

---

## Problématique

> Quelles sont les durées moyennes des crises météorologiques/inondations et leur évolution dans le temps ?

Les épisodes de fortes précipitations peuvent avoir des conséquences importantes sur les territoires :

- Inondations
- Perturbations des transports
- Risques pour les populations
- Impacts économiques et environnementaux

Pour répondre à cette problématique, nous avons :

- Collecté des données ouvertes de Météo-France
- Stocké les données dans PostgreSQL
- Créé un tableau de bord interactif avec Metabase
- Analysé l'évolution des précipitations selon les départements et les années

---

## Technologies utilisées

| Outil | Version | Rôle |
|---|---|---|
| PostgreSQL | 13 | Stockage des données |
| Metabase | v0.57 | Dashboard et visualisations |
| Docker / Docker Compose | — | Conteneurisation |
| Python | 3.10+ | Pipeline d'import des données |

**Source des données :** [meteo.data.gouv.fr](https://meteo.data.gouv.fr) (Météo-France Open Data)

---

## Structure du projet

```text
4DVST-project/
│
├── dashboard/
│   └── graphsQueries/
│       └── graphsQueries.sql   # Requêtes SQL du dashboard (versions finales + alternatives commentées)
│
├── db/
│   ├── Dockerfile              # Image PostgreSQL avec init.sql intégré
│   ├── init.sql                # Schéma, vues et référentiels départements
│   └── refresh_crises.sql      # Script de maintenance : recréer v_crises après import
│
├── scripts/
│   ├── import_data.py          # Pipeline de téléchargement et import des données
│   └── requirements.txt        # Dépendances Python
│
├── sujet/
│   └── MétéoFranceST.pdf       # Sujet et storytelling du projet initial
│
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## Prérequis

- Docker Desktop
- Python 3.10 ou supérieur
- Git

---

## Installation et lancement

### 1. Cloner le projet

```bash
git clone https://github.com/TomJous/4DVST-project.git
cd 4DVST-project
```

### 2. Configurer les variables d'environnement

```bash
cp .env.example .env    # Linux/Mac
copy .env.example .env  # Windows
```

Renseigner `DB_USER` et `DB_PASSWORD` dans le fichier `.env`.

### 3. Démarrer les conteneurs

```bash
docker compose up --build
```

- PostgreSQL → `localhost:5432`
- Metabase → [http://localhost:3000](http://localhost:3000)

### 4. Installer les dépendances Python

```bash
python3 -m venv venv
source venv/bin/activate        # Linux/Mac
venv\Scripts\activate           # Windows

pip install -r scripts/requirements.txt
```

### 5. Importer les données Météo-France

Télécharge les observations journalières pour 28 départements français (1990–2025) depuis Météo-France et les importe dans PostgreSQL.

```bash
venv/bin/python scripts/import_data.py
```

> Durée estimée : 10 à 20 minutes (~150 Mo à télécharger).

Pour réinitialiser et réimporter depuis zéro :

```bash
venv/bin/python scripts/import_data.py --reset
```

> Par souci de simplicité, le projet couvre **28 départements représentatifs**. Pour ajouter un département, modifier la variable `DEPARTMENTS` dans [`scripts/import_data.py`](scripts/import_data.py) (ligne 27) en ajoutant son code INSEE à 2 chiffres (ex : `"69"` pour le Rhône, `"2A"` pour la Corse-du-Sud), puis relancer l'import et le script de maintenance `refresh_crises.sql`.

---

## Connexion Metabase → PostgreSQL

| Paramètre | Valeur |
|---|---|
| Host | `postgres` |
| Port | `5432` |
| Database | `myBdd` |
| Username | *(DB_USER depuis .env)* |
| Password | *(DB_PASSWORD depuis .env)* |

---

## Modèle de données

### Définition d'une crise météorologique

Une **crise météorologique** est définie comme une séquence d'**au moins 2 jours consécutifs** durant lesquels les précipitations journalières dépassent **20 mm/jour**.

### Départements couverts

| Code | Département | Catégorie |
|---|---|---|
| 05 | Hautes-Alpes | Haute altitude |
| 06 | Alpes-Maritimes | Méditerranéen |
| 11 | Aude | Méditerranéen / Cévenol |
| 13 | Bouches-du-Rhône | Méditerranéen |
| 17 | Charente-Maritime | Côte Atlantique |
| 29 | Finistère | Côte Atlantique |
| 30 | Gard | Méditerranéen / Cévenol |
| 31 | Haute-Garonne | Piémont pyrénéen |
| 33 | Gironde | Atlantique |
| 34 | Hérault | Méditerranéen / Cévenol |
| 38 | Isère | Alpin |
| 44 | Loire-Atlantique | Atlantique |
| 48 | Lozère | Cévenol |
| 59 | Nord | Basse altitude |
| 62 | Pas-de-Calais | Basse altitude |
| 63 | Puy-de-Dôme | Massif Central |
| 64 | Pyrénées-Atlantiques | Atlantique / Pyrénées |
| 65 | Hautes-Pyrénées | Haute altitude |
| 66 | Pyrénées-Orientales | Méditerranéen |
| 67 | Bas-Rhin | Est |
| 69 | Rhône | Alpin |
| 73 | Savoie | Haute altitude |
| 74 | Haute-Savoie | Haute altitude |
| 75 | Paris | Forte densité |
| 76 | Seine-Maritime | Côte Normande |
| 77 | Seine-et-Marne | Île-de-France |
| 83 | Var | Méditerranéen |
| 85 | Vendée | Côte Atlantique |

---

## Bibliothèques Python

| Bibliothèque | Version | Usage |
|---|---|---|
| `psycopg2-binary` | 2.9.9 | Connexion PostgreSQL |
| `requests` | 2.32.3 | Téléchargement des CSV |
| `python-dotenv` | 1.0.1 | Chargement des variables d'environnement |

---

## Reproduire le dashboard

Toutes les requêtes SQL du dashboard sont disponibles dans [`dashboard/graphsQueries/graphsQueries.sql`](dashboard/graphsQueries/graphsQueries.sql).

Une fois le projet lancé et les données importées, suivre les étapes suivantes.

### Étape 1 — Configurer le GeoJSON (obligatoire pour les cartes)

1. Aller dans **Admin** (icône ⚙️ en haut à droite)
2. Cliquer sur **Maps** dans le menu gauche
3. Cliquer sur **Add a map** et remplir :
   - **Nom** : `Départements France`
   - **URL** : `https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements.geojson`
   - **Region field** : `code`
4. Cliquer sur **Add map** puis **Save**

### Étape 2 — Créer les questions SQL

Pour chaque graphique :

1. Aller dans **Nouveau → Requête SQL**
2. Sélectionner la base `MetaDATA`
3. Copier la requête correspondante depuis `graphsQueries.sql`
4. Cliquer sur **Visualiser** et choisir le type de graphique indiqué dans les commentaires
5. Sauvegarder la question dans la collection `Météo France - Crises`

### Étape 3 — Assembler le dashboard

1. Aller dans **Nouveau → Dashboard**
2. Ajouter les 4 questions créées
3. Ajouter un filtre **Année** : icône filtre → **Time** → **Year** → connecter à chaque question sur la colonne `annee`

### Visualisations du dashboard

1. **Graphique linéaire** — évolution du nombre de crises par an depuis 1990
2. **Carte choroplèthe** — nombre de crises par département
3. **Carte choroplèthe** — durée moyenne des crises par département
4. **Tableau** — top 10 des départements les plus touchés
5. **Nuage de points** — altitude moyenne vs nombre de crises par département

---

## Maintenance

### Recréer la vue `v_crises` après un import de données

Après chaque ajout de nouveaux fichiers CSV, rafraîchir la vue matérialisée :

```bash
docker exec postgres sh -c "psql \$POSTGRES_DB -U \$POSTGRES_USER -f /docker-entrypoint-initdb.d/refresh_crises.sql"
```

---

## Conclusion

Ce projet nous a permis de découvrir et d'utiliser plusieurs outils de la data : Python, PostgreSQL, Docker et Metabase.

Grâce aux données ouvertes de Météo-France, nous avons analysé les précipitations dans différents départements français et mis en évidence des tendances ainsi que des épisodes de fortes pluies. Le tableau de bord interactif facilite la compréhension des données à travers des visualisations claires et dynamiques.

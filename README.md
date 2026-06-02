# Analyse des précipitations en France à partir des données Météo-France

## Présentation du projet

Ce projet a été réalisé dans le cadre du cours de Data Visualisation.

L'objectif est d'analyser les données météorologiques fournies par Météo-France afin d'étudier les précipitations dans plusieurs départements français et d'identifier les tendances ainsi que les épisodes de fortes pluies pouvant être associés à des risques d'inondation.

## Membres du groupe

- Béatrice BEAVOGUI
- Tom JOUSSET


## Objectif du projet

L'objectif principal du projet est de répondre à la question suivante :

> Comment les données de précipitations permettent-elles d'identifier les zones les plus exposées aux fortes pluies en France ?

Pour répondre à cette problématique, nous avons :

- Collecté des données ouvertes de Météo-France ;
- Stocké les données dans PostgreSQL ;
- Créé un tableau de bord interactif avec Metabase ;
- Analysé l'évolution des précipitations selon les départements et les années.

## Technologies utilisées

- Docker
- PostgreSQL
- Metabase
- Python
- GitHub

## Sources des données

- Météo-France Open Data
- data.gouv.fr

## Structure du projet

```text
4DVST-project
│
├── db/
│   ├── Dockerfile
│   └── init.sql
│
├── scripts/
│   ├── import_data.py
│   └── requirements.txt
│
├── sujet/
│
├── .env
├── .env.example
├── docker-compose.yml
└── README.md
```

### Description des dossiers

#### db/

Contient les fichiers nécessaires à l'initialisation de la base de données PostgreSQL.

#### scripts/

Contient les scripts Python permettant de télécharger, traiter et importer les données météorologiques dans PostgreSQL.

#### sujet/

Contient les documents liés au sujet du projet et à la soutenance.

#### docker-compose.yml

Permet de lancer automatiquement PostgreSQL et Metabase à l'aide de Docker.

#### README.md

Documentation générale du projet.

---

## Installation et lancement du projet

### Prérequis

Avant de lancer le projet, les outils suivants doivent être installés :

- Docker Desktop
- Python 3.11 ou supérieur
- Git
- Visual Studio Code (optionnel)

### Cloner le projet

```bash
https://github.com/TomJous/4DVST-project.git
```

### Configuration

Créer un fichier `.env` à partir du modèle :

```bash
copy .env.example .env
```

Puis renseigner les informations de connexion PostgreSQL.

### Démarrage des services

Lancer PostgreSQL et Metabase avec Docker :

```bash
docker compose up -d
```

### Installation des dépendances Python

Depuis le dossier `scripts` :

```bash
cd scripts
pip install -r requirements.txt
```

### Import des données Météo-France

```bash
python import_data.py
```

### Accès à Metabase

Une fois les conteneurs démarrés, Metabase est accessible à l'adresse :

```text
http://localhost:3030
```

### Connexion à PostgreSQL depuis Metabase

| Paramètre | Valeur |
|------------|---------|
| Host | postgres |
| Port | 5432 |
| Database | myBdd |
| Username | postgres |
| Password | changeme |

---

## Problématique

Les épisodes de fortes précipitations sont de plus en plus fréquents et peuvent avoir des conséquences importantes sur les territoires :

- Inondations ;
- Perturbations des transports ;
- Risques pour les populations ;
- Impacts économiques et environnementaux.

À travers ce projet, nous cherchons à analyser les données météorologiques afin de répondre à la question suivante :

> Quels sont les départements les plus exposés aux fortes précipitations et comment ces phénomènes évoluent-ils dans le temps ?

## Résultats attendus

Le tableau de bord permettra notamment de :

- Identifier les départements les plus pluvieux ;
- Étudier l'évolution des précipitations au fil des années ;
- Détecter les épisodes de pluies extrêmes ;
- Comparer les territoires étudiés ;
- Faciliter l'interprétation des données grâce à des visualisations interactives.

## Conclusion

## Conclusion

Ce projet nous a permis de découvrir et d'utiliser plusieurs outils de la data tels que Python, PostgreSQL, Docker et Metabase.

Grâce aux données ouvertes de Météo-France, nous avons pu analyser les précipitations dans différents départements français et mettre en évidence certaines tendances ainsi que des épisodes de fortes pluies.

Le tableau de bord réalisé facilite la compréhension des données grâce à des visualisations claires et interactives. Ce projet nous a également permis de développer nos compétences en collecte, traitement, stockage et visualisation des données.
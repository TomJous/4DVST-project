CREATE TABLE IF NOT EXISTS observations (
    num_poste    VARCHAR(8)    NOT NULL,
    nom_usuel    VARCHAR(100),
    lat          NUMERIC(9,6),
    lon          NUMERIC(9,6),
    alti         INTEGER,
    aaaammjj     INTEGER       NOT NULL,
    rr           NUMERIC(6,1),
    qrr          SMALLINT,
    tn           NUMERIC(5,1),
    qtn          SMALLINT,
    htn          INTEGER,
    qhtn         SMALLINT,
    tx           NUMERIC(5,1),
    qtx          SMALLINT,
    htx          INTEGER,
    qhtx         SMALLINT,
    tm           NUMERIC(5,1),
    qtm          SMALLINT,
    tntxm        NUMERIC(5,1),
    qtntxm       SMALLINT,
    tampli       NUMERIC(5,1),
    qtampli      SMALLINT,
    tnsol        NUMERIC(5,1),
    qtnsol       SMALLINT,
    tn50         NUMERIC(5,1),
    qtn50        SMALLINT,
    dg           NUMERIC(6,1),
    qdg          SMALLINT,
    ffm          NUMERIC(5,1),
    qffm         SMALLINT,
    ff2m         NUMERIC(5,1),
    qff2m        SMALLINT,
    fxy          NUMERIC(5,1),
    qfxy         SMALLINT,
    dxy          INTEGER,
    qdxy         SMALLINT,
    hxy          INTEGER,
    qhxy         SMALLINT,
    fxi          NUMERIC(5,1),
    qfxi         SMALLINT,
    dxi          INTEGER,
    qdxi         SMALLINT,
    hxi          INTEGER,
    qhxi         SMALLINT,
    fxi2         NUMERIC(5,1),
    qfxi2        SMALLINT,
    dxi2         INTEGER,
    qdxi2        SMALLINT,
    hxi2         INTEGER,
    qhxi2        SMALLINT,
    fxi3s        NUMERIC(5,1),
    qfxi3s       SMALLINT,
    dxi3s        INTEGER,
    qdxi3s       SMALLINT,
    hxi3s        INTEGER,
    qhxi3s       SMALLINT,
    drr          NUMERIC(6,1),
    qdrr         SMALLINT,
    status_fxi3s SMALLINT,
    status_dxi3s SMALLINT,
    PRIMARY KEY (num_poste, aaaammjj)
);

CREATE INDEX IF NOT EXISTS idx_obs_date  ON observations(aaaammjj);
CREATE INDEX IF NOT EXISTS idx_obs_dept  ON observations(LEFT(num_poste, 2));

-- Vue nettoyée utilisée par Metabase
-- Colonnes : uniquement celles nécessaires pour le storytelling crises/inondations
-- Filtre qualité : qrr = 2 (donnée douteuse) exclue
CREATE OR REPLACE VIEW v_observations AS
SELECT
    num_poste,
    nom_usuel,
    LEFT(num_poste, 2)                                           AS departement, -- les 2 premiers chiffres du code station = numéro de département
    lat,
    lon,
    alti,
    TO_DATE(aaaammjj::text, 'YYYYMMDD')                          AS date_obs,   -- convertit l'entier YYYYMMDD en type DATE exploitable par Metabase
    EXTRACT(YEAR FROM TO_DATE(aaaammjj::text, 'YYYYMMDD'))::int  AS annee,      -- année extraite pour grouper les crises par année dans les graphiques
    COALESCE(rr, 0)                                              AS rr          -- remplace les précipitations NULL par 0 (absence de mesure = pas de pluie)
FROM observations
WHERE qrr IS NULL OR qrr <> 2;

-- ── Détection des crises (technique "gaps and islands") ──────────────────────
-- Une crise = séquence d'au moins 2 jours consécutifs avec rr >= 20 mm/jour
-- Vue matérialisée : résultats pré-calculés sur disque → requêtes Metabase instantanées
-- Pour rafraîchir après un nouvel import : REFRESH MATERIALIZED VIEW v_crises;
CREATE MATERIALIZED VIEW IF NOT EXISTS v_crises AS
WITH jours_pluie AS (
    SELECT
        num_poste,
        nom_usuel,
        departement,
        alti,
        date_obs,
        annee,
        rr,
        -- island_id : date - rang = constante pour chaque séquence consécutive
        date_obs - ROW_NUMBER() OVER (PARTITION BY num_poste ORDER BY date_obs)::integer AS island_id
    FROM v_observations
    WHERE rr >= 20
),
crises_brutes AS (
    SELECT
        num_poste,
        nom_usuel,
        departement,
        alti,
        island_id,
        MIN(date_obs)     AS debut,
        MAX(date_obs)     AS fin,
        COUNT(*)          AS duree_jours,
        SUM(rr)           AS precipitations_totales_mm,
        MIN(annee)        AS annee
    FROM jours_pluie
    GROUP BY num_poste, nom_usuel, departement, alti, island_id
    HAVING COUNT(*) >= 2
)
SELECT num_poste, nom_usuel, departement, alti,
       debut, fin, duree_jours, precipitations_totales_mm, annee
FROM crises_brutes;

CREATE INDEX IF NOT EXISTS idx_crises_annee  ON v_crises(annee);
CREATE INDEX IF NOT EXISTS idx_crises_dept   ON v_crises(departement);

CREATE TABLE IF NOT EXISTS ref_departements (
    code VARCHAR(3) PRIMARY KEY,
    nom  VARCHAR(50)
);

INSERT INTO ref_departements VALUES
    ('01','Ain'),('02','Aisne'),('03','Allier'),('04','Alpes-de-Haute-Provence'),
    ('05','Hautes-Alpes'),('06','Alpes-Maritimes'),('07','Ardèche'),('08','Ardennes'),
    ('09','Ariège'),('10','Aube'),('11','Aude'),('12','Aveyron'),
    ('13','Bouches-du-Rhône'),('14','Calvados'),('15','Cantal'),('16','Charente'),
    ('17','Charente-Maritime'),('18','Cher'),('19','Corrèze'),('2A','Corse-du-Sud'),
    ('2B','Haute-Corse'),('21','Côte-d Or'),('22','Côtes-d Armor'),('23','Creuse'),
    ('24','Dordogne'),('25','Doubs'),('26','Drôme'),('27','Eure'),
    ('28','Eure-et-Loir'),('29','Finistère'),('30','Gard'),('31','Haute-Garonne'),
    ('32','Gers'),('33','Gironde'),('34','Hérault'),('35','Ille-et-Vilaine'),
    ('36','Indre'),('37','Indre-et-Loire'),('38','Isère'),('39','Jura'),
    ('40','Landes'),('41','Loir-et-Cher'),('42','Loire'),('43','Haute-Loire'),
    ('44','Loire-Atlantique'),('45','Loiret'),('46','Lot'),('47','Lot-et-Garonne'),
    ('48','Lozère'),('49','Maine-et-Loire'),('50','Manche'),('51','Marne'),
    ('52','Haute-Marne'),('53','Mayenne'),('54','Meurthe-et-Moselle'),('55','Meuse'),
    ('56','Morbihan'),('57','Moselle'),('58','Nièvre'),('59','Nord'),
    ('60','Oise'),('61','Orne'),('62','Pas-de-Calais'),('63','Puy-de-Dôme'),
    ('64','Pyrénées-Atlantiques'),('65','Hautes-Pyrénées'),('66','Pyrénées-Orientales'),
    ('67','Bas-Rhin'),('68','Haut-Rhin'),('69','Rhône'),('70','Haute-Saône'),
    ('71','Saône-et-Loire'),('72','Sarthe'),('73','Savoie'),('74','Haute-Savoie'),
    ('75','Paris'),('76','Seine-Maritime'),('77','Seine-et-Marne'),('78','Yvelines'),
    ('79','Deux-Sèvres'),('80','Somme'),('81','Tarn'),('82','Tarn-et-Garonne'),
    ('83','Var'),('84','Vaucluse'),('85','Vendée'),('86','Vienne'),
    ('87','Haute-Vienne'),('88','Vosges'),('89','Yonne'),('90','Territoire de Belfort'),
    ('91','Essonne'),('92','Hauts-de-Seine'),('93','Seine-Saint-Denis'),
    ('94','Val-de-Marne'),('95','Val-d Oise')
ON CONFLICT (code) DO NOTHING;

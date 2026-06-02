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
-- Une crise = séquence de plus de 2 jours consécutifs avec rr >= 10 mm/jour
-- Le seuil de 10mm/jour est réaliste (le PDF mentionnait 1m/jour = erreur)
CREATE OR REPLACE VIEW v_crises AS
WITH jours_pluie AS (
    -- Numérotation globale par station vs numérotation dans les jours de pluie uniquement
    -- La différence est constante pour chaque séquence consécutive (island_id)
    SELECT
        num_poste,
        nom_usuel,
        departement,
        alti,
        date_obs,
        annee,
        rr,
        ROW_NUMBER() OVER (PARTITION BY num_poste ORDER BY date_obs)
        - ROW_NUMBER() OVER (PARTITION BY num_poste ORDER BY date_obs) AS island_id
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
        MIN(date_obs)        AS debut,
        MAX(date_obs)        AS fin,
        COUNT(*)             AS duree_jours,
        SUM(rr)              AS precipitations_totales_mm,
        MIN(annee)           AS annee
    FROM jours_pluie
    GROUP BY num_poste, nom_usuel, departement, alti, island_id
    HAVING COUNT(*) > 2  -- uniquement les crises de plus de 2 jours
)
SELECT
    num_poste,
    nom_usuel,
    departement,
    alti,
    debut,
    fin,
    duree_jours,
    precipitations_totales_mm,
    annee
FROM crises_brutes;

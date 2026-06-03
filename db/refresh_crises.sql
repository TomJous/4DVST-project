DROP MATERIALIZED VIEW IF EXISTS v_crises;

CREATE MATERIALIZED VIEW v_crises AS
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
        MIN(date_obs)        AS debut,
        MAX(date_obs)        AS fin,
        COUNT(*)             AS duree_jours,
        SUM(rr)              AS precipitations_totales_mm,
        MIN(annee)           AS annee
    FROM jours_pluie
    GROUP BY num_poste, nom_usuel, departement, alti, island_id
    HAVING COUNT(*) >= 2
)
SELECT num_poste, nom_usuel, departement, alti,
       debut, fin, duree_jours, precipitations_totales_mm, annee
FROM crises_brutes;

CREATE INDEX IF NOT EXISTS idx_crises_annee ON v_crises(annee);
CREATE INDEX IF NOT EXISTS idx_crises_dept  ON v_crises(departement);

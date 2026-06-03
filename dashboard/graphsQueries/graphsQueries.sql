-- ============================================================
-- DASHBOARD — Météo France x Metabase
-- Queries pour les 4 visualisations principales
-- Seuil crise : rr >= 20 mm/jour sur au moins 2 jours consécutifs
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- CHART 1 — Graphique linéaire : évolution des crises par année
-- Type Metabase : Courbe (Line)
-- X : annee | Y : total_jours_crise
-- ────────────────────────────────────────────────────────────

-- Version finale : total jours de crise par an (avec toutes les années)
-- generate_series garantit un point par année même si nb_crises = 0
SELECT
    g.annee,
    COALESCE(SUM(c.duree_jours), 0) AS total_jours_crise
FROM generate_series(1990, 2025) AS g(annee)
LEFT JOIN v_crises c ON c.annee = g.annee
GROUP BY g.annee
ORDER BY g.annee;

-- Version alternative : nombre d'épisodes par an (moins parlant)
-- SELECT annee, COUNT(*) AS nb_crises
-- FROM v_crises
-- GROUP BY annee
-- ORDER BY annee;


-- ────────────────────────────────────────────────────────────
-- CHART 2a — Carte choroplèthe : nombre de crises par département
-- Type Metabase : Carte (Map) > Region map
-- GeoJSON : https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements.geojson
-- Region field : departement | Metric : nb_crises | Couleur : rouge
-- ────────────────────────────────────────────────────────────

SELECT
    departement,
    COUNT(*) AS nb_crises
FROM v_crises
GROUP BY departement
ORDER BY nb_crises DESC;


-- ────────────────────────────────────────────────────────────
-- CHART 2b — Carte choroplèthe : durée moyenne des crises par département
-- Type Metabase : Carte (Map) > Region map
-- GeoJSON : https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements.geojson
-- Region field : departement | Metric : duree_moyenne
-- ────────────────────────────────────────────────────────────

SELECT
    departement,
    ROUND(AVG(duree_jours), 1) AS duree_moyenne,
    COUNT(*)                   AS nb_crises
FROM v_crises
GROUP BY departement
ORDER BY duree_moyenne DESC;


-- ────────────────────────────────────────────────────────────
-- CHART 3 — Tableau : top 10 départements les plus touchés
-- Type Metabase : Tableau (Table)
-- ────────────────────────────────────────────────────────────

SELECT
    r.nom                                    AS departement,
    COUNT(*)                                 AS nb_crises,
    ROUND(AVG(duree_jours), 1)               AS duree_moyenne_jours,
    ROUND(AVG(precipitations_totales_mm), 0) AS precipitations_moy_mm
FROM v_crises c
JOIN ref_departements r ON c.departement = r.code
GROUP BY r.nom
ORDER BY nb_crises DESC
LIMIT 10;


-- ────────────────────────────────────────────────────────────
-- CHART 4 — Nuage de points : altitude vs nombre de crises
-- Type Metabase : Nuage de points (Scatter)
-- X : altitude_moy | Y : nb_crises | Taille : duree_moyenne
-- ────────────────────────────────────────────────────────────

-- Version finale : agrégation par département avec noms
SELECT
    r.nom                      AS departement,
    ROUND(AVG(alti))           AS altitude_moy,
    COUNT(*)                   AS nb_crises,
    ROUND(AVG(duree_jours), 1) AS duree_moyenne
FROM v_crises c
JOIN ref_departements r ON c.departement = r.code
GROUP BY r.nom
ORDER BY altitude_moy;

-- Version par tranches d'altitude (4 points, trop peu)
-- SELECT
--     CASE
--         WHEN alti < 200   THEN '0-200m'
--         WHEN alti < 500   THEN '200-500m'
--         WHEN alti < 1000  THEN '500-1000m'
--         ELSE '> 1000m'
--     END AS tranche_altitude,
--     ROUND(AVG(alti))           AS altitude_moy,
--     COUNT(*)                   AS nb_crises,
--     ROUND(AVG(duree_jours), 1) AS duree_moyenne
-- FROM v_crises
-- GROUP BY tranche_altitude
-- ORDER BY altitude_moy;

-- Version par station individuelle (trop de points, illisible)
-- SELECT
--     num_poste,
--     nom_usuel,
--     departement,
--     alti,
--     COUNT(*)                   AS nb_crises,
--     ROUND(AVG(duree_jours), 1) AS duree_moyenne
-- FROM v_crises
-- GROUP BY num_poste, nom_usuel, departement, alti;

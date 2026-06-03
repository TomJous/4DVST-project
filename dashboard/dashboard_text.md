# Textes du Dashboard — CrisesDashboardV2

---

## TITRE PRINCIPAL

CrisesDashboard

---

## TITRE DE SECTION

Analyse des données climatologiques de Météo France

---

## BLOC INTRODUCTION (encadré haut)

Problématique : Quelles sont les durées moyennes des crises météorologiques/inondations et leur évolution dans le temps ?

Préambule : Définir une "crise météorologique" reste complexe car il n'existe pas de seuil universel. Dans cette étude, nous considérons qu'une crise correspond à une période de plus de deux jours consécutifs durant laquelle les précipitations dépassent un seuil critique de 20mm par jour. Cette définition permet d'identifier les épisodes de fortes pluies susceptibles d'entraîner des inondations et des perturbations importantes.

La première question que l'on se pose naturellement est : ces crises sont-elles de plus en plus fréquentes ?

---

## GRAPHIQUE 1 — nbreCrisesParAnnée
*Question Metabase : `Crises par année` | Chart 1 — graphsQueries.sql*

### Texte droite du graphique

Depuis 1990, le nombre de crises météorologiques fluctue fortement d'une année à l'autre. Les années 1990 ont été les plus intenses, avec un pic à plus de 2 600 épisodes en 1993. Mais où ces crises frappent-elles le plus fort ? C'est ce que la carte suivante révèle.

---

## CARTE 1 — Carte des crises en France (rouge)
*Question Metabase : `Nombre de crises par département` | Chart 2a — graphsQueries.sql*

### Texte gauche de la carte

Le nord et l'ouest reçoivent pourtant autant — voire plus — de précipitations annuelles. Mais leurs pluies sont diffuses et étalées. Ce qui crée une crise, ce n'est pas le volume d'eau, c'est sa concentration dans le temps. Les épisodes cévenols, phénomène météorologique propre au bassin méditerranéen, déversent en 48 à 72h des quantités d'eau qu'un département normand reçoit en plusieurs semaines.

Pour aller plus loin, regardons maintenant quels sont les 10 départements les plus touchés en nombre de crises et en durée — les données confirment et précisent ce que la carte esquisse.

---

## CARTE 2 — Nombre de jours des crises en fonction du département (bleu)
*Question Metabase : `Durée moyenne des crises par département` | Chart 2b — graphsQueries.sql*

### Texte droite de la carte

Nous pouvons constater que à la différence du graphique précédent le nord sont touchés aussi longtemps que dans le sud, comment l'expliquer ?

La réponse tient en une image : une éponge déjà humide n'absorbe plus rien. Dans le nord et sur les côtes atlantiques, les sols sont structurellement humides toute l'année. Lorsqu'une pluie intense survient — même modérée — le sol est déjà saturé. L'eau ne s'infiltre plus, elle ruisselle et stagne. La crise s'installe et se prolonge.

Dans le sud méditerranéen, c'est l'inverse : les sols plus secs absorbent une partie des précipitations, même torrentielles. Les épisodes cévenols frappent fort et vite, mais se dissipent aussi plus rapidement.

---

## GRAPHIQUE 2 — altitude/nbreCrisisGraph (nuage de points)
*Question Metabase : `Altitude vs nombre de crises` | Chart 4 — graphsQueries.sql*

### Texte gauche du graphique

Nous pouvons faire une seconde allégorie à l'aide du graphique suivant du bol de céréales. Imaginez un bol de céréales, l'eau s'accumule naturellement au fond et sur les bords.

Les zones les plus basses concentrent les inondations par ruissellement. Mais les contreforts montagneux jouent le rôle des bords du bol : ils reçoivent les précipitations des hauteurs et accumulent les eaux qui descendent des sommets. Le pire des deux mondes.

---

## TABLEAU — top10depCrisis
*Question Metabase : `Top 10 départements touchés` | Chart 3 — graphsQueries.sql*

### Données

| Département          | nb_crises | duree_moyenne_jours | precipitations_moy_mm |
|----------------------|-----------|---------------------|-----------------------|
| Pyrénées-Atlantiques | 5 598     | 2.3                 | 80                    |
| Haute-Savoie         | 5 535     | 2.3                 | 74                    |
| Savoie               | 5 346     | 2.2                 | 71                    |
| Alpes-Maritimes      | 4 877     | 2.3                 | 100                   |
| Isère                | 4 871     | 2.2                 | 74                    |
| Gard                 | 4 640     | 2.3                 | 121                   |
| Hérault              | 4 278     | 2.3                 | 120                   |

### Texte droite du tableau

Les 10 départements ci-dessous concentrent l'essentiel des crises enregistrées. On retrouve sans surprise les Pyrénées-Atlantiques, la Savoie et le Gard en tête — confirmation en chiffres de ce que les cartes montraient visuellement. À noter : la durée moyenne varie peu entre départements (2 à 3 jours), c'est le volume de crises qui creuse l'écart.

---

## CONCLUSION (encadré bas)

La géographie des crises météorologiques en France n'est pas uniforme. Elle est façonnée par trois facteurs qui s'entremêlent : le climat (méditerranéen vs atlantique), les sols (saturés au nord, secs au sud) et le relief (les fonds de vallée et les piémonts comme zones d'accumulation). Comprendre ces mécanismes, c'est mieux anticiper les territoires les plus vulnérables face à l'intensification climatique à venir.

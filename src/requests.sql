/**
 * Requêtes SQL
 */

/**
 * 1. Nombre de visionnages de vidéos par catégories de vidéos, pour les 
 *    visionnages de moins de deux semaines
 */
WITH latest_views AS (
    SELECT
        idvideo
    FROM
        historical
    WHERE
        viewingdate > ( sysdate - 14 )
)
SELECT
    idcategory,
    COUNT(idvideo)
FROM
    latest_views
    NATURAL LEFT JOIN video
    NATURAL LEFT JOIN program
    NATURAL FULL JOIN category
GROUP BY
    idcategory;

/**
 * 2. Par utilisateur, le nombre d’abonnement, de favoris et de vidéos 
 *    visionnées.
 */
SELECT
    c.idclient,
    COUNT(DISTINCT s.idprogram)       AS nbsubs,
    COUNT(DISTINCT f.idvideo)         AS nbfavs,
    COUNT(DISTINCT h.idvideo)         AS nbseen
FROM
    client        c
    LEFT JOIN subscription  s ON s.idclient = c.idclient
    LEFT JOIN favorite      f ON f.idclient = c.idclient
    LEFT JOIN historical    h ON c.idclient = h.idclient
GROUP BY
    c.idclient;

/**
 * 3. Pour chaque vidéo, le nombre de visionnages par des utilisateurs français, 
 *    le nombre de visionnage par des utilisateurs allemands, la différence 
 *    entre les deux, triés par valeur absolue de la différence entre les deux.
 */
WITH fr_clients AS (
    SELECT
        idclient
    FROM
        client
    WHERE
        nationality = 'FR'
), de_clients AS (
    SELECT
        idclient
    FROM
        client
    WHERE
        nationality = 'DE'
)
SELECT
    v.idvideo               AS video,
    COUNT(f.idclient)       AS fr,
    COUNT(d.idclient)       AS de
FROM
    video       v
    LEFT JOIN historical  h ON h.idvideo = v.idvideo
    LEFT JOIN fr_clients  f ON f.idclient = h.idclient
    LEFT JOIN de_clients  d ON d.idclient = h.idclient
GROUP BY
    v.idvideo
ORDER BY
    abs(fr - de);

/**
 * 4. Les épisodes d’émissions qui ont au moins deux fois plus de visionnage que 
 *    la moyenne des visionnages des autres épisodes de l’émission.
 */
WITH video_views AS (
    SELECT
        idvideo,
        COUNT(*) AS views
    FROM
        historical
    GROUP BY
        idvideo
)
SELECT
    v.idvideo
FROM
         video v
    JOIN video_views vv ON vv.idvideo = v.idvideo
WHERE
    vv.views > (
        SELECT
            2 * AVG(views)
        FROM
                 video
            NATURAL JOIN video_views
        WHERE
                idvideo != v.idvideo
            AND idprogram = v.idprogram
        GROUP BY
            idprogram
    );

/**
 * 5. Les 10 couples de vidéos apparaissant le plus souvent simultanément dans 
 * un historique de visionnage d’utilisateur.
 */
WITH video_pairs AS (
    SELECT
        h1.idvideo                        AS video1,
        h2.idvideo                        AS video2,
        COUNT(DISTINCT h1.idclient)       AS nb
    FROM
             historical h1
        JOIN historical h2 ON h2.idclient = h1.idclient
    WHERE
        h1.idvideo < h2.idvideo
    GROUP BY
        h1.idvideo,
        h2.idvideo
    ORDER BY
        nb DESC
)
SELECT
    video1,
    video2
FROM
    video_pairs
WHERE
    ROWNUM <= 10;
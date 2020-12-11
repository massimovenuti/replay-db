SET SERVEROUTPUT ON;

/**
 * Procédures et fonctions PL/SQL
 */

/**
 * 1. Définir une fonction qui convertit au format json les informations d’une 
 *    vidéo.
 */
CREATE OR REPLACE FUNCTION video_2_json (
    id_vid_p IN video.idvideo%TYPE
) RETURN VARCHAR2 IS
    row_v video%rowtype;
BEGIN
    SELECT
        *
    INTO row_v
    FROM
        video
    WHERE
        idvideo = id_vid_p;

    return('{'
           || '"IDVIDEO": "'
           || row_v.idvideo
           || '",'
           || '"IDPROGRAM": "'
           || row_v.idprogram
           || '",'
           || '"VIDEOPATH": "'
           || row_v.videopath
           || '",'
           || '"VIDEOTITLE": "'
           || row_v.videotitle
           || '",'
           || '"VIDEODESC": "'
           || row_v.videodesc
           || '",'
           || '"DURATION": "'
           || row_v.duration
           || '",'
           || '"YEARFIRSTBROADCAST": "'
           || row_v.yearfirstbroadcast
           || '",'
           || '"LASTBROADCAST": "'
           || row_v.lastbroadcast
           || '",'
           || '"ENDAVAILABILITY": "'
           || row_v.endavailability
           || '",'
           || '"NEXTBROADCAST": "'
           || row_v.nextbroadcast
           || '",'
           || '"EPISODENUM": "'
           || row_v.episodenum
           || '",'
           || '"COUNTRY": "'
           || row_v.country
           || '",'
           || '"QUALITY": "'
           || row_v.quality
           || '",'
           || '"IMAGEFORMAT": "'
           || row_v.imageformat
           || '"}');

END;
/

BEGIN
    video_2_json(1);
END;
/

/**
 * 2. Définir une procédure qui généra un texte initial de la newsletter en y 
 *    ajoutant la liste de toute les sortie de la semaine.
 */
CREATE OR REPLACE PROCEDURE newsletter IS
BEGIN
    dbms_output.put_line('Découvrez les nouvelles sorties de la semaine !');
    FOR video_c IN (
        SELECT
            videotitle
        FROM
            video
        WHERE
            lastbroadcast > ( sysdate - 7 )
    ) LOOP
        dbms_output.put_line(video_c.videotitle);
    END LOOP;

END;
/

BEGIN
    newsletter;
END;
/

/**
 * 3. Générer la liste des vidéos populaires, conseillé pour un utilisateur, 
 *    c’est à dire fonction des catégories de vidéos qu’il suit.
 */
CREATE OR REPLACE PROCEDURE reference (
    idclient_p INTEGER
) IS

    CURSOR ref_c IS
    WITH latest_views AS (
        SELECT
            idvideo
        FROM
            historical
        WHERE
            viewingdate > ( sysdate - 14 )
    )
    SELECT
        videotitle
    FROM
        video
        NATURAL FULL JOIN latest_views
        NATURAL JOIN program
        NATURAL JOIN category
    WHERE
        idcategory IN (
            SELECT
                idcategory
            FROM
                interest
            WHERE
                idclient = idclient_p
        )
    GROUP BY
        idcategory,
        videotitle
    ORDER BY
        COUNT(idvideo) DESC;

    i_v INTEGER;
BEGIN
    i_v := 1;
    FOR ref_r IN ref_c LOOP
        dbms_output.put_line(i_v
                             || ' - '
                             || ref_r.videotitle);
        i_v := i_v + 1;
    END LOOP;

END;
/

BEGIN
    reference(1);
END;
/
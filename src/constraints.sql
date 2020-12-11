/**
 * Contraintes d’intégrité
 */

/**
 * Contraintes perso
 *
 *  - Le mot de passe d’un utilisateur est composé de chiffres, de lettres majuscules et minuscules
 *  - La date de naissance d’un utilisateur est antérieure à la date courante
 *  - L’année de la première diffusion d’une vidéo est antérieure ou égale à l’année courante
 *
 */

 /**
 * 1. Un utilisateur aura un maximum de 300 vidéos en favoris.
 */
CREATE OR REPLACE TRIGGER favs BEFORE
    INSERT ON favorite
    FOR EACH ROW
DECLARE
    nbfavs_v INTEGER;
BEGIN
    SELECT
        COUNT(*)
    INTO nbfavs_v
    FROM
        favorite
    WHERE
        idclient = :new.idclient;

    IF nbfavs_v >= 300 THEN
        raise_application_error(-20000, 'Nombre de favoris maximal atteint pour l''utilisateur ' || :new.idclient);
    END IF;

END;
/

CREATE OR REPLACE PROCEDURE test_trigger_favs (
    idclient_v INTEGER
) IS
BEGIN
    FOR i IN 100..399 LOOP
        INSERT INTO video VALUES (
            i,
            1,
            '../videos/path',
            to_char(i),
            'desc',
            32,
            2000,
            sysdate - 2,
            sysdate + 10,
            sysdate + 12,
            1,
            'FR',
            '720p',
            'AVI'
        );

        INSERT INTO favorite VALUES (
            idclient_v,
            i
        );

    END LOOP;

    INSERT INTO video VALUES (
        400,
        1,
        '../videos/path',
        '400',
        'desc',
        32,
        2000,
        sysdate - 2,
        sysdate + 10,
        sysdate + 12,
        1,
        'FR',
        '720p',
        'AVI'
    );

    INSERT INTO favorite VALUES (
        idclient_v,
        400
    );

END;
/

BEGIN
    test_trigger_favs(1);
END;
/

/**
 * 2. Si une diffusion d’une émission est ajoutée, les dates de disponibilités 
 *    seront mises à jour. La nouvelle date de fin de disponibilité sera la date 
 *    de la dernière diffusion plus 14 jours.
 */
 CREATE OR REPLACE TRIGGER end_availability_update BEFORE
    INSERT OR UPDATE OF lastbroadcast ON video
    FOR EACH ROW
BEGIN
    :new.endavailability := :new.lastbroadcast + 14;
END;
/

CREATE OR REPLACE PROCEDURE test_trigger_availability (
    idvideo_v INTEGER
) IS
BEGIN
    UPDATE video
    SET
        lastbroadcast = sysdate
    WHERE
        idvideo = idvideo_v;

END;
/

BEGIN
    test_trigger_availability(1);
END;
/

/**
 * 3. La suppression d’une vidéo entraînera son archivage dans une tables des 
 *    vidéos qui ne sont plus accessibles par le site de replay. 
 */
CREATE OR REPLACE TRIGGER archivage BEFORE
    DELETE ON video
    FOR EACH ROW
BEGIN
    INSERT INTO archive VALUES (
        :old.idvideo,
        :old.idprogram,
        :old.videopath,
        :old.videotitle,
        :old.videodesc,
        :old.duration,
        :old.yearfirstbroadcast,
        :old.lastbroadcast,
        :old.endavailability,
        :old.nextbroadcast,
        :old.episodenum,
        :old.country,
        :old.quality,
        :old.imageformat
    );

END;
/

/**
 * 4. Afin de limiter le spam de visionnage, un utilisateur ne pourra pas lancer 
 *    plus de 3 visionnages par minutes. 
 */
CREATE OR REPLACE TRIGGER trigger_spam BEFORE
    INSERT ON historical
    FOR EACH ROW
DECLARE
    nbviews_v INTEGER;
BEGIN
    SELECT
        COUNT(*)
    INTO nbviews_v
    FROM
        historical
    WHERE
        ( idclient = :new.idclient )
        AND :new.viewingdate >= ( sysdate - INTERVAL '1' MINUTE );

    IF nbviews_v >= 3 THEN
        raise_application_error(-20001, 'Nombre de visionnages lancés en 1 minutes maximal atteint pour l''utilisateur ' || :new.
        idclient);
    END IF;

END;
/

CREATE OR REPLACE PROCEDURE test_trigger_spam (
    idclient_v INTEGER
) IS
BEGIN
    INSERT INTO historical VALUES (
        idclient_v,
        1,
        sysdate
    );

    INSERT INTO historical VALUES (
        idclient_v,
        2,
        sysdate
    );

    INSERT INTO historical VALUES (
        idclient_v,
        3,
        sysdate
    );

END;
/

BEGIN
    test_trigger_spam(1);
END;
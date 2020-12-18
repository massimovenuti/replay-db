/**
 * Contraintes d’intégrité
 */

 /**
 * 1. Un utilisateur aura un maximum de 300 vidéos en favoris.
 */
CREATE OR REPLACE TRIGGER i_favorite BEFORE
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
        raise_application_error(-20009, 'Nombre de favoris maximal atteint pour l''utilisateur ' || :new.idclient);
    END IF;

END;
/

/**
 * 2. Si une diffusion d’une émission est ajoutée, les dates de disponibilités 
 *    seront mises à jour. La nouvelle date de fin de disponibilité sera la date 
 *    de la dernière diffusion plus 14 jours.
 */
CREATE OR REPLACE TRIGGER iu_video_lastbroadcast BEFORE
    INSERT OR UPDATE OF lastbroadcast ON video
    FOR EACH ROW
BEGIN
    :new.endavailability := :new.lastbroadcast + 14;
END;
/

/**
 * 3. La suppression d’une vidéo entraînera son archivage dans une tables des 
 *    vidéos qui ne sont plus accessibles par le site de replay. 
 */
CREATE OR REPLACE TRIGGER d_video BEFORE
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
CREATE OR REPLACE TRIGGER i_historical BEFORE
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
            idclient = :new.idclient
        AND viewingdate <= :new.viewingdate
        AND viewingdate >= ( :new.viewingdate - INTERVAL '1' MINUTE );

    IF nbviews_v >= 3 THEN
        raise_application_error(-20001, 'Nombre de visionnages lancés en 1 minutes maximal atteint pour l''utilisateur ' || :new.idclient);
    END IF;

END;
/

/**
 * Contraintes bonus
 */

/*
 * La date de naissance d’un utilisateur est antérieure à la date courante.
 */
CREATE OR REPLACE TRIGGER i_client_birthdate BEFORE
    INSERT ON client
    FOR EACH ROW
BEGIN
    IF :new.birthdate > sysdate THEN
        raise_application_error(-20011, 'Date de naissance incorrecte de l''utilisateur ' || :new.idclient);
    END IF;
END;
/

/*
 * L’année de la première diffusion d’une vidéo est antérieure ou égale à 
 * l’année courante.
 */
CREATE OR REPLACE TRIGGER i_video_year BEFORE
    INSERT ON video
    FOR EACH ROW
BEGIN
    IF :new.yearfirstbroadcast > extract(YEAR FROM sysdate) THEN
        raise_application_error(-20012, 'Année de première diffusion incorrecte de la vidéo ' || :new.idvideo);
    END IF;
END;
/
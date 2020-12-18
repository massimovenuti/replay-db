/*
 * TRIGGER 
 */
 
DROP TRIGGER i_favorite;

DROP TRIGGER iu_video_lastbroadcast;

DROP TRIGGER d_video;

DROP TRIGGER i_historical;

DROP TRIGGER i_client_birthdate;

DROP TRIGGER i_video_year;

/*
 * TABLE 
 */
 
DROP TABLE subscription CASCADE CONSTRAINTS;

DROP TABLE favorite CASCADE CONSTRAINTS;

DROP TABLE interest CASCADE CONSTRAINTS;

DROP TABLE historical CASCADE CONSTRAINTS;

DROP TABLE client CASCADE CONSTRAINTS;

DROP TABLE video CASCADE CONSTRAINTS;

DROP TABLE archive CASCADE CONSTRAINTS;

DROP TABLE program CASCADE CONSTRAINTS;

DROP TABLE category CASCADE CONSTRAINTS;

/*
 * FUNCTION & PROCEDURE
 */

DROP FUNCTION video_2_json;

DROP PROCEDURE newsletter;

DROP PROCEDURE reference;
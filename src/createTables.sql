CREATE TABLE category (
    idcategory     INTEGER,
    categorytitle  VARCHAR2(255) NOT NULL,
    categorydesc   VARCHAR2(1000),
    PRIMARY KEY ( idcategory ),
    CONSTRAINT uc_category UNIQUE ( categorytitle )
);

CREATE TABLE program (
    idprogram     INTEGER,
    idcategory    INTEGER NOT NULL,
    programtitle  VARCHAR2(255) NOT NULL,
    programdesc   VARCHAR2(1000),
    CONSTRAINT pk_program PRIMARY KEY ( idprogram ),
    CONSTRAINT fk_program FOREIGN KEY ( idcategory )
        REFERENCES category
            ON DELETE CASCADE,
    CONSTRAINT uc_program UNIQUE ( programtitle )
);

CREATE TABLE client (
    idclient     INTEGER,
    login        VARCHAR2(32) NOT NULL,
    password     VARCHAR2(63) NOT NULL,
    firstname    VARCHAR2(127) NOT NULL,
    lastname     VARCHAR2(127) NOT NULL,
    gender       CHAR(1),
    nationality  CHAR(2) NOT NULL,
    city         VARCHAR(127),
    street       VARCHAR(255),
    postalcode   VARCHAR2(31),
    birthdate    DATE,
    mail         VARCHAR2(255) NOT NULL,
    subscribed   CHAR(1) DEFAULT 'N' NOT NULL,
    CONSTRAINT pk_client PRIMARY KEY ( idclient ),
    CONSTRAINT uc_client_login UNIQUE ( login ),
    CONSTRAINT uc_client_mail UNIQUE ( mail ),
    CONSTRAINT ck_client_password CHECK ( length(password) > 7 ),
    CONSTRAINT ck_client_mail CHECK ( mail LIKE '%@%.%' ),
    CONSTRAINT ck_client_gender CHECK ( gender IN ( 'M', 'F' ) ),
    CONSTRAINT ck_client_subscribed CHECK ( subscribed IN ( 'Y', 'N' ) ),
    CONSTRAINT ck_client_nationality CHECK ( nationality = upper(nationality) )
);

CREATE TABLE video (
    idvideo             INTEGER,
    idprogram           INTEGER NOT NULL,
    videopath           VARCHAR2(512) NOT NULL,
    videotitle          VARCHAR2(255) NOT NULL,
    videodesc           VARCHAR2(2000),
    duration            NUMBER(10) NOT NULL,
    yearfirstbroadcast  NUMBER(15) DEFAULT EXTRACT(YEAR FROM sysdate) NOT NULL,
    lastbroadcast       DATE DEFAULT sysdate NOT NULL,
    endavailability     DATE DEFAULT sysdate + 7 NOT NULL,
    nextbroadcast       DATE,
    episodenum          NUMBER(15) NOT NULL,
    country             CHAR(2) NOT NULL,
    quality             VARCHAR2(7) NOT NULL,
    imageformat         CHAR(3) NOT NULL,
    CONSTRAINT pk_video PRIMARY KEY ( idvideo ),
    CONSTRAINT fk_video FOREIGN KEY ( idprogram )
        REFERENCES program
            ON DELETE CASCADE,
    CONSTRAINT uc_video UNIQUE ( idprogram,
                                 videotitle ),
    CONSTRAINT ck_video_path CHECK ( videopath LIKE '../videos/%' ),
    CONSTRAINT ck_video_image CHECK ( imageformat IN ( 'MP4', 'AVI', 'MOV', 'FLV' ) ),
    CONSTRAINT ck_video_quality CHECK ( quality IN ( '240p', '360p', '480p', '720p', '1080p',
                                                     '2160p', '4320p' ) ),
    CONSTRAINT ck_video_duration CHECK ( duration BETWEEN 1 AND 600 ),
    CONSTRAINT ck_video_episode CHECK ( episodenum > 0 ),
    CONSTRAINT ck_video_country CHECK ( country = upper(country) ),
    CONSTRAINT ck_video_lastbroadcast CHECK ( EXTRACT(YEAR FROM lastbroadcast) >= yearfirstbroadcast ),
    CONSTRAINT ck_video_endavailability CHECK ( endavailability >= lastbroadcast + 7 ),
    CONSTRAINT ck_video_nextbroadcast CHECK ( nextbroadcast IS NULL
                                              OR nextbroadcast > lastbroadcast )
);

CREATE TABLE archive (
    idvideo             INTEGER,
    idprogram           INTEGER NOT NULL,
    videopath           VARCHAR2(512) NOT NULL,
    videotitle          VARCHAR2(255) NOT NULL,
    description         VARCHAR2(2000),
    duration            NUMBER(10) NOT NULL,
    yearfirstbroadcast  NUMBER(15) DEFAULT EXTRACT(YEAR FROM sysdate) NOT NULL,
    lastbroadcast       DATE DEFAULT sysdate NOT NULL,
    endavailability     DATE DEFAULT sysdate + 7 NOT NULL,
    nextbroadcast       DATE,
    episodenum          NUMBER(15) NOT NULL,
    country             CHAR(2) NOT NULL,
    quality             VARCHAR2(7) NOT NULL,
    imageformat         CHAR(3) NOT NULL,
    CONSTRAINT pk_archive PRIMARY KEY ( idvideo ),
    CONSTRAINT fk_archive FOREIGN KEY ( idprogram )
        REFERENCES program
            ON DELETE CASCADE,
    CONSTRAINT uc_archive UNIQUE ( idprogram,
                                   videotitle ),
    CONSTRAINT ck_archive_path CHECK ( videopath LIKE '../videos/%' ),
    CONSTRAINT ck_archive_imageformat CHECK ( imageformat IN ( 'MP4', 'AVI', 'MOV', 'FLV' ) ),
    CONSTRAINT ck_archive_quality CHECK ( quality IN ( '240p', '360p', '480p', '720p', '1080p',
                                                       '2160p', '4320p' ) ),
    CONSTRAINT ck_archive_duration CHECK ( duration BETWEEN 1 AND 600 ),
    CONSTRAINT ck_archive_episodenum CHECK ( episodenum > 0 ),
    CONSTRAINT ck_archive_country CHECK ( country = upper(country) ),
    CONSTRAINT ck_archive_lastbroadcast CHECK ( EXTRACT(YEAR FROM lastbroadcast) >= yearfirstbroadcast ),
    CONSTRAINT ck_archive_endavailability CHECK ( endavailability >= lastbroadcast + 7 ),
    CONSTRAINT ck_archive_nextbroadcast CHECK ( nextbroadcast IS NULL
                                                OR nextbroadcast > lastbroadcast )
);

CREATE TABLE subscription (
    idclient   INTEGER,
    idprogram  INTEGER,
    CONSTRAINT pk_subscription PRIMARY KEY ( idclient,
                                             idprogram ),
    CONSTRAINT fk_subscription_program FOREIGN KEY ( idprogram )
        REFERENCES program ( idprogram )
            ON DELETE CASCADE,
    CONSTRAINT fk_subscription_client FOREIGN KEY ( idclient )
        REFERENCES client ( idclient )
            ON DELETE CASCADE
);

CREATE TABLE favorite (
    idclient  INTEGER,
    idvideo   INTEGER,
    CONSTRAINT pk_favorite PRIMARY KEY ( idclient,
                                         idvideo ),
    CONSTRAINT fk_favorite_client FOREIGN KEY ( idclient )
        REFERENCES client ( idclient )
            ON DELETE CASCADE,
    CONSTRAINT fk_favorite_video FOREIGN KEY ( idvideo )
        REFERENCES video ( idvideo )
            ON DELETE CASCADE
);

CREATE TABLE interest (
    idclient    INTEGER,
    idcategory  INTEGER,
    CONSTRAINT pk_interest PRIMARY KEY ( idclient,
                                         idcategory ),
    CONSTRAINT fk_interest_client FOREIGN KEY ( idclient )
        REFERENCES client ( idclient )
            ON DELETE CASCADE,
    CONSTRAINT fk_interest_category FOREIGN KEY ( idcategory )
        REFERENCES category ( idcategory )
            ON DELETE CASCADE
);

CREATE TABLE historical (
    idclient     INTEGER,
    idvideo      INTEGER,
    viewingdate  DATE DEFAULT sysdate NOT NULL,
    CONSTRAINT pk_historical PRIMARY KEY ( idclient,
                                           idvideo,
                                           viewingdate ),
    CONSTRAINT fk_historical_client FOREIGN KEY ( idclient )
        REFERENCES client ( idclient )
            ON DELETE CASCADE,
    CONSTRAINT fk_historical_video FOREIGN KEY ( idvideo )
        REFERENCES video ( idvideo )
            ON DELETE CASCADE
);
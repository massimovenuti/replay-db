CREATE TABLE category
(
    idCategory    INTEGER,
    categoryTitle VARCHAR2(255) NOT NULL, 
    categoryDesc  VARCHAR2(1000),
    PRIMARY KEY (idCategory),
    CONSTRAINT UC_CATEGORY UNIQUE (categoryTitle)
);

CREATE TABLE program
(
    idProgram    INTEGER,
    idCategory   INTEGER       NOT NULL,
    programTitle VARCHAR2(255) NOT NULL,
    programDesc  VARCHAR2(1000),
    CONSTRAINT PK_program PRIMARY KEY (idProgram),
    CONSTRAINT FK_program FOREIGN KEY (idCategory) REFERENCES category ON DELETE CASCADE,
    CONSTRAINT UC_program UNIQUE (programTitle)
);

CREATE TABLE client
(
    idClient    INTEGER,
    login       VARCHAR2(32)        NOT NULL,
    password    VARCHAR2(63)        NOT NULL,
    firstName   VARCHAR2(127)       NOT NULL,
    lastName    VARCHAR2(127)       NOT NULL,
    gender      CHAR(1),
    nationality CHAR(2)             NOT NULL,
    city        VARCHAR(127),
    street      VARCHAR(255),
    postalCode  VARCHAR2(31),
    birthDate   DATE,
    mail        VARCHAR2(255)       NOT NULL,
    subscribed  CHAR(1) DEFAULT 'N' NOT NULL,
    CONSTRAINT PK_client PRIMARY KEY (idClient),
    CONSTRAINT UC_client_login UNIQUE (login),
    CONSTRAINT UC_client_mail UNIQUE (mail),
    CONSTRAINT CK_client_password CHECK (LENGTH(password) > 7),
    CONSTRAINT CK_client_mail CHECK (mail LIKE '%@%.%'),
    CONSTRAINT CK_client_gender CHECK (gender IN ('M', 'F')),
    CONSTRAINT CK_client_subscribed CHECK (subscribed IN ('Y', 'N')),
    CONSTRAINT CK_client_nationality CHECK (nationality = UPPER(nationality))
);

CREATE TABLE video
(
    idVideo            INTEGER,
    idProgram          INTEGER                                       NOT NULL,
    videoPath          VARCHAR2(512)                                 NOT NULL,
    videoTitle         VARCHAR2(255)                                 NOT NULL,
    videoDesc          VARCHAR2(2000),
    duration           NUMBER(10)                                    NOT NULL,
    yearFirstBroadcast NUMBER(15) DEFAULT EXTRACT(YEAR FROM SYSDATE) NOT NULL,
    lastBroadcast      DATE       DEFAULT SYSDATE                    NOT NULL,
    endAvailability    DATE       DEFAULT SYSDATE + 7                NOT NULL,
    nextBroadcast      DATE,
    episodeNum         NUMBER(15)                                    NOT NULL,
    country            CHAR(2)                                       NOT NULL,
    quality            VARCHAR2(7)                                   NOT NULL,
    imageFormat        CHAR(3)                                       NOT NULL,
    CONSTRAINT PK_video PRIMARY KEY (idVideo),
    CONSTRAINT FK_video FOREIGN KEY (idProgram) REFERENCES program ON DELETE CASCADE,
    CONSTRAINT UC_video UNIQUE (idProgram, videoTitle),
    CONSTRAINT CK_video_path CHECK (videoPath LIKE '../videos/%'),
    CONSTRAINT CK_video_image CHECK (imageFormat IN ('MP4', 'AVI', 'MOV', 'FLV')),
    CONSTRAINT CK_video_quality CHECK (quality IN ('240p', '360p', '480p', '720p', '1080p', '2160p', '4320p')),
    CONSTRAINT CK_video_duration CHECK (duration BETWEEN 1 AND 600),
    CONSTRAINT CK_video_episode CHECK (episodeNum > 0),
    CONSTRAINT CK_video_country CHECK (country = UPPER(country)),
    CONSTRAINT CK_video_lastBroadcast CHECK (EXTRACT(YEAR FROM lastBroadcast) >= yearFirstBroadcast),
    CONSTRAINT CK_video_endAvailability CHECK (endAvailability >= lastBroadcast + 7),
    CONSTRAINT CK_video_nextBroadcast CHECK (nextBroadcast IS NULL OR nextBroadcast > lastBroadcast)
);

CREATE TABLE archive
(
    idVideo            INTEGER,
    idProgram          INTEGER                                       NOT NULL,
    videoPath          VARCHAR2(512)                                 NOT NULL,
    videoTitle         VARCHAR2(255)                                 NOT NULL,
    description        VARCHAR2(2000),
    duration           NUMBER(10)                                    NOT NULL,
    yearFirstBroadcast NUMBER(15) DEFAULT EXTRACT(YEAR FROM SYSDATE) NOT NULL,
    lastBroadcast      DATE       DEFAULT SYSDATE                    NOT NULL,
    endAvailability    DATE       DEFAULT SYSDATE + 7                NOT NULL,
    nextBroadcast      DATE,
    episodeNum         NUMBER(15)                                    NOT NULL,
    country            CHAR(2)                                       NOT NULL,
    quality            VARCHAR2(7)                                   NOT NULL,
    imageFormat        CHAR(3)                                       NOT NULL,
    CONSTRAINT PK_archive PRIMARY KEY (idVideo),
    CONSTRAINT FK_archive FOREIGN KEY (idProgram) REFERENCES program ON DELETE CASCADE,
    CONSTRAINT UC_archive UNIQUE (idProgram, videoTitle),
    CONSTRAINT CK_archive_path CHECK (videoPath LIKE '../videos/%'),
    CONSTRAINT CK_archive_imageFormat CHECK (imageFormat IN ('MP4', 'AVI', 'MOV', 'FLV')),
    CONSTRAINT CK_archive_quality CHECK (quality IN ('240p', '360p', '480p', '720p', '1080p', '2160p', '4320p')),
    CONSTRAINT CK_archive_duration CHECK (duration BETWEEN 1 AND 600),
    CONSTRAINT CK_archive_episodeNum CHECK (episodeNum > 0),
    CONSTRAINT CK_archive_country CHECK (country = UPPER(country)),
    CONSTRAINT CK_archive_lastBroadcast CHECK (EXTRACT(YEAR FROM lastBroadcast) >= yearFirstBroadcast),
    CONSTRAINT CK_archive_endAvailability CHECK (endAvailability >= lastBroadcast + 7),
    CONSTRAINT CK_archive_nextBroadcast CHECK (nextBroadcast IS NULL OR nextBroadcast > lastBroadcast)
);

CREATE TABLE subscription
(
    idClient  INTEGER,
    idProgram INTEGER,
    CONSTRAINT PK_subscription PRIMARY KEY (idClient, idProgram),
    CONSTRAINT FK_subscription_program FOREIGN KEY (idProgram) REFERENCES program (idProgram) ON DELETE CASCADE,
    CONSTRAINT FK_subscription_client FOREIGN KEY (idClient) REFERENCES client (idClient) ON DELETE CASCADE
);


CREATE TABLE favorite
(
    idClient INTEGER,
    idVideo  INTEGER,
    CONSTRAINT PK_favorite PRIMARY KEY (idClient, idVideo),
    CONSTRAINT FK_favorite_client FOREIGN KEY (idClient) REFERENCES client (idClient) ON DELETE CASCADE,
    CONSTRAINT FK_favorite_video FOREIGN KEY (idVideo) REFERENCES video (idVideo) ON DELETE CASCADE
);


CREATE TABLE interest
(
    idClient   INTEGER,
    idCategory INTEGER,
    CONSTRAINT PK_interest PRIMARY KEY (idClient, idCategory),
    CONSTRAINT FK_interest_client FOREIGN KEY (idClient) REFERENCES client (idClient) ON DELETE CASCADE,
    CONSTRAINT FK_interest_category FOREIGN KEY (idCategory) REFERENCES category (idCategory) ON DELETE CASCADE
);


CREATE TABLE historical
(
    idClient    INTEGER,
    idVideo     INTEGER,
    viewingDate DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT PK_historical PRIMARY KEY (idClient, idVideo, viewingDate),
    CONSTRAINT FK_historical_client FOREIGN KEY (idClient) REFERENCES client (idClient) ON DELETE CASCADE,
    CONSTRAINT FK_historical_video FOREIGN KEY (idVideo) REFERENCES video (idVideo) ON DELETE CASCADE
);

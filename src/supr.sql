create or replace trigger archivage
before 
    delete on VIDEO
for each row
begin
    insert into archive VALUES (
        :old.IDVIDEO, :old.IDPROGRAM,
        :old.VIDEOPATH,
        :old.VIDEOTITLE,
        :old.VIDEODESC,
        :old.DURATION,
        :old.YEARFIRSTBROADCAST,
        :old.LASTBROADCAST,
        :old.ENDAVAILABILITY,
        :old.NEXTBROADCAST,
        :old.EPISODENUM,
        :old.COUNTRY,
        :old.QUALITY,
        :old.IMAGEFORMAT
    );
 end;
/

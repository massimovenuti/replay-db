create or replace function video_2_json (ID_VID_p in VIDEO.IDVIDEO%type) return VARCHAR2 is
    row_v VIDEO%ROWTYPE;
begin
    select * into row_v from VIDEO where IDVIDEO = ID_VID_p;
    return ( '{'
        || '"IDVIDEO": "' || row_v.IDVIDEO || '",'
        || '"IDPROGRAM": "' || row_v.IDPROGRAM || '",'
        || '"VIDEOPATH": "' || row_v.VIDEOPATH || '",'
        || '"VIDEOTITLE": "' || row_v.VIDEOTITLE || '",'
        || '"VIDEODESC": "' || row_v.VIDEODESC || '",'
        || '"DURATION": "' || row_v.DURATION || '",'
        || '"YEARFIRSTBROADCAST": "' || row_v.YEARFIRSTBROADCAST || '",'
        || '"LASTBROADCAST": "' || row_v.LASTBROADCAST || '",'
        || '"ENDAVAILABILITY": "' || row_v.ENDAVAILABILITY || '",'
        || '"NEXTBROADCAST": "' || row_v.NEXTBROADCAST || '",'
        || '"EPISODENUM": "' || row_v.EPISODENUM || '",'
        || '"COUNTRY": "' || row_v.COUNTRY || '",'
        || '"QUALITY": "' || row_v.QUALITY || '",'
        || '"IMAGEFORMAT": "' || row_v.IMAGEFORMAT || '"}'
    );
end;

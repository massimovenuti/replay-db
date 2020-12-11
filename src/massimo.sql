set serveroutput on;

/*
 * Procédures et fonctions PL/SQL
 */

create or replace procedure newsletter
is
begin 
    dbms_output.put_line('Découvrez les nouvelles sorties de la semaine !');
    for video_c in (select videotitle from video where lastbroadcast > (SYSDATE - 7))
    loop
        dbms_output.put_line(video_c.col_name);
    end loop;
end;
/

begin
    newsletter;
end;
/

/**
 * Des suggestions de vidéos à regarder seront aussi générées. Elles seront basées uniquement sur la
 * popularité des vidéos par catégories. La popularité sera basée sur le nombre de visionnages au cours
 * des deux dernières semaines afin de favoriser les vidéos récentes.
 */
create or replace procedure reference(idclient_p integer)
is
cursor ref_c is  
    with latest_views as (
        select idvideo
        from historical
        where viewingdate > (SYSDATE - 14)
    )
    select videotitle
    from video
    natural full join latest_views
    natural join program
    natural join category
    where idcategory in ( 
        select idcategory 
        from interest 
        where idclient = idclient_p
        )
    group by idcategory, videotitle
    order by count(idvideo) desc;
    
i_v integer;    
begin
    i_v := 1;
    for ref_r in ref_c
    loop
        DBMS_OUTPUT.PUT_LINE(i_v || ' - ' || ref_r.videotitle);
        i_v := i_v + 1;
    end loop;
end;
/

begin
    reference(1);  
end;
/

/*
 * Contraintes d'intégrité
 */

create trigger favs
after insert on favorite

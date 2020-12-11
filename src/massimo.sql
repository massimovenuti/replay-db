set serveroutput on;

/**
 * Procédures et fonctions PL/SQL
 */

/**
 * 2. Définir une procédure qui généra un texte initial de la newsletter en y ajoutant la liste de
 * toute les sortie de la semaine.
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
 * 3. Générer la liste des vidéos populaires, conseillé pour un utilisateur, c’est à dire fonction des
 * catégories de vidéos qu’il suit.
 * 
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

/**
 * Contraintes d'intégrité
 */

/**
 * 1. Un utilisateur aura un maximum de 300 vidéos en favoris
 */
create or replace trigger favs
before insert on favorite
for each row
declare
    nbfavs_v integer;
begin
    select count(*) into nbfavs_v
    from favorite
    where idclient = :new.idclient;
    
    if nbfavs_v >= 300 then
        raise_application_error(-20000, 'Nombre de favoris maximal atteint pour l''utilisateur ' ||  :new.idclient);
    end if;
end;
/

create or replace procedure test_trigger_favs 
is
begin
    FOR i IN 100..399 LOOP
          insert into video values (i, 1, '../videos/path', to_char(i), 'desc', 32, 2000, SYSDATE-2,  SYSDATE+10, SYSDATE+12, 1, 'FR', '720p', 'AVI');
          insert into favorite values (1, i);
          commit;
        END LOOP;
    insert into video values (400, 1, '../videos/path', '400', 'desc', 32, 2000, SYSDATE-2, SYSDATE+10, SYSDATE+12, 1, 'FR', '720p', 'AVI');
    insert into favorite values (1, 400);    
    commit;
end;
/

begin
    test_trigger_favs;
end;
/

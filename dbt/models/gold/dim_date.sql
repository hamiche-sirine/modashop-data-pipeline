-- =====================================================
-- dim_date : dimension DATE (calendrier) du schéma en étoile
-- Grain : une ligne = un jour
-- Source : AUCUNE — la table est générée par SQL
-- =====================================================

with jours as (

    -- 1) On génère une ligne par jour, du 01/01/2025 au 31/12/2027
    select
        generate_series(
            '2025-01-01'::date,      -- date de début
            '2027-12-31'::date,      -- date de fin
            interval '1 day'         -- pas : un jour
        )::date as date_jour

)

-- 2) Pour chaque jour, on calcule ses informations de calendrier
select
    date_jour,                                              -- clé primaire

    extract(year    from date_jour)::int    as annee,
    extract(quarter from date_jour)::int    as trimestre,
    extract(month   from date_jour)::int    as mois,

    (array['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
           'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
    )[extract(month from date_jour)::int]   as nom_mois,

    to_char(date_jour, 'YYYY-MM')           as annee_mois,
    extract(day     from date_jour)::int    as jour_mois,

    extract(isodow  from date_jour)::int    as jour_semaine,   -- 1 = lundi … 7 = dimanche

    (array['Lundi', 'Mardi', 'Mercredi', 'Jeudi',
           'Vendredi', 'Samedi', 'Dimanche']
    )[extract(isodow from date_jour)::int]  as nom_jour,

    extract(isodow from date_jour) in (6, 7) as est_weekend    -- true si samedi ou dimanche

from jours
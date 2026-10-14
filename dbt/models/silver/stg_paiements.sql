-- Silver : paiements du prestataire, une colonne par champ, valeurs nettoyées

with source as (

    select * from {{ source('bronze', 'paiements') }}

),

extrait as (

    -- 1. Sortir chaque champ du JSON pour en faire une colonne (encore en texte)
    select
        trim(donnees->>'id_paiement')                       as id_paiement,
        donnees->>'id_commande'                             as id_commande_brut,
        replace(trim(donnees->>'montant'), ',', '.')        as montant_brut,
        donnees->>'moyen'                                   as moyen_brut,
        donnees->>'statut'                                  as statut_brut,
        _fichier_source,
        _date_chargement
    from source

),

avec_tickets as (

    -- 2. Si le prestataire renvoie un paiement dans un autre fichier, on garde le plus récent
    select
        *,
        row_number() over (
            partition by id_paiement
            order by _date_chargement desc
        ) as ticket
    from extrait

)

-- 3. Nettoyer et typer
select
    id_paiement,
    id_commande_brut::int                           as id_commande,

    case
        when montant_brut ~ '^[0-9]+(\.[0-9]+)?$'
            then montant_brut::numeric(10, 2)
        else null
    end                                             as montant,

    upper(trim(moyen_brut))                         as moyen_paiement,
    coalesce(upper(trim(statut_brut)), 'INCONNU')   as statut,
    montant_brut                                    as montant_origine,
    _fichier_source                                 as fichier_source
from avec_tickets
where ticket = 1
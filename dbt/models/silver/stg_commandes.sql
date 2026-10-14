-- Silver : commandes nettoyées, une seule ligne par commande (la version la plus récente)

with source as (

    select * from {{ source('bronze', 'commandes') }}

),

avec_tickets as (

    -- Une file par commande, la version la plus récente reçoit le ticket 1
    select
        *,
        row_number() over (
            partition by id_commande
            order by date_modification::timestamp desc
        ) as ticket
    from source

),

derniere_version as (

    select * from avec_tickets
    where ticket = 1

)

select
    id_commande::int                as id_commande,
    id_client::int                  as id_client,
    date_commande::timestamp        as date_commande,
    upper(trim(statut))             as statut,
    date_modification::timestamp    as date_modification
from derniere_version
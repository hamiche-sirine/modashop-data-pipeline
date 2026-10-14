-- Silver : produits nettoyés, une seule ligne par produit (la version la plus récente)

with source as (

    select * from {{ source('bronze', 'produits') }}

),

avec_tickets as (

    -- Une file par produit, la version la plus récente reçoit le ticket 1
    select
        *,
        row_number() over (
            partition by id_produit
            order by date_modification::timestamp desc
        ) as ticket
    from source

),

derniere_version as (

    select * from avec_tickets
    where ticket = 1

)

select
    id_produit::int                 as id_produit,
    trim(nom)                       as nom,
    upper(trim(categorie))          as categorie,
    prix::numeric(10, 2)            as prix,
    date_modification::timestamp    as date_modification
from derniere_version
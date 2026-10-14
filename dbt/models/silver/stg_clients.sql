-- Silver : clients nettoyés, une seule ligne par client (la version la plus récente)

with source as (

    select * from {{ source('bronze', 'clients') }}

),

avec_tickets as (

    -- Une file par client, la version la plus récente reçoit le ticket 1
    select
        *,
        row_number() over (
            partition by id_client
            order by date_modification::timestamp desc
        ) as ticket
    from source

),

derniere_version as (

    select * from avec_tickets
    where ticket = 1

)

select
    id_client::int                  as id_client,
    trim(nom)                       as nom,
    lower(trim(email))              as email,
    trim(ville)                     as ville,
    case
        when upper(trim(region)) = 'IDF' then 'ÎLE-DE-FRANCE'
        else upper(trim(region))
    end                             as region,
    date_inscription::date          as date_inscription,
    date_modification::timestamp    as date_modification
from derniere_version
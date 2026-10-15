-- =====================================================
-- dim_client : dimension CLIENT du schéma en étoile
-- Grain : une ligne = un client
-- Source : silver.stg_clients (déjà nettoyé et dédoublonné)
-- =====================================================

select
    id_client,            -- clé primaire : relie la dimension aux ventes
    nom,
    ville,
    region,
    date_inscription
from {{ ref('stg_clients') }}
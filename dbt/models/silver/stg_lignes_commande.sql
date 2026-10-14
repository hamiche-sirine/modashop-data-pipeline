-- Silver : articles de chaque commande, une ligne par article
-- Pas de dédoublonnage : la table est rechargée en entier à chaque ingestion

with source as (

    select * from {{ source('bronze', 'lignes_commande') }}

)

select
    id_ligne::int                                    as id_ligne,
    id_commande::int                                 as id_commande,
    id_produit::int                                  as id_produit,
    quantite::int                                    as quantite,
    prix_unitaire::numeric(10, 2)                    as prix_unitaire,
    (quantite::int * prix_unitaire::numeric(10, 2))  as montant_ligne
from source
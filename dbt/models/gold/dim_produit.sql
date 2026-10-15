-- =====================================================
-- dim_produit : dimension PRODUIT du schéma en étoile
-- Grain : une ligne = un produit
-- Source : silver.stg_produits (déjà nettoyé et dédoublonné)
-- =====================================================

select
    id_produit,                         -- clé primaire : relie la dimension aux ventes
    nom         as nom_produit,         -- renommé pour éviter la confusion avec dim_client.nom
    categorie,
    prix        as prix_catalogue,      -- prix ACTUEL de l'étiquette : ne pas utiliser pour le CA

    -- Enrichissement : on classe chaque produit dans une gamme de prix
    case
        when prix < 30 then 'ENTREE DE GAMME'
        when prix < 70 then 'MILIEU DE GAMME'
        else                'HAUT DE GAMME'
    end         as gamme_prix

from {{ ref('stg_produits') }}
-- =====================================================
-- fait_ventes : table de FAITS (centre du schéma en étoile)
-- Grain : une ligne = un produit acheté dans une commande
-- Sources : silver.stg_lignes_commande + silver.stg_commandes
-- Règle métier : CA = montant des lignes dont la commande est PAYEE
-- =====================================================

with lignes as (

    -- Le détail des tickets : quoi, combien, à quel prix
    select * from {{ ref('stg_lignes_commande') }}

),

commandes as (

    -- Le haut des tickets : qui, quand, quel statut
    select * from {{ ref('stg_commandes') }}

)

select
    -- 🔑 Clés (les branches de l'étoile)
    l.id_ligne,                                  -- clé primaire du fait
    l.id_commande,                               -- dimension dégénérée (pour compter les commandes)
    c.id_client,                                 -- → dim_client
    l.id_produit,                                -- → dim_produit
    c.date_commande::date      as date_commande, -- → dim_date (on garde le jour, sans l'heure)

    -- 🏷️ Contexte
    c.statut,

    -- 🔢 Mesures
    l.quantite,
    l.prix_unitaire,                             -- prix PAYÉ au moment de l'achat
    l.montant_ligne            as montant,       -- quantite × prix_unitaire

    -- Règle métier du CA appliquée UNE SEULE FOIS, ici
    case
        when c.statut = 'PAYEE' then l.montant_ligne
        else 0
    end                        as montant_ca

from lignes l
left join commandes c
    on l.id_commande = c.id_commande
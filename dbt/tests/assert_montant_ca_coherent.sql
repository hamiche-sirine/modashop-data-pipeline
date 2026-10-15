-- =====================================================
-- Test singulier : la règle métier du chiffre d'affaires
-- Règle : montant_ca = montant si PAYEE, sinon 0
-- Le test ÉCHOUE s'il renvoie au moins une ligne
-- =====================================================

select
    id_ligne,
    statut,
    montant,
    montant_ca
from {{ ref('fait_ventes') }}
where
    -- cas 1 : commande payée, mais le CA ne vaut pas le montant
    (statut = 'PAYEE'  and montant_ca <> montant)
    or
    -- cas 2 : commande non payée, mais elle compte quand même dans le CA
    (statut <> 'PAYEE' and montant_ca <> 0)
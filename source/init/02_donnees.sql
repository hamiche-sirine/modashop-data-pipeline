-- Données de départ du site ModaShop

INSERT INTO clients (nom, email, ville, region, date_inscription) VALUES
('Léa Martin',    'lea.martin@mail.fr',    'Paris',     'Île-de-France',               '2025-03-10'),
('Karim Benali',  'karim.benali@mail.fr',  'Toulouse',  'Occitanie',                   '2025-04-02'),
('Emma Dubois',   'emma.dubois@mail.fr',   'Lyon',      'Auvergne-Rhône-Alpes',        '2025-05-15'),
('Hugo Petit',    'hugo.petit@mail.fr',    'Paris',     'IDF',                         '2025-06-01'),
('Inès Moreau',   'ines.moreau@mail.fr',   'Rennes',    'Bretagne',                    '2025-07-20'),
('Yanis Haddad',  'yanis.haddad@mail.fr',  'Lyon',      ' auvergne-rhône-alpes ',      '2025-08-08'),
('Sofia Rossi',   'sofia.rossi@mail.fr',   'Marseille', 'Provence-Alpes-Côte d''Azur', '2026-09-25'),
('Nathan Leroy',  'nathan.leroy@mail.fr',  'Lille',     'Hauts-de-France',             '2025-11-30');

INSERT INTO produits (nom, categorie, prix) VALUES
('Veste en jean',    'Vêtements',   89.90),
('T-shirt blanc',    'Vêtements',   22.50),
('Baskets urbaines', 'Chaussures',  75.00),
('Casquette',        'Accessoires', 18.00),
('Sac à dos',        'Accessoires', 45.00),
('Pull en laine',    'Vêtements',   59.90);

INSERT INTO commandes (id_client, date_commande, statut) VALUES
(1, '2026-09-20 10:15', 'PAYEE'),
(2, '2026-09-20 14:30', 'PAYEE'),
(3, '2026-09-21 09:05', 'PAYEE'),
(1, '2026-09-22 18:40', 'PAYEE'),
(4, '2026-09-22 20:10', 'ANNULEE'),
(5, '2026-09-23 11:00', 'PAYEE'),
(2, '2026-09-24 16:20', 'PAYEE'),
(6, '2026-09-25 13:45', 'PAYEE'),
(3, '2026-09-26 08:30', 'REMBOURSEE'),
(1, '2026-09-27 21:00', 'PAYEE'),
(4, '2026-09-28 12:00', 'PAYEE'),
(6, '2026-09-28 17:25', 'ANNULEE'),
(8, '2026-09-29 10:10', 'PAYEE'),
(5, '2026-09-30 15:50', 'EN_ATTENTE');

INSERT INTO lignes_commande (id_commande, id_produit, quantite, prix_unitaire) VALUES
(1, 1, 1, 89.90),
(2, 2, 2, 22.50),
(3, 3, 1, 75.00),
(4, 4, 1, 18.00),
(5, 5, 1, 45.00),
(6, 1, 1, 89.90),
(6, 4, 1, 18.00),
(7, 3, 1, 75.00),
(8, 2, 3, 22.50),
(9, 4, 2, 18.00),
(10, 3, 1, 75.00),
(10, 6, 1, 59.90),
(11, 2, 1, 22.50),
(12, 5, 1, 45.00),
(13, 6, 2, 59.90),
(13, 4, 1, 18.00),
(14, 1, 1, 89.90);
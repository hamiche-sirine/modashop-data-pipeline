-- Base source : le site ModaShop (OLTP, normalisée)

CREATE TABLE clients (
    id_client          SERIAL PRIMARY KEY,
    nom                VARCHAR(100) NOT NULL,
    email              VARCHAR(150) NOT NULL UNIQUE,
    ville              VARCHAR(100),
    region             VARCHAR(100),
    date_inscription   DATE NOT NULL,
    date_modification  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE produits (
    id_produit         SERIAL PRIMARY KEY,
    nom                VARCHAR(100) NOT NULL,
    categorie          VARCHAR(50) NOT NULL,
    prix               NUMERIC(10, 2) NOT NULL,
    date_modification  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE commandes (
    id_commande        SERIAL PRIMARY KEY,
    id_client          INT NOT NULL REFERENCES clients(id_client),
    date_commande      TIMESTAMP NOT NULL,
    statut             VARCHAR(20) NOT NULL,
    date_modification  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE lignes_commande (
    id_ligne           SERIAL PRIMARY KEY,
    id_commande        INT NOT NULL REFERENCES commandes(id_commande),
    id_produit         INT NOT NULL REFERENCES produits(id_produit),
    quantite           INT NOT NULL,
    prix_unitaire      NUMERIC(10, 2) NOT NULL
);
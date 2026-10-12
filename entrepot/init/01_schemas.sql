-- Les trois couches de l'entrepôt ModaShop

-- Bronze : copie exacte des sources, jamais modifiée
CREATE SCHEMA bronze;

-- Silver : données nettoyées, typées, dédoublonnées
CREATE SCHEMA silver;

-- Gold : données modélisées pour le métier (schéma en étoile)
CREATE SCHEMA gold;
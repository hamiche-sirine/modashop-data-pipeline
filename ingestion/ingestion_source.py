from datetime import datetime

from psycopg2.extras import execute_values

from connexions import connexion_entrepot, connexion_source

# Les tables du site à copier
TABLES = ["clients", "produits", "commandes", "lignes_commande"]


def copier_table(table, cur_source, cur_entrepot, date_chargement):
    """Copie une table de la source vers le bronze (chargement complet)."""

    # 1. Lire toute la table dans la source
    cur_source.execute(f"SELECT * FROM {table};")
    lignes = cur_source.fetchall()
    colonnes = [col[0] for col in cur_source.description]

    # 2. Créer la table bronze si elle n'existe pas encore (tout en texte)
    colonnes_sql = ", ".join(f"{c} TEXT" for c in colonnes)
    cur_entrepot.execute(
        f"CREATE TABLE IF NOT EXISTS bronze.{table} "
        f"({colonnes_sql}, _date_chargement TIMESTAMP);"
    )

    # 3. Vider la table bronze
    cur_entrepot.execute(f"TRUNCATE bronze.{table};")

    # 4. Préparer les lignes : valeurs en texte + date de chargement
    lignes_a_inserer = [
        tuple(str(v) if v is not None else None for v in ligne) + (date_chargement,)
        for ligne in lignes
    ]

    # 5. Insérer toutes les lignes d'un coup
    execute_values(
        cur_entrepot,
        f"INSERT INTO bronze.{table} ({', '.join(colonnes)}, _date_chargement) VALUES %s",
        lignes_a_inserer,
    )

    print(f"  bronze.{table} : {len(lignes)} lignes copiées")


def main():
    print("Ingestion de la source vers le bronze...")
    date_chargement = datetime.now()

    source = connexion_source()
    entrepot = connexion_entrepot()

    cur_source = source.cursor()
    cur_entrepot = entrepot.cursor()

    for table in TABLES:
        copier_table(table, cur_source, cur_entrepot, date_chargement)

    # Valider toutes les écritures d'un coup
    entrepot.commit()

    source.close()
    entrepot.close()
    print("Terminé.")


if __name__ == "__main__":
    main()
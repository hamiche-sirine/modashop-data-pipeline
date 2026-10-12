from datetime import datetime

from psycopg2.extras import execute_values

from connexions import connexion_entrepot, connexion_source

# Chaque table a sa stratégie
TABLES_INCREMENTALES = ["clients", "produits", "commandes"]  # ont une date_modification
TABLES_COMPLETES = ["lignes_commande"]                       # pas de date_modification

# Marque-page de départ : une date très ancienne, pour tout copier la 1re fois
DATE_DEPART = "1900-01-01"


# ---------- Le marque-page (watermark) ----------

def creer_table_suivi(cur_entrepot):
    """Crée la table qui retient le marque-page de chaque table."""
    cur_entrepot.execute(
        """
        CREATE TABLE IF NOT EXISTS bronze._suivi_ingestion (
            table_source          TEXT PRIMARY KEY,
            derniere_modification TIMESTAMP
        );
        """
    )


def lire_marque_page(table, cur_entrepot):
    """Renvoie la dernière date déjà copiée, ou DATE_DEPART la 1re fois."""
    cur_entrepot.execute(
        "SELECT derniere_modification FROM bronze._suivi_ingestion WHERE table_source = %s;",
        (table,),
    )
    resultat = cur_entrepot.fetchone()
    return resultat[0] if resultat else DATE_DEPART


def enregistrer_marque_page(table, nouvelle_date, cur_entrepot):
    """Avance le marque-page (le crée s'il n'existe pas encore)."""
    cur_entrepot.execute(
        """
        INSERT INTO bronze._suivi_ingestion (table_source, derniere_modification)
        VALUES (%s, %s)
        ON CONFLICT (table_source)
        DO UPDATE SET derniere_modification = EXCLUDED.derniere_modification;
        """,
        (table, nouvelle_date),
    )


# ---------- Outils communs ----------

def creer_table_bronze(table, colonnes, cur_entrepot):
    colonnes_sql = ", ".join(f"{c} TEXT" for c in colonnes)
    cur_entrepot.execute(
        f"CREATE TABLE IF NOT EXISTS bronze.{table} "
        f"({colonnes_sql}, _date_chargement TIMESTAMP);"
    )


def inserer_lignes(table, colonnes, lignes, date_chargement, cur_entrepot):
    lignes_a_inserer = [
        tuple(str(v) if v is not None else None for v in ligne) + (date_chargement,)
        for ligne in lignes
    ]
    execute_values(
        cur_entrepot,
        f"INSERT INTO bronze.{table} ({', '.join(colonnes)}, _date_chargement) VALUES %s",
        lignes_a_inserer,
    )


# ---------- Les deux stratégies ----------

def copier_incremental(table, cur_source, cur_entrepot, date_chargement):
    """Copie seulement les lignes modifiées depuis le marque-page, et les AJOUTE."""
    marque_page = lire_marque_page(table, cur_entrepot)

    cur_source.execute(
        f"SELECT * FROM {table} WHERE date_modification > %s ORDER BY date_modification;",
        (marque_page,),
    )
    lignes = cur_source.fetchall()
    colonnes = [col[0] for col in cur_source.description]

    creer_table_bronze(table, colonnes, cur_entrepot)

    if lignes:
        inserer_lignes(table, colonnes, lignes, date_chargement, cur_entrepot)
        # Le nouveau marque-page = la date de modification la plus récente copiée
        position = colonnes.index("date_modification")
        nouvelle_date = max(ligne[position] for ligne in lignes)
        enregistrer_marque_page(table, nouvelle_date, cur_entrepot)

    print(f"  bronze.{table} [incrémental] : {len(lignes)} nouvelles lignes (marque-page : {marque_page})")


def copier_complet(table, cur_source, cur_entrepot, date_chargement):
    """Vide la table bronze puis recopie tout."""
    cur_source.execute(f"SELECT * FROM {table};")
    lignes = cur_source.fetchall()
    colonnes = [col[0] for col in cur_source.description]

    creer_table_bronze(table, colonnes, cur_entrepot)
    cur_entrepot.execute(f"TRUNCATE bronze.{table};")
    inserer_lignes(table, colonnes, lignes, date_chargement, cur_entrepot)

    print(f"  bronze.{table} [complet] : {len(lignes)} lignes copiées")


# ---------- Programme principal ----------

def main():
    print("Ingestion de la source vers le bronze...")
    date_chargement = datetime.now()

    source = connexion_source()
    entrepot = connexion_entrepot()
    cur_source = source.cursor()
    cur_entrepot = entrepot.cursor()

    creer_table_suivi(cur_entrepot)

    for table in TABLES_INCREMENTALES:
        copier_incremental(table, cur_source, cur_entrepot, date_chargement)

    for table in TABLES_COMPLETES:
        copier_complet(table, cur_source, cur_entrepot, date_chargement)

    # Données ET marque-pages validés ensemble : tout ou rien
    entrepot.commit()

    source.close()
    entrepot.close()
    print("Terminé.")


if __name__ == "__main__":
    main()
import json
from datetime import datetime
from pathlib import Path

from psycopg2.extras import Json

from connexions import connexion_entrepot

# Le dossier où le prestataire dépose ses fichiers
DOSSIER = Path(__file__).resolve().parent.parent / "data" / "api_paiements"


def creer_tables(cur):
    """Crée la table bronze des paiements et le carnet des fichiers chargés."""
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS bronze.paiements (
            donnees          JSONB,
            _fichier_source  TEXT,
            _date_chargement TIMESTAMP
        );
        """
    )
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS bronze._fichiers_charges (
            nom_fichier      TEXT PRIMARY KEY,
            nb_paiements     INT,
            _date_chargement TIMESTAMP
        );
        """
    )


def fichiers_deja_charges(cur):
    """Renvoie l'ensemble des noms de fichiers déjà chargés."""
    cur.execute("SELECT nom_fichier FROM bronze._fichiers_charges;")
    return {ligne[0] for ligne in cur.fetchall()}


def charger_fichier(chemin, cur, date_chargement):
    """Charge un fichier JSON : un paiement = une ligne, gardé tel quel."""
    with open(chemin, encoding="utf-8") as f:
        contenu = json.load(f)

    paiements = contenu.get("paiements", [])

    for paiement in paiements:
        cur.execute(
            "INSERT INTO bronze.paiements (donnees, _fichier_source, _date_chargement) "
            "VALUES (%s, %s, %s);",
            (Json(paiement), chemin.name, date_chargement),
        )

    # On note le fichier dans le carnet : il ne sera plus rechargé
    cur.execute(
        "INSERT INTO bronze._fichiers_charges (nom_fichier, nb_paiements, _date_chargement) "
        "VALUES (%s, %s, %s);",
        (chemin.name, len(paiements), date_chargement),
    )
    return len(paiements)


def main():
    print("Ingestion des paiements (JSON) vers le bronze...")
    date_chargement = datetime.now()

    entrepot = connexion_entrepot()
    cur = entrepot.cursor()
    creer_tables(cur)

    deja_charges = fichiers_deja_charges(cur)
    nouveaux = 0

    # sorted() : on charge les fichiers dans l'ordre des dates
    for chemin in sorted(DOSSIER.glob("paiements_*.json")):
        if chemin.name in deja_charges:
            print(f"  {chemin.name} : déjà chargé, ignoré")
            continue

        try:
            nb = charger_fichier(chemin, cur, date_chargement)
            print(f"  {chemin.name} : {nb} paiements chargés")
            nouveaux += 1
        except json.JSONDecodeError:
            # Fichier illisible : on le signale, sans bloquer les autres
            print(f"  {chemin.name} : ERREUR, JSON invalide, fichier ignoré")

    entrepot.commit()
    entrepot.close()
    print(f"Terminé : {nouveaux} nouveau(x) fichier(s) chargé(s).")


if __name__ == "__main__":
    main()
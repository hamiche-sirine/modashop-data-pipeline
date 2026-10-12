import os

import psycopg2
from dotenv import load_dotenv

# Lit le fichier .env et charge ses valeurs
load_dotenv()


def connexion_source():
    """Ouvre une connexion à la base du site (source)."""
    return psycopg2.connect(
        host="localhost",
        port=5433,
        dbname=os.getenv("SOURCE_DB_NAME"),
        user=os.getenv("SOURCE_DB_USER"),
        password=os.getenv("SOURCE_DB_PASSWORD"),
    )


def connexion_entrepot():
    """Ouvre une connexion à l'entrepôt de données."""
    return psycopg2.connect(
        host="localhost",
        port=5434,
        dbname=os.getenv("ENTREPOT_DB_NAME"),
        user=os.getenv("ENTREPOT_DB_USER"),
        password=os.getenv("ENTREPOT_DB_PASSWORD"),
    )
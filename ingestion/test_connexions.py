from connexions import connexion_entrepot, connexion_source

# Test de la source : on compte les clients
conn = connexion_source()
cur = conn.cursor()
cur.execute("SELECT COUNT(*) FROM clients;")
print("Source OK :", cur.fetchone()[0], "clients")
conn.close()

# Test de l'entrepôt : on liste les couches
conn = connexion_entrepot()
cur = conn.cursor()
cur.execute(
    "SELECT schema_name FROM information_schema.schemata "
    "WHERE schema_name IN ('bronze', 'silver', 'gold') ORDER BY schema_name;"
)
print("Entrepôt OK, couches :", [ligne[0] for ligne in cur.fetchall()])
conn.close()
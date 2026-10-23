import sqlite3

# Nom de la base et du fichier d'export
BASE_FICHIER = "projet.db"
EXPORT_FICHIER = "export_projet.sql"

def exporter_base():
    """Sauvegarde toute la base dans un fichier SQL lisible."""
    db = sqlite3.connect(BASE_FICHIER)
    with open(EXPORT_FICHIER, "w", encoding="utf-8") as f:
        for ligne in db.iterdump():
            f.write(f"{ligne}\n")
    db.close()
    print(f"Export terminé avec succès : {EXPORT_FICHIER}")

if __name__ == "__main__":
    exporter_base()
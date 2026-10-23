import os
import random
import sqlite3
from datetime import date, timedelta
from werkzeug.security import generate_password_hash

# Noms et prénoms réalistes
NOMS = [
    "Mbarga", "Ngo Bassa", "Fotso", "Atangana", "Njoya", "Ekane", 
    "Tchoupo", "Bello", "Kamga", "Ewodo", "Abena", "Mballa", 
    "Ndedi", "Mouelle", "Song", "Biya", "Bassong", "Tientcheu"
]
PRENOMS = [
    "Aline", "Paul", "Kevin", "Marie", "Ibrahim", "Sandra", 
    "Rose", "Moussa", "Samuel", "Chantal", "Christian", "Carine", 
    "Arthur", "Danielle", "Eric", "Florence", "Guy", "Helene"
]
VILLES = ["Douala", "Yaoundé", "Bafoussam", "Garoua", "Kribi", "Buea"]

# Les 4 spécialités imposées par le sujet
SPECIALITES = ["Généraliste", "Pédiatrie", "Gynécologie", "Cardiologie"]

# Créneaux de consultation par tranches de 30 min (8h à 12h)
CRENEAUX = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30"]

JOURS_SEMAINE = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"]

MOTIFS = [
    "Consultation de routine",
    "Fièvre persistante et maux de tête",
    "Suivi tension artérielle",
    "Douleurs abdominales",
    "Bilan de santé annuel",
    "Vaccination et contrôle pédiatrique",
    "Renouvellement d'ordonnance",
    "Certificat médical d'aptitude"
]

def initialiser_bdd(fichier_db="projet.db", fichier_schema="schema.sql"):
    """Supprime l'ancienne base et réexécute le schéma."""
    if os.path.exists(fichier_db):
        os.remove(fichier_db)
    
    conn = sqlite3.connect(fichier_db)
    with open(fichier_schema, mode="r", encoding="utf-8") as f:
        conn.executescript(f.read())
    conn.commit()
    return conn

def peupler_base(conn):
    cur = conn.cursor()

    # 1. Création du compte administrateur obligatoire
    cur.execute(
        "INSERT INTO administrateurs (login, empreinte) VALUES (?, ?)",
        ("admin", generate_password_hash("Admin!2026"))
    )

    # 2. Insertion de 8 médecins (2 par spécialité)
    medecins_data = [
        ("Dr Mbarga Jean", "Généraliste", "Lundi,Mardi,Mercredi,Jeudi,Vendredi"),
        ("Dr Ngo Bassa Sophie", "Généraliste", "Mardi,Mercredi,Jeudi,Vendredi,Samedi"),
        ("Dr Kamga Paul", "Pédiatrie", "Lundi,Mercredi,Vendredi"),
        ("Dr Abena Chantal", "Pédiatrie", "Mardi,Jeudi,Samedi"),
        ("Dr Mouelle Arthur", "Cardiologie", "Lundi,Mardi,Jeudi"),
        ("Dr Danielle Song", "Cardiologie", "Mercredi,Vendredi,Samedi"),
        ("Dr Fotso Patrick", "Gynécologie", "Lundi,Mardi,Mercredi,Vendredi"),
        ("Dr Carine Bello", "Gynécologie", "Mardi,Mercredi,Jeudi,Samedi")
    ]
    for nom, spec, jours in medecins_data:
        cur.execute(
            "INSERT INTO medecins (nom, specialite, photo, jours_consultation, actif) VALUES (?, ?, ?, ?, 1)",
            (nom, spec, "default_doc.png", jours)
        )
    nb_medecins = len(medecins_data)

    # 3. Insertion de 50 patients
    # Génération de numéros camerounais uniques commençant par 6
    telephones = [f"6{random.randint(50000000, 99999999)}" for _ in range(50)]
    telephones = list(set(telephones))
    while len(telephones) < 50:
        telephones.append(f"6{random.randint(50000000, 99999999)}")
        telephones = list(set(telephones))

    patients_ids = []
    for i in range(50):
        nom = random.choice(NOMS)
        prenom = random.choice(PRENOMS)
        tel = telephones[i]
        # Date de naissance réaliste (entre 1 et 70 ans)
        annee_naiss = date.today().year - random.randint(1, 70)
        date_naiss = f"{annee_naiss}-{random.randint(1,12):02d}-{random.randint(1,28):02d}"
        ville = random.choice(VILLES)
        
        cur.execute(
            "INSERT INTO patients (nom, prenom, telephone, date_naissance, ville) VALUES (?, ?, ?, ?, ?)",
            (nom, prenom, tel, date_naiss, ville)
        )
        patients_ids.append(cur.lastrowid)

    # 4. Insertion de 150 rendez-vous (sur deux mois : -30 jours à +30 jours)
    rdv_crees = 0
    # Traduction des jours Python (0=Monday ... 6=Sunday)
    jours_map = {0: "Lundi", 1: "Mardi", 2: "Mercredi", 3: "Jeudi", 4: "Vendredi", 5: "Samedi", 6: "Dimanche"}
    
    # Récupérer les jours travaillés pour chaque médecin
    cur.execute("SELECT id, jours_consultation FROM medecins")
    planning_docs = {row[0]: row[1].split(",") for row in cur.fetchall()}

    while rdv_crees < 150:
        medecin_id = random.randint(1, nb_medecins)
        jours_autorises = planning_docs[medecin_id]
        
        # Tirer un jour entre il y a 30 jours et dans 30 jours
        delta_jours = random.randint(-30, 30)
        jour_cible = date.today() + timedelta(days=delta_jours)
        nom_jour = jours_map[jour_cible.weekday()]

        # Respecter les jours de consultation du médecin
        if nom_jour not in jours_autorises:
            continue

        heure_choisie = random.choice(CRENEAUX)
        patient_id = random.choice(patients_ids)
        motif = random.choice(MOTIFS)

        # Statut cohérent avec la date
        if jour_cible < date.today():
            statut = random.choices(["effectué", "annulé"], weights=[0.85, 0.15])[0]
        else:
            statut = random.choices(["prévu", "annulé"], weights=[0.90, 0.10])[0]

        try:
            cur.execute(
                """INSERT INTO rendez_vous (patient_id, medecin_id, date, heure, motif, statut) 
                   VALUES (?, ?, ?, ?, ?, ?)""",
                (patient_id, medecin_id, jour_cible.isoformat(), heure_choisie, motif, statut)
            )
            rdv_crees += 1
        except sqlite3.IntegrityError:
            # Créneau déjà pris pour ce médecin à cette date et heure (contrainte UNIQUE)
            continue

    conn.commit()

if __name__ == "__main__":
    random.seed(42)  # Reproductibilité garantie
    base_fichier = "projet.db"
    connexion = initialiser_bdd(base_fichier, "schema.sql")
    peupler_base(connexion)
    
    # Vérification des volumes insérés
    print("--- Peuplement terminé avec succès ---")
    cur = connexion.cursor()
    for table in ["administrateurs", "medecins", "patients", "rendez_vous"]:
        cur.execute(f"SELECT COUNT(*) FROM {table}")
        print(f"Table '{table}' : {cur.fetchone()[0]} lignes.")
    connexion.close()
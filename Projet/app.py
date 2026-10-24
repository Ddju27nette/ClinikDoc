import csv
import functools
import io
import os
import re
import secrets
import sqlite3
from datetime import date, datetime, timedelta
from flask import (
    Flask,
    abort,
    flash,
    g,
    jsonify,
    make_response,
    redirect,
    render_template,
    request,
    session,
    url_for,
)
from werkzeug.security import check_password_hash, generate_password_hash

# ---------------------------------------------------------
# Configuration des chemins absolus (résout TemplateNotFound sous Windows)
# ---------------------------------------------------------
BASE_DIR = os.path.abspath(os.path.dirname(__file__))

app = Flask(
    __name__,
    template_folder=os.path.join(BASE_DIR, "templates"),
    static_folder=os.path.join(BASE_DIR, "static")
)

app.config["VERCEL_DEMO"] = os.environ.get("VERCEL") == "1"
app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY") or (
    None if app.config["VERCEL_DEMO"] else secrets.token_hex(32)
)
app.config["DATABASE"] = (
    "/tmp/clinikdoc-demo.sqlite" if app.config["VERCEL_DEMO"]
    else os.path.join(BASE_DIR, "projet.db")
)

# ---------------------------------------------------------
# Gestion de la connexion SQLite par requête
# ---------------------------------------------------------
def get_db():
    """Ouvre une connexion par requête et la réutilise."""
    if "db" not in g:
        if app.config["VERCEL_DEMO"] and not os.path.exists(app.config["DATABASE"]):
            secret_key = app.config["SECRET_KEY"]
            admin_login = os.environ.get("CLINIKDOC_ADMIN_LOGIN", "").strip()
            admin_password = os.environ.get("CLINIKDOC_ADMIN_PASSWORD", "")
            if not secret_key or not admin_login or not admin_password:
                raise RuntimeError(
                    "Configurez SECRET_KEY, CLINIKDOC_ADMIN_LOGIN et "
                    "CLINIKDOC_ADMIN_PASSWORD dans les variables d'environnement Vercel."
                )
            connection = sqlite3.connect(app.config["DATABASE"])
            with open(os.path.join(BASE_DIR, "schema.sql"), encoding="utf-8") as schema_file:
                connection.executescript(schema_file.read())
            connection.execute(
                "INSERT INTO administrateurs (login, empreinte) VALUES (?, ?)",
                (admin_login, generate_password_hash(admin_password))
            )
            connection.commit()
            connection.close()

        g.db = sqlite3.connect(app.config["DATABASE"])
        g.db.row_factory = sqlite3.Row  # Accès aux colonnes par leur nom
        g.db.execute("PRAGMA foreign_keys = ON;")
        colonnes = {row["name"] for row in g.db.execute("PRAGMA table_info(medecins)")}
        if "login" not in colonnes:
            g.db.execute("ALTER TABLE medecins ADD COLUMN login TEXT")
        if "empreinte" not in colonnes:
            g.db.execute("ALTER TABLE medecins ADD COLUMN empreinte TEXT")
        g.db.execute(
            "CREATE UNIQUE INDEX IF NOT EXISTS idx_medecins_login ON medecins(login) WHERE login IS NOT NULL"
        )
    return g.db

@app.teardown_appcontext
def fermer_db(exception=None):
    """Ferme la connexion à la fin de chaque requête."""
    db = g.pop("db", None)
    if db is not None:
        db.close()

# ---------------------------------------------------------
# Décorateur de contrôle d'accès pour l'administration
# ---------------------------------------------------------
def connexion_requise(vue):
    """Interdit l'accès si l'administrateur n'est pas connecté."""
    @functools.wraps(vue)
    def vue_enveloppee(**kwargs):
        if session.get("admin_id") is None:
            flash("Veuillez vous connecter pour accéder à l'administration.", "erreur")
            return redirect(url_for("connexion"))
        return vue(**kwargs)
    return vue_enveloppee

def medecin_connecte_requis(vue):
    """Réserve une page à un médecin connecté."""
    @functools.wraps(vue)
    def vue_enveloppee(**kwargs):
        if session.get("medecin_id") is None:
            flash("Veuillez vous connecter avec un compte médecin.", "erreur")
            return redirect(url_for("connexion"))
        return vue(**kwargs)
    return vue_enveloppee

# ---------------------------------------------------------
# Gestion de l'erreur 404 personnalisée
# ---------------------------------------------------------
@app.errorhandler(404)
def page_non_trouvee(e):
    return render_template("404.html"), 404

# ---------------------------------------------------------
# PARTIE PUBLIQUE
# ---------------------------------------------------------
@app.route("/")
def index():
    """Page d'accueil : présentation de ClinikDoc et statistiques clés."""
    db = get_db()
    nb_medecins = db.execute("SELECT COUNT(*) FROM medecins WHERE actif = 1").fetchone()[0]
    nb_patients = db.execute("SELECT COUNT(*) FROM patients").fetchone()[0]
    nb_rdv = db.execute("SELECT COUNT(*) FROM rendez_vous WHERE statut = 'effectué'").fetchone()[0]
    
    # Récupérer quelques médecins pour l'affichage vitrine
    medecins = db.execute("SELECT * FROM medecins WHERE actif = 1 LIMIT 4").fetchall()
    return render_template("index.html", 
                           nb_medecins=nb_medecins, 
                           nb_patients=nb_patients, 
                           nb_rdv=nb_rdv, 
                           medecins=medecins)

@app.route("/medecins")
def medecins():
    """Liste des médecins filtrable par spécialité."""
    specialite = request.args.get("specialite", "").strip()
    db = get_db()
    
    specialites = [row["specialite"] for row in db.execute(
        "SELECT DISTINCT specialite FROM medecins WHERE actif = 1 ORDER BY specialite"
    ).fetchall()]
    
    if specialite and specialite in specialites:
        liste_medecins = db.execute(
            "SELECT * FROM medecins WHERE actif = 1 AND specialite = ? ORDER BY nom", 
            (specialite,)
        ).fetchall()
    else:
        liste_medecins = db.execute(
            "SELECT * FROM medecins WHERE actif = 1 ORDER BY nom"
        ).fetchall()
        
    return render_template("medecins.html", 
                           medecins=liste_medecins, 
                           specialites=specialites, 
                           specialite_active=specialite)

@app.route("/reserver", methods=["GET", "POST"])
def reserver():
    """Formulaire de prise de rendez-vous avec vérifications strictes."""
    db = get_db()
    
    if request.method == "POST":
        medecin_id = request.form.get("medecin_id", "").strip()
        nom = request.form.get("nom", "").strip()
        prenom = request.form.get("prenom", "").strip()
        telephone = request.form.get("telephone", "").strip().replace(" ", "")
        date_naissance = request.form.get("date_naissance", "").strip()
        ville = request.form.get("ville", "").strip()
        date_rdv = request.form.get("date", "").strip()
        heure = request.form.get("heure", "").strip()
        motif = request.form.get("motif", "").strip()

        # Validation côté serveur
        erreurs = []
        if not (nom and prenom and telephone and date_naissance and ville and date_rdv and heure and motif):
            erreurs.append("Tous les champs sont obligatoires.")
        
        if not re.fullmatch(r"6\d{8}", telephone):
            erreurs.append("Le numéro de téléphone doit comporter exactement 9 chiffres et commencer par 6.")
            
        try:
            date_choisie = date.fromisoformat(date_rdv)
            if date_choisie <= date.today():
                erreurs.append("La date du rendez-vous doit être dans le futur.")
        except ValueError:
            erreurs.append("Format de date invalide.")

        creneaux_valides = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30"]
        if heure not in creneaux_valides:
            erreurs.append("Créneau horaire non conforme.")

        # Vérification des jours de consultation du médecin
        medecin = db.execute("SELECT * FROM medecins WHERE id = ? AND actif = 1", (medecin_id,)).fetchone()
        if not medecin:
            erreurs.append("Médecin sélectionné inexistant.")
        else:
            jours_fr = {0: "Lundi", 1: "Mardi", 2: "Mercredi", 3: "Jeudi", 4: "Vendredi", 5: "Samedi", 6: "Dimanche"}
            nom_jour = jours_fr[date_choisie.weekday()]
            if nom_jour not in medecin["jours_consultation"].split(","):
                erreurs.append(f"Le {medecin['nom']} ne consulte pas le {nom_jour}.")

        if erreurs:
            for err in erreurs:
                flash(err, "erreur")
            medecins_dispo = db.execute("SELECT id, nom, specialite, jours_consultation FROM medecins WHERE actif = 1").fetchall()
            return render_template("reserver.html", medecins=medecins_dispo, donnees=request.form), 400

        # Enregistrement ou mise à jour du patient
        patient = db.execute("SELECT id FROM patients WHERE telephone = ?", (telephone,)).fetchone()
        if patient:
            patient_id = patient["id"]
            db.execute(
                "UPDATE patients SET nom = ?, prenom = ?, date_naissance = ?, ville = ? WHERE id = ?",
                (nom, prenom, date_naissance, ville, patient_id)
            )
        else:
            cur = db.execute(
                "INSERT INTO patients (nom, prenom, telephone, date_naissance, ville) VALUES (?, ?, ?, ?, ?)",
                (nom, prenom, telephone, date_naissance, ville)
            )
            patient_id = cur.lastrowid

        # Enregistrement du rendez-vous protégé contre les collisions (contrainte UNIQUE)
        try:
            db.execute(
                """INSERT INTO rendez_vous (patient_id, medecin_id, date, heure, motif, statut)
                   VALUES (?, ?, ?, ?, ?, 'prévu')""",
                (patient_id, medecin_id, date_rdv, heure, motif)
            )
            db.commit()
            flash(f"Votre rendez-vous avec le {medecin['nom']} le {date_rdv} à {heure} a été confirmé.", "succes")
            return redirect(url_for("mes_rdv", telephone=telephone))
        except sqlite3.IntegrityError:
            db.rollback()
            flash("Ce créneau vient tout juste d'être réservé par un autre patient. Veuillez choisir une autre heure.", "erreur")
            medecins_dispo = db.execute("SELECT id, nom, specialite, jours_consultation FROM medecins WHERE actif = 1").fetchall()
            return render_template("reserver.html", medecins=medecins_dispo, donnees=request.form), 400

    medecins_dispo = db.execute("SELECT id, nom, specialite, jours_consultation FROM medecins WHERE actif = 1").fetchall()
    medecin_preselect = request.args.get("medecin_id", "")
    return render_template("reserver.html", medecins=medecins_dispo, medecin_preselect=medecin_preselect, donnees={})

@app.route("/mes-rendez-vous")
def mes_rdv():
    """Consultation de ses rendez-vous à l'aide de son numéro de téléphone."""
    telephone = request.args.get("telephone", "").strip().replace(" ", "")
    rendez_vous = []
    patient = None
    rappels = []
    
    if telephone:
        db = get_db()
        patient = db.execute("SELECT * FROM patients WHERE telephone = ?", (telephone,)).fetchone()
        if patient:
            session["patient_id"] = patient["id"]
            rendez_vous = db.execute(
                """SELECT r.id, r.date, r.heure, r.motif, r.statut, m.nom AS medecin_nom, m.specialite
                   FROM rendez_vous r
                   JOIN medecins m ON r.medecin_id = m.id
                   WHERE r.patient_id = ?
                   ORDER BY r.date DESC, r.heure DESC""",
                (patient["id"],)
            ).fetchall()
            demain = (date.today() + timedelta(days=1)).isoformat()
            rappels = [rdv for rdv in rendez_vous if rdv["date"] == demain and rdv["statut"] == "prévu"]
        else:
            session.pop("patient_id", None)
            flash("Aucun dossier patient trouvé avec ce numéro de téléphone.", "avertissement")

    return render_template(
        "mes_rdv.html",
        telephone=telephone,
        patient=patient,
        rendez_vous=rendez_vous,
        rappels=rappels
    )

# ---------------------------------------------------------
# APIS JSON (Endpoints consommés par fetch)
# ---------------------------------------------------------
@app.route("/api/creneaux")
def api_creneaux():
    """Renvoie les créneaux libres pour un médecin et une date donnée."""
    medecin_id = request.args.get("medecin_id", type=int)
    date_str = request.args.get("date", "").strip()

    if not medecin_id or not date_str:
        return jsonify({"erreur": "Paramètres manquants"}), 400

    db = get_db()
    medecin = db.execute("SELECT * FROM medecins WHERE id = ? AND actif = 1", (medecin_id,)).fetchone()
    if not medecin:
        return jsonify({"erreur": "Médecin introuvable"}), 404

    # Vérifier le jour de consultation
    try:
        date_obj = date.fromisoformat(date_str)
    except ValueError:
        return jsonify({"erreur": "Date invalide"}), 400

    jours_fr = {0: "Lundi", 1: "Mardi", 2: "Mercredi", 3: "Jeudi", 4: "Vendredi", 5: "Samedi", 6: "Dimanche"}
    nom_jour = jours_fr[date_obj.weekday()]
    if nom_jour not in medecin["jours_consultation"].split(","):
        return jsonify({"creneaux": [], "message": f"Le médecin ne consulte pas le {nom_jour}."})

    tous_les_creneaux = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30"]

    # Créneaux déjà pris (non annulés)
    occupes = db.execute(
        """SELECT heure FROM rendez_vous 
           WHERE medecin_id = ? AND date = ? AND statut != 'annulé'""",
        (medecin_id, date_str)
    ).fetchall()
    heures_occupees = {row["heure"] for row in occupes}

    libres = [h for h in tous_les_creneaux if h not in heures_occupees]
    return jsonify({"creneaux": libres, "total_libres": len(libres)})

@app.route("/api/statistiques")
@connexion_requise
def api_statistiques():
    """API JSON des statistiques demandées par le cahier des charges."""
    db = get_db()
    
    # 1. Nombre de rendez-vous par spécialité
    par_specialite = [dict(row) for row in db.execute(
        """SELECT m.specialite, COUNT(r.id) AS total
           FROM rendez_vous r
           JOIN medecins m ON r.medecin_id = m.id
           GROUP BY m.specialite"""
    ).fetchall()]

    # 2. Taux d'annulation par médecin
    taux_annulation = [dict(row) for row in db.execute(
        """SELECT m.nom, 
                  COUNT(r.id) AS total_rdv,
                  SUM(CASE WHEN r.statut = 'annulé' THEN 1 ELSE 0 END) AS annules,
                  ROUND(SUM(CASE WHEN r.statut = 'annulé' THEN 1.0 ELSE 0.0 END) * 100 / COUNT(r.id), 1) AS taux
           FROM medecins m
           LEFT JOIN rendez_vous r ON m.id = r.medecin_id
           GROUP BY m.id"""
    ).fetchall()]

    # 3. Les 5 jours les plus chargés du mois courant
    jours_charges = [dict(row) for row in db.execute(
        """SELECT date, COUNT(id) AS total_rdv
           FROM rendez_vous
           WHERE strftime('%Y-%m', date) = strftime('%Y-%m', 'now')
           GROUP BY date
           ORDER BY total_rdv DESC
           LIMIT 5"""
    ).fetchall()]

    # 4. Nouveaux patients par semaine
    patients_semaine = [dict(row) for row in db.execute(
        """SELECT strftime('%Y-%W', cree_le) AS semaine, COUNT(id) AS nouveaux
           FROM patients
           GROUP BY semaine
           ORDER BY semaine DESC
           LIMIT 8"""
    ).fetchall()]

    return jsonify({
        "par_specialite": par_specialite,
        "taux_annulation": taux_annulation,
        "jours_charges": jours_charges,
        "patients_semaine": patients_semaine
    })

# ---------------------------------------------------------
# ESPACE ADMINISTRATION
# ---------------------------------------------------------
@app.route("/connexion", methods=["GET", "POST"])
def connexion():
    """Authentification des administrateurs et médecins."""
    if request.method == "POST":
        login = request.form.get("login", "").strip()
        mot_de_passe = request.form.get("mdp", "").strip()
        role = request.form.get("role", "admin").strip()

        db = get_db()
        if role == "admin":
            utilisateur = db.execute("SELECT * FROM administrateurs WHERE login = ?", (login,)).fetchone()
            if utilisateur and check_password_hash(utilisateur["empreinte"], mot_de_passe):
                session.clear()
                session["admin_id"] = utilisateur["id"]
                session["admin_login"] = utilisateur["login"]
                flash(f"Bienvenue, {utilisateur['login']}.", "succes")
                return redirect(url_for("admin_planning"))
        elif role == "medecin":
            utilisateur = db.execute(
                "SELECT id, nom, login, empreinte FROM medecins WHERE login = ? AND actif = 1",
                (login,)
            ).fetchone()
            if utilisateur and utilisateur["empreinte"] and check_password_hash(utilisateur["empreinte"], mot_de_passe):
                session.clear()
                session["medecin_id"] = utilisateur["id"]
                session["medecin_nom"] = utilisateur["nom"]
                session["medecin_login"] = utilisateur["login"]
                flash(f"Bienvenue, {utilisateur['nom']}.", "succes")
                return redirect(url_for("espace_medecin"))

        flash("Identifiants incorrects.", "erreur")
        return redirect(url_for("connexion"))

    return render_template("admin/connexion.html")

@app.route("/deconnexion", methods=["POST"])
def deconnexion():
    """Déconnexion de l'administrateur."""
    session.clear()
    flash("Vous êtes déconnecté.", "info")
    return redirect(url_for("connexion"))

@app.route("/admin/planning")
@connexion_requise
def admin_planning():
    """Planning du jour filtrable par médecin."""
    jour = request.args.get("date", date.today().isoformat())
    medecin_id = request.args.get("medecin_id", type=int)
    specialite = request.args.get("specialite", "").strip()

    db = get_db()
    medecins = db.execute("SELECT id, nom, specialite, jours_consultation, actif, login FROM medecins ORDER BY nom").fetchall()
    specialites = db.execute(
        "SELECT DISTINCT specialite FROM medecins WHERE actif = 1 ORDER BY specialite"
    ).fetchall()

    requete = """
        SELECT r.id, r.date, r.heure, r.motif, r.statut,
               p.nom AS patient_nom, p.prenom AS patient_prenom, p.telephone,
               m.nom AS medecin_nom, m.specialite
        FROM rendez_vous r
        JOIN patients p ON r.patient_id = p.id
        JOIN medecins m ON r.medecin_id = m.id
        WHERE r.date = ?
    """
    params = [jour]

    if medecin_id:
        requete += " AND r.medecin_id = ?"
        params.append(medecin_id)
    if specialite:
        requete += " AND m.specialite = ?"
        params.append(specialite)

    requete += " ORDER BY r.heure ASC"
    rdvs = db.execute(requete, params).fetchall()

    return render_template("admin/planning.html", 
                           rdvs=rdvs, 
                           medecins=medecins, 
                           specialites=specialites,
                           date_selectionnee=jour, 
                           medecin_selectionne=medecin_id,
                           specialite_selectionnee=specialite)

@app.route("/medecin/espace")
@medecin_connecte_requis
def espace_medecin():
    """Affiche au médecin connecté son planning passé et à venir."""
    db = get_db()
    medecin_id = session["medecin_id"]
    rendez_vous = db.execute(
        """SELECT r.id, r.date, r.heure, r.motif, r.statut,
                  p.nom AS patient_nom, p.prenom AS patient_prenom, p.telephone
           FROM rendez_vous r
           JOIN patients p ON p.id = r.patient_id
           WHERE r.medecin_id = ?
           ORDER BY r.date DESC, r.heure DESC""",
        (medecin_id,)
    ).fetchall()
    prochain_rdv = db.execute(
        """SELECT r.date, r.heure, r.motif, p.nom AS patient_nom, p.prenom AS patient_prenom
           FROM rendez_vous r
           JOIN patients p ON p.id = r.patient_id
           WHERE r.medecin_id = ? AND r.statut = 'prévu' AND r.date >= ?
           ORDER BY r.date, r.heure
           LIMIT 1""",
        (medecin_id, date.today().isoformat())
    ).fetchone()
    return render_template(
        "medecin/espace.html",
        rendez_vous=rendez_vous,
        prochain_rdv=prochain_rdv
    )

@app.route("/admin/planning/export.csv")
@connexion_requise
def admin_export_planning():
    """Exporte le planning d'un médecin en CSV."""
    medecin_id = request.args.get("medecin_id", type=int)
    if not medecin_id:
        flash("Sélectionnez un médecin pour exporter son planning.", "erreur")
        return redirect(url_for("admin_planning"))

    db = get_db()
    medecin = db.execute("SELECT nom FROM medecins WHERE id = ?", (medecin_id,)).fetchone()
    if not medecin:
        abort(404)
    rendez_vous = db.execute(
        """SELECT r.date, r.heure, p.nom, p.prenom, p.telephone, m.specialite, r.motif, r.statut
           FROM rendez_vous r
           JOIN patients p ON p.id = r.patient_id
           JOIN medecins m ON m.id = r.medecin_id
           WHERE r.medecin_id = ?
           ORDER BY r.date, r.heure""",
        (medecin_id,)
    ).fetchall()

    sortie = io.StringIO()
    sortie.write("\ufeff")
    writer = csv.writer(sortie, delimiter=";")
    writer.writerow(["Date", "Heure", "Nom", "Prénom", "Téléphone", "Spécialité", "Motif", "Statut"])
    writer.writerows(tuple(rdv) for rdv in rendez_vous)
    reponse = make_response(sortie.getvalue())
    reponse.headers["Content-Type"] = "text/csv; charset=utf-8"
    reponse.headers["Content-Disposition"] = f'attachment; filename="planning-medecin-{medecin_id}.csv"'
    return reponse

@app.route("/admin/rdv/<int:id_rdv>/statut", methods=["POST"])
@connexion_requise
def admin_changer_statut(id_rdv):
    """Met à jour le statut d'un rendez-vous (effectué ou annulé)."""
    nouveau_statut = request.form.get("statut", "").strip()
    if nouveau_statut in ("effectué", "annulé", "prévu"):
        db = get_db()
        db.execute("UPDATE rendez_vous SET statut = ? WHERE id = ?", (nouveau_statut, id_rdv))
        db.commit()
        flash("Statut du rendez-vous mis à jour.", "succes")
    return redirect(request.referrer or url_for("admin_planning"))

@app.route("/admin/patients")
@connexion_requise
def admin_patients():
    """Liste des patients avec moteur de recherche par nom."""
    recherche = request.args.get("q", "").strip()
    db = get_db()
    if recherche:
        patients = db.execute(
            "SELECT * FROM patients WHERE nom LIKE ? OR prenom LIKE ? ORDER BY nom",
            (f"%{recherche}%", f"%{recherche}%")
        ).fetchall()
    else:
        patients = db.execute("SELECT * FROM patients ORDER BY nom LIMIT 100").fetchall()
    return render_template("admin/patients.html", patients=patients, recherche=recherche)

@app.route("/admin/medecins/ajouter", methods=["GET", "POST"])
@connexion_requise
def admin_ajouter_medecin():
    """Ajout d'un nouveau praticien."""
    if request.method == "POST":
        nom = request.form.get("nom", "").strip()
        specialite = request.form.get("specialite", "").strip()
        jours = request.form.getlist("jours")
        login = request.form.get("login", "").strip()
        mot_de_passe = request.form.get("mdp", "")

        if not nom or not specialite or not jours or not login or not mot_de_passe:
            flash("Veuillez renseigner toutes les informations, y compris les identifiants du médecin.", "erreur")
            return redirect(url_for("admin_ajouter_medecin"))

        jours_str = ",".join(jours)
        db = get_db()
        try:
            db.execute(
                """INSERT INTO medecins
                   (nom, specialite, jours_consultation, photo, actif, login, empreinte)
                   VALUES (?, ?, ?, 'default_doc.png', 1, ?, ?)""",
                (nom, specialite, jours_str, login, generate_password_hash(mot_de_passe))
            )
        except sqlite3.IntegrityError:
            db.rollback()
            flash("Cet identifiant médecin est déjà utilisé.", "erreur")
            return redirect(url_for("admin_ajouter_medecin"))
        db.commit()
        flash(f"Le médecin {nom} a été ajouté avec succès.", "succes")
        return redirect(url_for("admin_planning"))

    return render_template("admin/medecin_form.html", action="Ajouter", medecin=None)

@app.route("/admin/medecins/<int:id_medecin>/modifier", methods=["GET", "POST"])
@connexion_requise
def admin_modifier_medecin(id_medecin):
    """Modification d'un praticien existant."""
    db = get_db()
    medecin = db.execute("SELECT * FROM medecins WHERE id = ?", (id_medecin,)).fetchone()
    if not medecin:
        abort(404)

    if request.method == "POST":
        nom = request.form.get("nom", "").strip()
        specialite = request.form.get("specialite", "").strip()
        jours = request.form.getlist("jours")
        actif = 1 if request.form.get("actif") else 0
        login = request.form.get("login", "").strip()
        mot_de_passe = request.form.get("mdp", "")

        if not nom or not specialite or not jours or not login:
            flash("Veuillez renseigner tous les champs.", "erreur")
            return redirect(url_for("admin_modifier_medecin", id_medecin=id_medecin))

        jours_str = ",".join(jours)
        try:
            if mot_de_passe:
                db.execute(
                    """UPDATE medecins
                       SET nom = ?, specialite = ?, jours_consultation = ?, actif = ?,
                           login = ?, empreinte = ?
                       WHERE id = ?""",
                    (nom, specialite, jours_str, actif, login, generate_password_hash(mot_de_passe), id_medecin)
                )
            else:
                db.execute(
                    """UPDATE medecins
                       SET nom = ?, specialite = ?, jours_consultation = ?, actif = ?, login = ?
                       WHERE id = ?""",
                    (nom, specialite, jours_str, actif, login, id_medecin)
                )
        except sqlite3.IntegrityError:
            db.rollback()
            flash("Cet identifiant médecin est déjà utilisé.", "erreur")
            return redirect(url_for("admin_modifier_medecin", id_medecin=id_medecin))
        db.commit()
        flash("Informations du médecin mises à jour.", "succes")
        return redirect(url_for("admin_planning"))

    return render_template("admin/medecin_form.html", action="Modifier", medecin=medecin)

@app.route("/admin/statistiques")
@connexion_requise
def admin_statistiques():
    """Page d'affichage des statistiques de la clinique."""
    return render_template("admin/statistiques.html")

# ---------------------------------------------------------
# Lancement de l'application
# ---------------------------------------------------------
if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(os.environ.get("PORT", "5000")),
        debug=False
    )
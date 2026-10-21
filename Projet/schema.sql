-- Suppression des tables existantes pour repartir sur une base propre
DROP TABLE IF EXISTS rendez_vous;
DROP TABLE IF EXISTS medecins;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS administrateurs;

-- Activation des clés étrangères sous SQLite
PRAGMA foreign_keys = ON;

-- 1. Table des administrateurs / secrétaires
CREATE TABLE administrateurs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    login TEXT NOT NULL UNIQUE,
    empreinte TEXT NOT NULL,
    cree_le TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Table des médecins de la clinique
CREATE TABLE medecins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    specialite TEXT NOT NULL CHECK (specialite IN ('Généraliste', 'Pédiatrie', 'Gynécologie', 'Cardiologie')),
    photo TEXT NOT NULL DEFAULT 'default_doc.png',
    jours_consultation TEXT NOT NULL, -- Ex: 'Lundi,Mardi,Jeudi'
    actif INTEGER NOT NULL DEFAULT 1 CHECK (actif IN (0, 1))
);

-- 3. Table des patients
CREATE TABLE patients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    prenom TEXT NOT NULL,
    telephone TEXT NOT NULL UNIQUE CHECK (length(telephone) = 9 AND telephone LIKE '6%'),
    date_naissance TEXT NOT NULL,
    ville TEXT NOT NULL,
    cree_le TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. Table des rendez-vous
CREATE TABLE rendez_vous (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    patient_id INTEGER NOT NULL,
    medecin_id INTEGER NOT NULL,
    date TEXT NOT NULL,       -- Format ISO: 'YYYY-MM-DD'
    heure TEXT NOT NULL CHECK (heure IN ('08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30')),
    motif TEXT NOT NULL,
    statut TEXT NOT NULL DEFAULT 'prévu' CHECK (statut IN ('prévu', 'effectué', 'annulé')),
    date_prise TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (medecin_id) REFERENCES medecins(id) ON DELETE RESTRICT,
    -- Contrainte d'intégrité vitale : un médecin ne peut avoir qu'un seul rendez-vous par créneau
    CONSTRAINT unique_creneau_medecin UNIQUE (medecin_id, date, heure)
);

-- Index pour accélérer les recherches fréquentes
CREATE INDEX idx_rdv_patient ON rendez_vous(patient_id);
CREATE INDEX idx_rdv_medecin_date ON rendez_vous(medecin_id, date);
CREATE INDEX idx_patients_tel ON patients(telephone);
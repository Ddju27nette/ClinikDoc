BEGIN TRANSACTION;
CREATE TABLE administrateurs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    login TEXT NOT NULL UNIQUE,
    empreinte TEXT NOT NULL,
    cree_le TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "administrateurs" VALUES(1,'admin','scrypt:32768:8:1$rKoCkpHYluZwMtMK$f84753ab162a80aa76e118ad09352ca2d45f20adfe55a1231d8b939184254f13baa875eb79638274c238500f90194c54df6b1c9f66521b85b1a8297b5a0317d5','2026-10-21 23:51:45');
CREATE TABLE medecins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    specialite TEXT NOT NULL CHECK (specialite IN ('Généraliste', 'Pédiatrie', 'Gynécologie', 'Cardiologie')),
    photo TEXT NOT NULL DEFAULT 'default_doc.png',
    jours_consultation TEXT NOT NULL, -- Ex: 'Lundi,Mardi,Jeudi'
    actif INTEGER NOT NULL DEFAULT 1 CHECK (actif IN (0, 1))
);
INSERT INTO "medecins" VALUES(1,'Dr Mbarga Jean','Généraliste','default_doc.png','Lundi,Mardi,Mercredi,Jeudi,Vendredi',1);
INSERT INTO "medecins" VALUES(2,'Dr Ngo Bassa Sophie','Généraliste','default_doc.png','Mardi,Mercredi,Jeudi,Vendredi,Samedi',1);
INSERT INTO "medecins" VALUES(3,'Dr Kamga Paul','Pédiatrie','default_doc.png','Lundi,Mercredi,Vendredi',1);
INSERT INTO "medecins" VALUES(4,'Dr Abena Chantal','Pédiatrie','default_doc.png','Mardi,Jeudi,Samedi',1);
INSERT INTO "medecins" VALUES(5,'Dr Mouelle Arthur','Cardiologie','default_doc.png','Lundi,Mardi,Jeudi',1);
INSERT INTO "medecins" VALUES(6,'Dr Danielle Song','Cardiologie','default_doc.png','Mercredi,Vendredi,Samedi',1);
INSERT INTO "medecins" VALUES(7,'Dr Fotso Patrick','Gynécologie','default_doc.png','Lundi,Mardi,Mercredi,Vendredi',1);
INSERT INTO "medecins" VALUES(8,'Dr Carine Bello','Gynécologie','default_doc.png','Mardi,Mercredi,Jeudi,Samedi',1);
CREATE TABLE patients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    prenom TEXT NOT NULL,
    telephone TEXT NOT NULL UNIQUE CHECK (length(telephone) = 9 AND telephone LIKE '6%'),
    date_naissance TEXT NOT NULL,
    ville TEXT NOT NULL,
    cree_le TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "patients" VALUES(1,'Kamga','Paul','699423746','1967-09-04','Garoua','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(2,'Fotso','Helene','652132899','1988-11-20','Bafoussam','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(3,'Tchoupo','Kevin','660714555','2020-11-08','Bafoussam','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(4,'Fotso','Moussa','672833825','2013-07-09','Garoua','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(5,'Mballa','Sandra','678314694','1978-06-07','Buea','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(6,'Kamga','Kevin','699764611','2004-09-24','Yaoundé','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(7,'Ekane','Eric','693613006','1977-05-21','Buea','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(8,'Tientcheu','Moussa','690400793','1984-01-08','Douala','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(9,'Abena','Arthur','651780798','1991-02-07','Kribi','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(10,'Abena','Rose','657471301','1962-07-21','Garoua','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(11,'Njoya','Samuel','687664518','2008-04-24','Kribi','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(12,'Tientcheu','Samuel','666434414','1971-10-13','Bafoussam','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(13,'Bello','Ibrahim','698051262','1960-08-03','Douala','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(14,'Atangana','Ibrahim','663343768','2005-11-14','Kribi','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(15,'Fotso','Arthur','692911206','1977-10-15','Kribi','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(16,'Kamga','Helene','672588477','2024-11-24','Douala','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(17,'Tientcheu','Samuel','664449461','1982-02-10','Garoua','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(18,'Ekane','Eric','686598928','2025-12-24','Bafoussam','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(19,'Bassong','Sandra','664793519','1961-02-28','Buea','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(20,'Ewodo','Guy','678153498','2000-03-12','Yaoundé','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(21,'Tientcheu','Guy','664672546','2025-10-11','Garoua','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(22,'Mbarga','Marie','656287781','1979-05-08','Douala','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(23,'Bello','Kevin','689544950','2015-12-16','Douala','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(24,'Tientcheu','Ibrahim','659364231','2009-11-16','Kribi','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(25,'Ekane','Samuel','650436124','1958-10-14','Yaoundé','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(26,'Tientcheu','Rose','678361172','1986-07-22','Buea','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(27,'Mballa','Eric','674090698','1959-08-04','Yaoundé','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(28,'Bello','Kevin','656859215','1982-01-19','Kribi','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(29,'Bello','Moussa','656490526','2025-02-23','Buea','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(30,'Ngo Bassa','Moussa','695412533','2017-01-28','Bafoussam','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(31,'Fotso','Guy','665613608','1995-05-22','Garoua','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(32,'Tchoupo','Helene','697065122','2009-12-19','Kribi','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(33,'Biya','Moussa','683913819','1965-07-07','Douala','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(34,'Atangana','Danielle','668669062','1980-07-14','Garoua','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(35,'Ngo Bassa','Marie','689627281','2018-07-24','Bafoussam','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(36,'Atangana','Moussa','655834366','2001-04-18','Garoua','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(37,'Njoya','Danielle','699705370','2002-05-15','Yaoundé','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(38,'Fotso','Eric','656878334','2013-01-21','Kribi','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(39,'Mbarga','Kevin','660434052','1995-03-14','Garoua','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(40,'Biya','Rose','686570403','1974-01-06','Garoua','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(41,'Mbarga','Arthur','673082477','1992-08-10','Garoua','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(42,'Tientcheu','Florence','651678443','2006-04-10','Yaoundé','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(43,'Ngo Bassa','Helene','675496489','2018-12-11','Douala','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(44,'Ngo Bassa','Florence','651999657','1961-09-06','Douala','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(45,'Bassong','Kevin','656224068','2002-02-20','Douala','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(46,'Bello','Arthur','664979419','2010-10-08','Kribi','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(47,'Ngo Bassa','Kevin','696851341','1972-11-19','Kribi','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(48,'Bassong','Christian','680145908','1992-04-22','Buea','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(49,'Abena','Moussa','668456905','1992-07-05','Buea','2026-10-21 23:51:45');
INSERT INTO "patients" VALUES(50,'Ewodo','Eric','668647630','1985-02-01','Garoua','2026-10-21 23:51:45');
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
INSERT INTO "rendez_vous" VALUES(1,33,2,'2026-09-26','09:30','Bilan de santé annuel','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(2,24,2,'2026-11-17','09:30','Bilan de santé annuel','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(3,43,1,'2026-11-03','10:00','Fièvre persistante et maux de tête','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(4,48,2,'2026-11-17','08:30','Suivi tension artérielle','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(5,6,8,'2026-10-08','08:00','Renouvellement d''ordonnance','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(6,50,1,'2026-09-22','10:30','Suivi tension artérielle','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(7,36,8,'2026-10-27','11:00','Consultation de routine','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(8,24,3,'2026-10-26','08:00','Suivi tension artérielle','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(9,23,6,'2026-11-18','08:00','Douleurs abdominales','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(10,40,2,'2026-10-14','11:00','Suivi tension artérielle','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(11,48,7,'2026-09-23','09:00','Vaccination et contrôle pédiatrique','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(12,25,3,'2026-11-11','08:30','Consultation de routine','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(13,15,8,'2026-10-14','10:00','Douleurs abdominales','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(14,18,4,'2026-10-17','10:30','Fièvre persistante et maux de tête','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(15,2,7,'2026-11-04','10:30','Fièvre persistante et maux de tête','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(16,39,5,'2026-09-24','08:30','Renouvellement d''ordonnance','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(17,17,2,'2026-10-16','09:30','Consultation de routine','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(18,5,4,'2026-10-15','11:00','Vaccination et contrôle pédiatrique','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(19,33,2,'2026-11-07','10:00','Bilan de santé annuel','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(20,36,6,'2026-10-17','10:00','Suivi tension artérielle','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(21,40,7,'2026-11-04','09:00','Bilan de santé annuel','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(22,38,5,'2026-10-05','11:00','Vaccination et contrôle pédiatrique','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(23,33,8,'2026-11-04','09:30','Certificat médical d''aptitude','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(24,6,2,'2026-10-10','10:30','Douleurs abdominales','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(25,10,4,'2026-11-12','09:30','Consultation de routine','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(26,30,8,'2026-10-31','08:30','Renouvellement d''ordonnance','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(27,16,7,'2026-10-23','11:00','Suivi tension artérielle','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(28,50,1,'2026-11-18','08:30','Renouvellement d''ordonnance','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(29,30,4,'2026-11-19','08:30','Suivi tension artérielle','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(30,40,6,'2026-11-21','11:30','Renouvellement d''ordonnance','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(31,48,8,'2026-11-18','09:00','Certificat médical d''aptitude','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(32,50,4,'2026-11-14','10:00','Certificat médical d''aptitude','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(33,46,5,'2026-10-20','08:30','Bilan de santé annuel','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(34,15,2,'2026-09-30','09:00','Renouvellement d''ordonnance','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(35,27,4,'2026-09-26','11:00','Vaccination et contrôle pédiatrique','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(36,27,7,'2026-09-25','09:30','Renouvellement d''ordonnance','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(37,32,7,'2026-10-26','09:30','Douleurs abdominales','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(38,22,8,'2026-09-23','11:00','Renouvellement d''ordonnance','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(39,40,8,'2026-11-19','09:00','Consultation de routine','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(40,12,7,'2026-09-30','11:30','Consultation de routine','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(41,17,7,'2026-10-09','11:00','Fièvre persistante et maux de tête','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(42,49,2,'2026-11-10','08:00','Consultation de routine','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(43,40,4,'2026-11-14','08:00','Suivi tension artérielle','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(44,37,8,'2026-11-03','08:30','Douleurs abdominales','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(45,11,5,'2026-11-10','10:30','Fièvre persistante et maux de tête','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(46,20,2,'2026-10-29','08:00','Renouvellement d''ordonnance','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(47,7,4,'2026-09-26','09:30','Bilan de santé annuel','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(48,23,2,'2026-11-11','08:00','Renouvellement d''ordonnance','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(49,1,2,'2026-10-24','10:30','Renouvellement d''ordonnance','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(50,47,3,'2026-10-19','09:00','Bilan de santé annuel','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(51,47,8,'2026-10-21','11:00','Bilan de santé annuel','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(52,18,4,'2026-11-14','08:30','Certificat médical d''aptitude','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(53,22,8,'2026-10-28','11:00','Consultation de routine','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(54,14,6,'2026-10-03','11:30','Vaccination et contrôle pédiatrique','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(55,36,6,'2026-10-09','10:00','Consultation de routine','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(56,32,4,'2026-11-07','11:00','Douleurs abdominales','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(57,6,8,'2026-10-20','08:00','Bilan de santé annuel','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(58,18,6,'2026-10-14','11:30','Bilan de santé annuel','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(59,21,2,'2026-11-07','09:30','Fièvre persistante et maux de tête','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(60,19,5,'2026-09-28','09:30','Douleurs abdominales','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(61,18,5,'2026-09-22','09:00','Consultation de routine','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(62,41,5,'2026-11-05','09:00','Certificat médical d''aptitude','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(63,31,1,'2026-10-28','10:00','Certificat médical d''aptitude','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(64,31,3,'2026-09-25','10:00','Fièvre persistante et maux de tête','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(65,37,7,'2026-10-23','08:30','Consultation de routine','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(66,39,4,'2026-09-29','11:00','Douleurs abdominales','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(67,20,7,'2026-10-20','11:30','Renouvellement d''ordonnance','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(68,41,2,'2026-11-21','09:30','Douleurs abdominales','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(69,12,2,'2026-10-02','09:30','Fièvre persistante et maux de tête','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(70,5,5,'2026-11-05','11:30','Douleurs abdominales','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(71,39,1,'2026-10-02','10:00','Bilan de santé annuel','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(72,45,8,'2026-11-05','10:00','Renouvellement d''ordonnance','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(73,39,8,'2026-10-20','08:30','Consultation de routine','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(74,2,6,'2026-10-30','10:00','Fièvre persistante et maux de tête','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(75,37,1,'2026-11-09','10:00','Consultation de routine','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(76,12,8,'2026-11-19','10:00','Renouvellement d''ordonnance','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(77,22,8,'2026-10-14','11:00','Vaccination et contrôle pédiatrique','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(78,49,8,'2026-10-10','11:00','Consultation de routine','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(79,43,7,'2026-11-16','08:00','Certificat médical d''aptitude','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(80,41,6,'2026-10-31','11:30','Certificat médical d''aptitude','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(81,29,3,'2026-11-20','10:00','Certificat médical d''aptitude','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(82,6,1,'2026-10-27','11:00','Douleurs abdominales','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(83,42,2,'2026-10-21','08:30','Suivi tension artérielle','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(84,30,8,'2026-10-22','09:30','Suivi tension artérielle','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(85,18,3,'2026-11-16','08:30','Renouvellement d''ordonnance','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(86,36,8,'2026-10-14','10:30','Renouvellement d''ordonnance','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(87,37,4,'2026-11-05','09:30','Renouvellement d''ordonnance','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(88,32,7,'2026-10-16','09:00','Consultation de routine','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(89,27,8,'2026-09-22','09:00','Suivi tension artérielle','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(90,42,5,'2026-10-13','11:00','Fièvre persistante et maux de tête','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(91,35,7,'2026-10-12','11:30','Consultation de routine','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(92,28,5,'2026-10-06','08:30','Fièvre persistante et maux de tête','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(93,45,2,'2026-10-20','09:00','Bilan de santé annuel','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(94,19,1,'2026-10-12','08:00','Vaccination et contrôle pédiatrique','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(95,37,3,'2026-10-07','11:00','Suivi tension artérielle','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(96,40,2,'2026-10-31','11:00','Douleurs abdominales','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(97,30,5,'2026-11-03','08:00','Bilan de santé annuel','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(98,38,8,'2026-11-21','10:30','Bilan de santé annuel','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(99,45,6,'2026-10-28','10:00','Bilan de santé annuel','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(100,37,7,'2026-10-09','08:00','Consultation de routine','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(101,50,8,'2026-11-14','10:00','Douleurs abdominales','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(102,44,4,'2026-10-31','10:00','Suivi tension artérielle','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(103,47,8,'2026-09-24','10:30','Suivi tension artérielle','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(104,12,5,'2026-10-12','11:00','Douleurs abdominales','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(105,48,8,'2026-11-12','10:00','Vaccination et contrôle pédiatrique','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(106,49,8,'2026-09-26','09:00','Douleurs abdominales','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(107,35,7,'2026-09-22','10:00','Fièvre persistante et maux de tête','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(108,41,5,'2026-10-29','11:00','Vaccination et contrôle pédiatrique','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(109,40,4,'2026-10-22','08:00','Vaccination et contrôle pédiatrique','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(110,16,8,'2026-09-29','08:30','Suivi tension artérielle','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(111,32,7,'2026-11-02','08:30','Renouvellement d''ordonnance','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(112,14,5,'2026-09-24','10:30','Certificat médical d''aptitude','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(113,18,6,'2026-09-25','11:00','Douleurs abdominales','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(114,16,1,'2026-09-25','10:30','Suivi tension artérielle','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(115,39,4,'2026-10-13','09:00','Consultation de routine','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(116,12,3,'2026-09-30','10:00','Fièvre persistante et maux de tête','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(117,23,1,'2026-09-30','08:00','Douleurs abdominales','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(118,50,2,'2026-10-22','11:30','Vaccination et contrôle pédiatrique','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(119,40,2,'2026-10-20','09:30','Consultation de routine','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(120,26,1,'2026-09-25','11:30','Renouvellement d''ordonnance','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(121,21,8,'2026-09-26','08:30','Suivi tension artérielle','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(122,30,6,'2026-10-16','10:00','Renouvellement d''ordonnance','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(123,27,8,'2026-11-17','09:30','Vaccination et contrôle pédiatrique','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(124,24,7,'2026-10-12','10:00','Suivi tension artérielle','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(125,43,1,'2026-10-29','10:30','Fièvre persistante et maux de tête','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(126,15,4,'2026-10-01','11:30','Fièvre persistante et maux de tête','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(127,36,4,'2026-11-12','11:00','Consultation de routine','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(128,22,3,'2026-10-09','10:00','Vaccination et contrôle pédiatrique','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(129,5,3,'2026-10-28','11:00','Suivi tension artérielle','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(130,11,7,'2026-10-21','10:30','Vaccination et contrôle pédiatrique','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(131,10,2,'2026-11-17','08:00','Suivi tension artérielle','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(132,18,1,'2026-11-04','08:30','Certificat médical d''aptitude','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(133,23,5,'2026-10-05','08:30','Renouvellement d''ordonnance','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(134,26,5,'2026-09-24','09:30','Consultation de routine','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(135,49,4,'2026-11-10','09:00','Bilan de santé annuel','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(136,48,2,'2026-09-22','11:30','Renouvellement d''ordonnance','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(137,30,1,'2026-10-19','08:00','Fièvre persistante et maux de tête','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(138,46,7,'2026-10-28','11:00','Renouvellement d''ordonnance','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(139,11,7,'2026-09-23','10:30','Certificat médical d''aptitude','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(140,38,2,'2026-10-07','11:00','Renouvellement d''ordonnance','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(141,48,7,'2026-11-16','10:00','Vaccination et contrôle pédiatrique','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(142,16,6,'2026-10-14','09:00','Fièvre persistante et maux de tête','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(143,49,4,'2026-10-03','09:00','Fièvre persistante et maux de tête','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(144,44,8,'2026-10-21','11:30','Vaccination et contrôle pédiatrique','annulé','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(145,29,8,'2026-09-26','11:30','Bilan de santé annuel','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(146,20,1,'2026-10-14','08:30','Certificat médical d''aptitude','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(147,5,1,'2026-10-15','10:00','Fièvre persistante et maux de tête','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(148,29,7,'2026-10-21','08:00','Douleurs abdominales','effectué','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(149,4,8,'2026-10-24','09:00','Certificat médical d''aptitude','prévu','2026-10-21 23:51:45');
INSERT INTO "rendez_vous" VALUES(150,33,6,'2026-11-06','08:30','Suivi tension artérielle','prévu','2026-10-21 23:51:45');
CREATE INDEX idx_rdv_patient ON rendez_vous(patient_id);
CREATE INDEX idx_rdv_medecin_date ON rendez_vous(medecin_id, date);
CREATE INDEX idx_patients_tel ON patients(telephone);
DELETE FROM "sqlite_sequence";
INSERT INTO "sqlite_sequence" VALUES('administrateurs',1);
INSERT INTO "sqlite_sequence" VALUES('medecins',8);
INSERT INTO "sqlite_sequence" VALUES('patients',50);
INSERT INTO "sqlite_sequence" VALUES('rendez_vous',150);
COMMIT;

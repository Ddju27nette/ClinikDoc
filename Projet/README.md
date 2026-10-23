# ClinikDoc

Application Flask de gestion des consultations et rendez-vous médicaux.

## Lancer en local

Dans le dossier qui contient `app.py`, exécutez :

```powershell
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

Ouvrez ensuite `http://127.0.0.1:5000`.

## Déployer une démonstration sur Vercel

Le mode Vercel de cette application est destiné à une démonstration. Il crée
une base SQLite vierge dans `/tmp` et l'initialise avec le compte administrateur
défini par les variables d'environnement. Vercel peut supprimer ou remplacer
ce stockage temporaire : les médecins ajoutés, patients et rendez-vous ne sont
donc pas garantis d'être conservés. Ne mettez pas de véritables données de
patients sur cette démonstration. Pour une utilisation réelle, migrez vers une
base de données persistante et sécurisée.

1. Poussez le projet vers un dépôt GitHub, puis importez ce dépôt depuis Vercel.
2. Dans les paramètres du projet Vercel, choisissez comme **Root Directory**
   le dossier contenant `app.py`, `requirements.txt` et `schema.sql`
   (dans ce dépôt, `Projet-web-Medecine/Projet`).
3. Ajoutez ces variables dans **Settings > Environment Variables** pour
   l'environnement **Production** et, si souhaité, **Preview** :

   | Nom | Valeur |
   | --- | --- |
   | `SECRET_KEY` | Secret aléatoire, différent des mots de passe |
   | `CLINIKDOC_ADMIN_LOGIN` | Identifiant administrateur choisi |
   | `CLINIKDOC_ADMIN_PASSWORD` | Mot de passe administrateur fort |

   Pour générer un secret aléatoire localement :

   ```powershell
   python -c "import secrets; print(secrets.token_hex(32))"
   ```

   Ne publiez pas ces valeurs dans Git et ne les partagez pas dans une capture
   d'écran.
4. Lancez **Deploy** dans Vercel. Flask est détecté depuis `app.py`, et les
   fichiers dans `public/static` sont servis comme ressources statiques.
5. Ouvrez l'URL `*.vercel.app` créée par Vercel. Connectez-vous en
   administrateur avec les identifiants définis à l'étape 3, puis ajoutez des
   médecins pour permettre les réservations.

Le fichier local `projet.db` et l'export SQL ne sont pas inclus dans le
déploiement Vercel.

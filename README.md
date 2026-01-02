# Basketball DB - Guide d'utilisation

## Installation

1. **Créer un environnement virtuel :**
   ```bash
   python3 -m venv venv
   ```

2. **Activer l'environnement virtuel :**
   ```bash
   source venv/bin/activate
   ```

3. **Installer les dépendances :**
   ```bash
   pip install -r requirements.txt
   ```

## Lancer le site web en local

1. **Activer l'environnement virtuel :**
   ```bash
   source venv/bin/activate
   ```

2. **Lancer l'application Flask :**
   ```bash
   python app.py
   ```

3. **Ouvrir dans le navigateur :**
   ```
   http://127.0.0.1:5000/
   ```

## Se connecter à la base de données

La base de données SQLite se trouve dans le fichier `basketball.db`.

### Connexion via le terminal

```bash
sqlite3 basketball.db
```

### Exemples de requêtes SQL

```sql
-- Lister toutes les tables
.tables

-- Afficher le schéma d'une table
.schema Player

-- Lister tous les joueurs
SELECT * FROM Player;

-- Compter le nombre de joueurs
SELECT COUNT(*) FROM Player;

-- Lister les équipes
SELECT * FROM Team;

-- Lister les matchs avec les scores
SELECT g.date_time, g.location, 
       t1.team_name as home_team, gp1.score as home_score,
       t2.team_name as away_team, gp2.score as away_score
FROM Game g
JOIN GameParticipant gp1 ON g.game_id = gp1.game_id AND gp1.role = 'home'
JOIN GameParticipant gp2 ON g.game_id = gp2.game_id AND gp2.role = 'away'
JOIN Team t1 ON gp1.team_id = t1.team_id
JOIN Team t2 ON gp2.team_id = t2.team_id;

-- Quitter SQLite
.quit
```

### Commandes SQLite utiles

```sql
.headers on          -- Afficher les en-têtes de colonnes
.mode column         -- Format colonnes
.width 15 20 10      -- Ajuster la largeur des colonnes
```
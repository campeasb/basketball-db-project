from flask import Flask, render_template, abort
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
import os

app = Flask(__name__)

# --------------------
# CONFIGURATION DB
# --------------------
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
db_path = os.path.join(BASE_DIR, "basketball.db")

app.config["SQLALCHEMY_DATABASE_URI"] = f"sqlite:///{db_path}"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)


# --------------------
# MODELES ORM
# (mappés sur ton schema.sql existant)
# --------------------

class Country(db.Model):
    __tablename__ = "Country"

    country_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text, nullable=False)
    iso_code = db.Column(db.Text, unique=True)

    def __repr__(self):
        return f"<Country {self.country_id} {self.name}>"


class Team(db.Model):
    __tablename__ = "Team"

    team_id = db.Column(db.Integer, primary_key=True)
    team_name = db.Column(db.Text, nullable=False)
    type = db.Column(db.Text, nullable=False)  # 'club' ou 'national'

    def __repr__(self):
        return f"<Team {self.team_id} {self.team_name} ({self.type})>"


class Player(db.Model):
    __tablename__ = "Player"

    player_id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.Text, nullable=False)
    date_of_birth = db.Column(db.Text)
    height_cm = db.Column(db.Integer)

    citizenship_country_id = db.Column(
        db.Integer,
        db.ForeignKey("Country.country_id")
    )
    country = db.relationship("Country", backref="players")

    def __repr__(self):
        return f"<Player {self.player_id} {self.full_name}>"

class Game(db.Model):
    __tablename__ = "Game"

    game_id = db.Column(db.Integer, primary_key=True)
    date_time = db.Column(db.Text)
    location = db.Column(db.Text)
    competition_type = db.Column(db.Text)  # 'league' ou 'championship'
    league_season_id_league = db.Column(db.Integer)
    league_season_id_season = db.Column(db.Integer)
    edition_id = db.Column(db.Integer)
    stage = db.Column(db.Text)
    is_final = db.Column(db.Integer, nullable=False, default=0)


class GameParticipant(db.Model):
    __tablename__ = "GameParticipant"

    game_id = db.Column(db.Integer, db.ForeignKey("Game.game_id"), primary_key=True)
    team_id = db.Column(db.Integer, db.ForeignKey("Team.team_id"), primary_key=True)

    role = db.Column(db.Text, nullable=False)  # 'home' / 'away'
    score = db.Column(db.Integer)

    game = db.relationship("Game", backref="participants")
    team = db.relationship("Team")

class PlayerClubContract(db.Model):
    __tablename__ = "PlayerClubContract"

    player_id = db.Column(
        db.Integer,
        db.ForeignKey("Player.player_id"),
        primary_key=True
    )
    team_id = db.Column(
        db.Integer,
        db.ForeignKey("Team.team_id"),
        primary_key=True
    )
    start_date = db.Column(db.Text, primary_key=True)
    end_date = db.Column(db.Text)

    player = db.relationship("Player", backref="club_contracts")
    team = db.relationship("Team", backref="club_contracts")

class NationalSelection(db.Model):
    __tablename__ = "NationalSelection"

    player_id = db.Column(
        db.Integer,
        db.ForeignKey("Player.player_id"),
        primary_key=True
    )
    team_id = db.Column(
        db.Integer,
        db.ForeignKey("Team.team_id"),
        primary_key=True
    )
    start_date = db.Column(db.Text, primary_key=True)
    end_date = db.Column(db.Text)

    player = db.relationship("Player", backref="national_selections")
    team = db.relationship("Team", backref="national_selections")


# --------------------
# ROUTES SIMPLES
# --------------------

@app.route("/")
def index():
    return render_template("index.html")


@app.route("/players")
def list_players():
    players = Player.query.order_by(Player.full_name).all()
    return render_template("players.html", players=players)


@app.route("/players/<int:player_id>")
def player_detail(player_id):
    from flask import abort
    player = Player.query.get(player_id)
    if player is None:
        abort(404)
    return render_template("player_detail.html", player=player)


@app.route("/teams")
def list_teams():
    clubs = Team.query.filter_by(type="club").order_by(Team.team_name).all()
    nationals = Team.query.filter_by(type="national").order_by(Team.team_name).all()
    return render_template("teams.html", clubs=clubs, nationals=nationals)

@app.route("/games")
def list_games():
    games = Game.query.order_by(Game.date_time.desc()).all()

    # On attache "home" et "away" à chaque game (simple pour le template)
    for g in games:
        home = None
        away = None
        for p in g.participants:
            if p.role == "home":
                home = p
            elif p.role == "away":
                away = p
        g._home = home
        g._away = away

    return render_template("games.html", games=games)

@app.route("/teams/<int:team_id>")
def team_detail(team_id):
    team = Team.query.get(team_id)
    if team is None:
        abort(404)

    # Liste de joueurs associée selon le type d'équipe
    if team.type == "club":
        players = (
            Player.query
            .join(PlayerClubContract, Player.player_id == PlayerClubContract.player_id)
            .filter(PlayerClubContract.team_id == team_id)
            .order_by(Player.full_name)
            .all()
        )
    else:  # national
        players = (
            Player.query
            .join(NationalSelection, Player.player_id == NationalSelection.player_id)
            .filter(NationalSelection.team_id == team_id)
            .order_by(Player.full_name)
            .all()
        )

    return render_template("team_detail.html", team=team, players=players)

@app.route("/stats")
def stats():
    # 1) Top 10 joueurs (Points totaux en équipe nationale)
    # Formule : points = ft_made + 2*fg2_made + 3*fg3_made
    query_1 = text("""
        SELECT p.full_name, t.team_name,
               SUM(pgs.ft_made + 2*pgs.fg2_made + 3*pgs.fg3_made) as total_points
        FROM Player p
        JOIN PlayerGameStats pgs ON p.player_id = pgs.player_id
        JOIN GameParticipant gp ON pgs.game_id = gp.game_id
        JOIN Team t ON gp.team_id = t.team_id
        WHERE t.type = 'national' AND pgs.player_id IN (
            SELECT ns.player_id FROM NationalSelection ns WHERE ns.team_id = t.team_id
        )
        GROUP BY p.player_id
        ORDER BY total_points DESC
        LIMIT 10
    """)
    res_1 = db.session.execute(query_1).fetchall()

    # 2) Top 3 joueurs (% Lancer Francs - Finale Euro 2002)
    # On cherche l'edition_id pour l'Euro 2002 (supposons id=1 selon votre seed)
    query_2 = text("""
        SELECT p.full_name, 
               (CAST(pgs.ft_made AS FLOAT) / pgs.ft_att) * 100 as ft_percent
        FROM Player p
        JOIN PlayerGameStats pgs ON p.player_id = pgs.player_id
        JOIN Game g ON pgs.game_id = g.game_id
        JOIN ChampionshipEdition ce ON g.edition_id = ce.edition_id
        WHERE ce.championship_id = 1 
          AND ce.year = 2002 
          AND g.stage = 'Final'
          AND pgs.ft_att > 0
        ORDER BY ft_percent DESC
        LIMIT 3
    """)
    res_2 = db.session.execute(query_2).fetchall()

    # 3) Club avec la plus grande moyenne de taille
    query_3 = text("""
        SELECT t.team_name, AVG(p.height_cm) as avg_height
        FROM Team t
        JOIN PlayerClubContract pcc ON t.team_id = pcc.team_id
        JOIN Player p ON pcc.player_id = p.player_id
        WHERE t.type = 'club'
        GROUP BY t.team_id
        ORDER BY avg_height DESC
        LIMIT 1
    """)
    res_3 = db.session.execute(query_3).fetchone()

    # 4) Sponsor ayant sponsorisé le plus d'équipes nationales championnes du monde
    # championship_id = 2 (World Champ), is_final = 1
    # On doit trouver qui a gagné chaque finale
    query_4 = text("""
        SELECT s.name, COUNT(DISTINCT ce.year) as titles_count
        FROM Sponsor s
        JOIN Sponsorship sp ON s.sponsor_id = sp.sponsor_id
        JOIN Team t ON sp.team_id = t.team_id
        JOIN GameParticipant gp ON t.team_id = gp.team_id
        JOIN Game g ON gp.game_id = g.game_id
        JOIN ChampionshipEdition ce ON g.edition_id = ce.edition_id
        WHERE ce.championship_id = 2  -- World Championship
          AND g.is_final = 1
          -- L'équipe doit avoir gagné (score max du match)
          AND gp.score = (SELECT MAX(score) FROM GameParticipant WHERE game_id = g.game_id)
        GROUP BY s.sponsor_id
        ORDER BY titles_count DESC
        LIMIT 1
    """)
    res_4 = db.session.execute(query_4).fetchone()

    # 5) Pour chaque club, le joueur avec le meilleur % à 3pts (Saison courante)
    # C'est complexe en une seule requête SQL simple. 
    # On va récupérer les stats agrégées et filtrer en Python pour simplifier.
    query_5 = text("""
        SELECT t.team_name, p.full_name,
               SUM(pgs.fg3_made) as made, SUM(pgs.fg3_att) as att
        FROM PlayerGameStats pgs
        JOIN Game g ON pgs.game_id = g.game_id
        JOIN GameParticipant gp ON g.game_id = gp.game_id 
             AND gp.team_id IN (SELECT team_id FROM PlayerClubContract WHERE player_id = pgs.player_id)
        JOIN Team t ON gp.team_id = t.team_id
        JOIN Player p ON pgs.player_id = p.player_id
        WHERE g.competition_type = 'league' 
          AND g.league_season_id_season = 1 -- Saison courante id=1
          AND t.type = 'club'
        GROUP BY t.team_id, p.player_id
        HAVING att > 0
    """)
    raw_5 = db.session.execute(query_5).fetchall()
    
    # Traitement Python pour trouver le max par club
    clubs_best_3p = {}
    for row in raw_5:
        pct = (row.made / row.att) * 100
        team = row.team_name
        if team not in clubs_best_3p or pct > clubs_best_3p[team]['pct']:
            clubs_best_3p[team] = {'player': row.full_name, 'pct': pct}

    # 6) Pour un club particulier (ex: Real Madrid, ID=4), joueur avec le plus d'Assists/Match
    # Vous pouvez changer l'ID ici ou le passer en paramètre d'URL
    target_club_id = 4 
    query_6 = text("""
        SELECT p.full_name, AVG(pgs.assists) as avg_assists
        FROM PlayerGameStats pgs
        JOIN Game g ON pgs.game_id = g.game_id
        JOIN GameParticipant gp ON g.game_id = gp.game_id
        JOIN Player p ON pgs.player_id = p.player_id
        WHERE gp.team_id = :club_id
        GROUP BY p.player_id
        ORDER BY avg_assists DESC
        LIMIT 1
    """)
    res_6 = db.session.execute(query_6, {'club_id': target_club_id}).fetchone()

    # 7) Clubs ayant gagné l'Euroleague (> 3 fois)
    # championship_id = 3 (selon seed_extended), is_final = 1
    query_7 = text("""
        SELECT t.team_name, COUNT(ce.year) as wins
        FROM Team t
        JOIN GameParticipant gp ON t.team_id = gp.team_id
        JOIN Game g ON gp.game_id = g.game_id
        JOIN ChampionshipEdition ce ON g.edition_id = ce.edition_id
        WHERE ce.championship_id = 3
          AND g.is_final = 1
          AND gp.score = (SELECT MAX(score) FROM GameParticipant WHERE game_id = g.game_id)
        GROUP BY t.team_id
        HAVING wins > 3
    """)
    res_7 = db.session.execute(query_7).fetchall()

    return render_template("stats.html", 
                           res_1=res_1, res_2=res_2, res_3=res_3, 
                           res_4=res_4, res_5=clubs_best_3p, 
                           res_6=res_6, res_7=res_7)

if __name__ == "__main__":
    app.run(debug=True)
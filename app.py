from flask import Flask, render_template, abort
from flask_sqlalchemy import SQLAlchemy
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
if __name__ == "__main__":
    app.run(debug=True)
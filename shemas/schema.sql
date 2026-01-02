-- =========================================
-- SQLite schema - Basketball DB (updated)
-- =========================================

PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- =====================
-- Reference tables
-- =====================
CREATE TABLE Country (
  country_id INTEGER PRIMARY KEY,
  name       TEXT NOT NULL,
  iso_code   TEXT UNIQUE
);

CREATE TABLE League (
  league_id INTEGER PRIMARY KEY,
  name      TEXT NOT NULL
);

CREATE TABLE Season (
  season_id  INTEGER PRIMARY KEY,
  label      TEXT NOT NULL,
  start_date TEXT,  -- store ISO-8601 date 'YYYY-MM-DD'
  end_date   TEXT
);

CREATE TABLE Championship (
  championship_id INTEGER PRIMARY KEY,
  name            TEXT NOT NULL
);

CREATE TABLE Sponsor (
  sponsor_id INTEGER PRIMARY KEY,
  name       TEXT NOT NULL,
  city       TEXT
);

-- =====================
-- Teams
-- =====================
CREATE TABLE Team (
  team_id   INTEGER PRIMARY KEY,
  team_name TEXT NOT NULL,
  type      TEXT NOT NULL CHECK (type IN ('club','national'))
);

-- =====================
-- Junctions / editions
-- =====================
CREATE TABLE LeagueSeason (
  league_id INTEGER NOT NULL,
  season_id INTEGER NOT NULL,
  PRIMARY KEY (league_id, season_id),
  FOREIGN KEY (league_id) REFERENCES League(league_id),
  FOREIGN KEY (season_id) REFERENCES Season(season_id)
);

CREATE TABLE ChampionshipEdition (
  edition_id       INTEGER PRIMARY KEY,
  championship_id  INTEGER NOT NULL,
  year             INTEGER NOT NULL,
  host_country_id  INTEGER,
  FOREIGN KEY (championship_id) REFERENCES Championship(championship_id),
  FOREIGN KEY (host_country_id) REFERENCES Country(country_id)
);

-- =====================
-- Players
-- =====================
CREATE TABLE Player (
  player_id                INTEGER PRIMARY KEY,
  full_name                TEXT NOT NULL,
  date_of_birth            TEXT,   -- ISO-8601 date
  height_cm                INTEGER,
  citizenship_country_id   INTEGER,
  FOREIGN KEY (citizenship_country_id) REFERENCES Country(country_id)
);

-- =====================
-- Club contracts & national selections
-- (type d'équipe vérifié via triggers, pas via CHECK)
-- =====================
CREATE TABLE PlayerClubContract (
  player_id  INTEGER NOT NULL,
  team_id    INTEGER NOT NULL,
  start_date TEXT    NOT NULL,  -- ISO-8601 date
  end_date   TEXT,
  PRIMARY KEY (player_id, team_id, start_date),
  FOREIGN KEY (player_id) REFERENCES Player(player_id),
  FOREIGN KEY (team_id)   REFERENCES Team(team_id)
);

CREATE TABLE NationalSelection (
  player_id  INTEGER NOT NULL,
  team_id    INTEGER NOT NULL,
  start_date TEXT    NOT NULL,  -- ISO-8601 date
  end_date   TEXT,
  PRIMARY KEY (player_id, team_id, start_date),
  FOREIGN KEY (player_id) REFERENCES Player(player_id),
  FOREIGN KEY (team_id)   REFERENCES Team(team_id)
);

-- Triggers: PlayerClubContract must reference a 'club' team
CREATE TRIGGER trg_pcc_team_is_club_ins
BEFORE INSERT ON PlayerClubContract
FOR EACH ROW
WHEN (SELECT type FROM Team WHERE team_id = NEW.team_id) <> 'club'
BEGIN
  SELECT RAISE(ABORT, 'PlayerClubContract requires a club team');
END;

CREATE TRIGGER trg_pcc_team_is_club_upd
BEFORE UPDATE ON PlayerClubContract
FOR EACH ROW
WHEN (SELECT type FROM Team WHERE team_id = NEW.team_id) <> 'club'
BEGIN
  SELECT RAISE(ABORT, 'PlayerClubContract requires a club team');
END;

-- Triggers: NationalSelection must reference a 'national' team
CREATE TRIGGER trg_ns_team_is_national_ins
BEFORE INSERT ON NationalSelection
FOR EACH ROW
WHEN (SELECT type FROM Team WHERE team_id = NEW.team_id) <> 'national'
BEGIN
  SELECT RAISE(ABORT, 'NationalSelection requires a national team');
END;

CREATE TRIGGER trg_ns_team_is_national_upd
BEFORE UPDATE ON NationalSelection
FOR EACH ROW
WHEN (SELECT type FROM Team WHERE team_id = NEW.team_id) <> 'national'
BEGIN
  SELECT RAISE(ABORT, 'NationalSelection requires a national team');
END;

-- =====================
-- Games
-- =====================
CREATE TABLE Game (
  game_id                  INTEGER PRIMARY KEY,
  date_time                TEXT,   -- ISO datetime string 'YYYY-MM-DDTHH:MM:SS'
  location                 TEXT,
  competition_type         TEXT CHECK (competition_type IN ('league','championship')),
  league_season_id_league  INTEGER,
  league_season_id_season  INTEGER,
  edition_id               INTEGER,
  stage                    TEXT,
  is_final                 INTEGER NOT NULL DEFAULT 0 CHECK (is_final IN (0,1)),
  FOREIGN KEY (league_season_id_league, league_season_id_season)
    REFERENCES LeagueSeason(league_id, season_id),
  FOREIGN KEY (edition_id) REFERENCES ChampionshipEdition(edition_id),

  -- Cohérence: un match de 'league' référence LeagueSeason et pas ChampionshipEdition,
  -- un match de 'championship' fait l'inverse.
  CHECK (
    (competition_type='league'
      AND league_season_id_league IS NOT NULL
      AND league_season_id_season IS NOT NULL
      AND edition_id IS NULL)
    OR
    (competition_type='championship'
      AND edition_id IS NOT NULL
      AND league_season_id_league IS NULL
      AND league_season_id_season IS NULL)
  )
);

CREATE TABLE GameParticipant (
  game_id INTEGER NOT NULL,
  team_id INTEGER NOT NULL,
  role    TEXT NOT NULL CHECK (role IN ('home','away')),
  score   INTEGER,
  PRIMARY KEY (game_id, team_id),
  FOREIGN KEY (game_id) REFERENCES Game(game_id),
  FOREIGN KEY (team_id) REFERENCES Team(team_id),
  -- Empêche d'avoir 2 équipes 'home' ou 2 'away' dans le même match
  UNIQUE (game_id, role)
);

CREATE TABLE PlayerGameStats (
  player_id INTEGER NOT NULL,
  game_id   INTEGER NOT NULL,
  fg3_made  INTEGER NOT NULL DEFAULT 0,
  fg2_made  INTEGER NOT NULL DEFAULT 0,
  fg3_att   INTEGER NOT NULL DEFAULT 0,
  fg2_att   INTEGER NOT NULL DEFAULT 0,
  ft_made   INTEGER NOT NULL DEFAULT 0,
  ft_att    INTEGER NOT NULL DEFAULT 0,
  assists   INTEGER NOT NULL DEFAULT 0,
  rebounds  INTEGER NOT NULL DEFAULT 0,
  blocks    INTEGER NOT NULL DEFAULT 0,
  fouls     INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (player_id, game_id),
  FOREIGN KEY (player_id) REFERENCES Player(player_id),
  FOREIGN KEY (game_id)   REFERENCES Game(game_id)
);

-- =====================
-- Sponsorships
-- =====================
CREATE TABLE Sponsorship (
  sponsor_id INTEGER NOT NULL,
  team_id    INTEGER NOT NULL,
  amount     REAL,
  start_date TEXT,
  end_date   TEXT,
  PRIMARY KEY (sponsor_id, team_id, start_date),
  FOREIGN KEY (sponsor_id) REFERENCES Sponsor(sponsor_id),
  FOREIGN KEY (team_id)    REFERENCES Team(team_id)
);

-- =====================
-- Indexes (performances FKs / requêtes fréquentes)
-- =====================
CREATE INDEX idx_player_citizenship ON Player(citizenship_country_id);
CREATE INDEX idx_leagueseason_league ON LeagueSeason(league_id);
CREATE INDEX idx_leagueseason_season ON LeagueSeason(season_id);
CREATE INDEX idx_champedition_champ ON ChampionshipEdition(championship_id);
CREATE INDEX idx_pcc_player ON PlayerClubContract(player_id);
CREATE INDEX idx_pcc_team   ON PlayerClubContract(team_id);
CREATE INDEX idx_ns_player  ON NationalSelection(player_id);
CREATE INDEX idx_ns_team    ON NationalSelection(team_id);
CREATE INDEX idx_game_league ON Game(league_season_id_league, league_season_id_season);
CREATE INDEX idx_game_edition ON Game(edition_id);
CREATE INDEX idx_gpart_game ON GameParticipant(game_id);
CREATE INDEX idx_gpart_team ON GameParticipant(team_id);
CREATE INDEX idx_pgs_game   ON PlayerGameStats(game_id);
CREATE INDEX idx_pgs_player ON PlayerGameStats(player_id);
CREATE INDEX idx_sponsor_team ON Sponsorship(team_id);
CREATE INDEX idx_sponsor_sponsor ON Sponsorship(sponsor_id);

COMMIT;
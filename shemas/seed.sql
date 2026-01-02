PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;

-- ===== Countries
INSERT INTO Country(country_id, name, iso_code) VALUES
  (1,'France','FRA'),
  (2,'Spain','ESP'),
  (3,'United States','USA'),
  (4,'Turkey','TUR');

-- ===== League & Season (pour la saison courante 2025/26)
INSERT INTO League(league_id, name) VALUES
  (1,'EuroLeague');

INSERT INTO Season(season_id, label, start_date, end_date) VALUES
  (1,'2025/26','2025-07-01','2026-06-30');

INSERT INTO LeagueSeason(league_id, season_id) VALUES
  (1,1);

-- ===== Championships (Europe & Monde)
INSERT INTO Championship(championship_id, name) VALUES
  (1,'European Championship'),
  (2,'World Championship');

-- Editions : Euro 2002 ; Mondial 2010 & 2014
INSERT INTO ChampionshipEdition(edition_id, championship_id, year, host_country_id) VALUES
  (1,1,2002,4),   -- Euro 2002 en Turquie (exemple)
  (2,2,2010,4),   -- Mondial 2010
  (3,2,2014,2);   -- Mondial 2014 en Espagne (exemple)

-- ===== Teams (nationales + clubs)
INSERT INTO Team(team_id, team_name, type) VALUES
  (1,'Spain NT','national'),
  (2,'France NT','national'),
  (3,'USA NT','national'),
  (4,'Real Madrid','club'),
  (5,'ASVEL','club');

-- ===== Players (heights utiles pour Q3)
INSERT INTO Player(player_id, full_name, date_of_birth, height_cm, citizenship_country_id) VALUES
  (1,'Juan Perez','1990-01-01',198,2),   -- ESP
  (2,'Pierre Dubois','1991-02-02',196,1),-- FRA
  (3,'John Smith','1988-03-03',201,3),   -- USA
  (4,'Luis Gomez','1992-04-04',205,2);   -- ESP

-- ===== Club contracts (saison courante)
INSERT INTO PlayerClubContract(player_id, team_id, start_date, end_date) VALUES
  (1,4,'2025-07-01',NULL),  -- Juan Perez -> Real Madrid
  (2,5,'2025-07-01',NULL),  -- Pierre Dubois -> ASVEL
  (3,4,'2025-07-01',NULL),  -- John Smith  -> Real Madrid
  (4,4,'2025-07-01',NULL);  -- Luis Gomez  -> Real Madrid

-- ===== National selections (actives couvrant les dates des matches)
INSERT INTO NationalSelection(player_id, team_id, start_date, end_date) VALUES
  (1,1,'2000-01-01',NULL),  -- Juan -> Spain NT
  (2,2,'2000-01-01',NULL),  -- Pierre -> France NT
  (3,3,'2000-01-01',NULL),  -- John -> USA NT
  (4,1,'2000-01-01',NULL);  -- Luis -> Spain NT

-- ===== Sponsors
INSERT INTO Sponsor(sponsor_id, name, city) VALUES
  (1,'Nike','Beaverton'),
  (2,'Adidas','Herzogenaurach');

-- Sponsorships (compte pour Q4)
-- Nike sponsorise Spain NT et USA NT ; Adidas sponsorise France NT
INSERT INTO Sponsorship(sponsor_id, team_id, amount, start_date, end_date) VALUES
  (1,1,1000000,'2000-01-01',NULL),  -- Nike -> Spain NT
  (1,3,1000000,'2000-01-01',NULL),  -- Nike -> USA NT
  (2,2, 800000,'2000-01-01',NULL);  -- Adidas -> France NT

-- ===== GAMES =====

-- (A) Euro 2002 FINAL: Spain NT vs France NT (is_final = 1)
INSERT INTO Game(game_id, date_time, location, competition_type,
                 league_season_id_league, league_season_id_season,
                 edition_id, stage, is_final)
VALUES
  (1,'2002-09-08T20:00:00','Istanbul','championship',
   NULL,NULL,
   1,'Final',1);

INSERT INTO GameParticipant(game_id, team_id, role, score) VALUES
  (1,1,'home',75),  -- Spain NT 75
  (1,2,'away',70);  -- France NT 70

-- Player stats (utiles pour Q1 + Q2: %LF (FT%) dans la finale Euro 2002)
-- Points = 3*fg3_made + 2*fg2_made + ft_made
INSERT INTO PlayerGameStats(player_id, game_id,
  fg3_made, fg2_made, fg3_att, fg2_att, ft_made, ft_att, assists, rebounds, blocks, fouls)
VALUES
  (1,1, 2,5, 5,10, 6,6, 3,5,0,2),  -- Juan Perez (ESP) FT% = 100%
  (2,1, 1,6, 4,12, 7,8, 5,7,1,3),  -- Pierre Dubois (FRA) FT% = 87.5%
  (4,1, 0,4, 1,8, 2,2, 2,6,0,1);   -- Luis Gomez (ESP) FT% = 100% (peu d'attaques)

-- (B) World Championship 2010 FINAL: Spain NT vs USA NT -> Spain gagne
INSERT INTO Game(game_id, date_time, location, competition_type,
                 league_season_id_league, league_season_id_season,
                 edition_id, stage, is_final)
VALUES
  (2,'2010-09-12T20:00:00','Istanbul','championship',
   NULL,NULL,
   2,'Final',1);

INSERT INTO GameParticipant(game_id, team_id, role, score) VALUES
  (2,1,'home',80),  -- Spain
  (2,3,'away',78);  -- USA

INSERT INTO PlayerGameStats(player_id, game_id,
  fg3_made, fg2_made, fg3_att, fg2_att, ft_made, ft_att, assists, rebounds, blocks, fouls)
VALUES
  (1,2, 3,4, 7,9, 4,5, 4,4,0,2),   -- Juan (ESP)
  (3,2, 2,5, 6,11, 3,4, 6,7,1,3);  -- John (USA)

-- (C) World Championship 2014 FINAL: USA NT vs France NT -> USA gagne
INSERT INTO Game(game_id, date_time, location, competition_type,
                 league_season_id_league, league_season_id_season,
                 edition_id, stage, is_final)
VALUES
  (3,'2014-09-14T20:00:00','Madrid','championship',
   NULL,NULL,
   3,'Final',1);

INSERT INTO GameParticipant(game_id, team_id, role, score) VALUES
  (3,3,'home',85),   -- USA
  (3,2,'away',72);   -- France

INSERT INTO PlayerGameStats(player_id, game_id,
  fg3_made, fg2_made, fg3_att, fg2_att, ft_made, ft_att, assists, rebounds, blocks, fouls)
VALUES
  (3,3, 4,6, 9,12, 5,6, 5,7,1,2),  -- John (USA)
  (2,3, 2,5, 6,10, 4,5, 4,5,0,3);  -- Pierre (FRA)

-- (D) League game saison 2025/26 (pour Q3 & Q5: % à 3pts par club)
INSERT INTO Game(game_id, date_time, location, competition_type,
                 league_season_id_league, league_season_id_season,
                 edition_id, stage, is_final)
VALUES
  (4,'2025-10-10T19:30:00','Madrid','league',
   1,1,
   NULL,'Regular',0);

INSERT INTO GameParticipant(game_id, team_id, role, score) VALUES
  (4,4,'home',92),  -- Real Madrid (club)
  (4,5,'away',88);  -- ASVEL

INSERT INTO PlayerGameStats(player_id, game_id,
  fg3_made, fg2_made, fg3_att, fg2_att, ft_made, ft_att, assists, rebounds, blocks, fouls)
VALUES
  (1,4, 3,3, 6,8, 2,2, 5,6,0,2),  -- Juan (Real) 3P% = 50%
  (3,4, 1,4, 4,7, 1,2, 4,5,1,3),  -- John (Real) 3P% = 25%
  (4,4, 0,5, 1,6, 0,0, 2,7,0,2),  -- Luis (Real) 3P% = 0%
  (2,4, 2,3, 5,6, 3,4, 3,4,0,3);  -- Pierre (ASVEL) 3P% = 40%

COMMIT;
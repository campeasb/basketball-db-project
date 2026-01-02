PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;

INSERT OR IGNORE INTO Country(country_id, name, iso_code) VALUES
  (1,'France','FRA'),
  (2,'Spain','ESP'),
  (3,'United States','USA'),
  (4,'Turkey','TUR'),
  (5,'Serbia','SRB'),
  (6,'Greece','GRC');

INSERT OR IGNORE INTO League(league_id, name) VALUES
  (1,'EuroLeague');

INSERT OR IGNORE INTO Season(season_id, label, start_date, end_date) VALUES
  (1,'2025/26','2025-07-01','2026-06-30');

INSERT OR IGNORE INTO LeagueSeason(league_id, season_id) VALUES
  (1,1);

INSERT OR IGNORE INTO Championship(championship_id, name) VALUES
  (1,'European Championship'),
  (2,'World Championship'),
  (3,'Euroleague');


INSERT OR IGNORE INTO Team(team_id, team_name, type) VALUES
  (1,'Spain NT','national'),
  (2,'France NT','national'),
  (3,'USA NT','national'),
  (10,'Turkey NT','national'),
  (11,'Serbia NT','national'),
  (12,'Greece NT','national');

INSERT OR IGNORE INTO Team(team_id, team_name, type) VALUES
  (4,'Real Madrid','club'),
  (5,'ASVEL','club'),
  (20,'FC Barcelona','club'),
  (21,'Olympiacos','club'),
  (22,'Fenerbahçe','club'),
  (23,'Panathinaikos','club');

INSERT OR IGNORE INTO Player(player_id, full_name, date_of_birth, height_cm, citizenship_country_id) VALUES
  (1,'Juan Perez','1990-01-01',198,2),
  (4,'Luis Gomez','1992-04-04',205,2),
  (30,'Carlos Ruiz','1994-06-12',200,2),
  (31,'Miguel Torres','1995-08-21',193,2);

INSERT OR IGNORE INTO Player(player_id, full_name, date_of_birth, height_cm, citizenship_country_id) VALUES
  (2,'Pierre Dubois','1991-02-02',196,1),
  (32,'Antoine Martin','1993-03-10',202,1),
  (33,'Nicolas Laurent','1996-11-02',190,1);

INSERT OR IGNORE INTO Player(player_id, full_name, date_of_birth, height_cm, citizenship_country_id) VALUES
  (3,'John Smith','1988-03-03',201,3),
  (34,'Mike Johnson','1992-09-09',203,3);

INSERT OR IGNORE INTO Player(player_id, full_name, date_of_birth, height_cm, citizenship_country_id) VALUES
  (35,'Emre Kaya','1994-01-19',199,4),
  (36,'Kerem Yilmaz','1991-12-12',206,4);

INSERT OR IGNORE INTO Player(player_id, full_name, date_of_birth, height_cm, citizenship_country_id) VALUES
  (37,'Nikola Petrovic','1990-05-05',208,5),
  (38,'Marko Jovanovic','1995-07-07',195,5);

-- Grèce / Panathinaikos
INSERT OR IGNORE INTO Player(player_id, full_name, date_of_birth, height_cm, citizenship_country_id) VALUES
  (39,'Giorgos Papas','1993-04-14',197,6),
  (40,'Dimitris Nikolaou','1996-02-28',204,6);

INSERT OR IGNORE INTO PlayerClubContract(player_id, team_id, start_date, end_date) VALUES
  (1,4,'2025-07-01',NULL),
  (3,4,'2025-07-01',NULL),
  (4,4,'2025-07-01',NULL),
  (30,4,'2025-07-01',NULL),
  (34,4,'2025-07-01',NULL);

INSERT OR IGNORE INTO PlayerClubContract(player_id, team_id, start_date, end_date) VALUES
  (2,5,'2025-07-01',NULL),
  (32,5,'2025-07-01',NULL),
  (33,5,'2025-07-01',NULL);

INSERT OR IGNORE INTO PlayerClubContract(player_id, team_id, start_date, end_date) VALUES
  (31,20,'2025-07-01',NULL);

INSERT OR IGNORE INTO PlayerClubContract(player_id, team_id, start_date, end_date) VALUES
  (37,21,'2025-07-01',NULL),
  (38,21,'2025-07-01',NULL);

INSERT OR IGNORE INTO PlayerClubContract(player_id, team_id, start_date, end_date) VALUES
  (35,22,'2025-07-01',NULL),
  (36,22,'2025-07-01',NULL);

INSERT OR IGNORE INTO PlayerClubContract(player_id, team_id, start_date, end_date) VALUES
  (39,23,'2025-07-01',NULL),
  (40,23,'2025-07-01',NULL);

INSERT OR IGNORE INTO NationalSelection(player_id, team_id, start_date, end_date) VALUES
  (1,1,'2000-01-01',NULL),
  (4,1,'2000-01-01',NULL),
  (30,1,'2005-01-01',NULL),
  (31,1,'2010-01-01',NULL),

  (2,2,'2000-01-01',NULL),
  (32,2,'2004-01-01',NULL),
  (33,2,'2012-01-01',NULL),

  (3,3,'2000-01-01',NULL),
  (34,3,'2008-01-01',NULL),

  (35,10,'2008-01-01',NULL),
  (36,10,'2006-01-01',NULL),

  (37,11,'2006-01-01',NULL),
  (38,11,'2014-01-01',NULL),

  (39,12,'2010-01-01',NULL),
  (40,12,'2011-01-01',NULL);


INSERT OR IGNORE INTO Sponsor(sponsor_id, name, city) VALUES
  (1,'Nike','Beaverton'),
  (2,'Adidas','Herzogenaurach'),
  (3,'Pepsi','Purchase');

INSERT OR IGNORE INTO Sponsorship(sponsor_id, team_id, amount, start_date, end_date) VALUES
  (1,1,1000000,'2000-01-01',NULL),   -- Nike -> Spain NT
  (1,3,1200000,'2000-01-01',NULL),   -- Nike -> USA NT
  (1,11, 900000,'2005-01-01',NULL),  -- Nike -> Serbia NT
  (2,2, 800000,'2000-01-01',NULL),   -- Adidas -> France NT
  (3,10,600000,'2008-01-01',NULL);   -- Pepsi -> Turkey NT


INSERT OR IGNORE INTO ChampionshipEdition(edition_id, championship_id, year, host_country_id) VALUES
  (1,1,2002,4);

INSERT OR IGNORE INTO ChampionshipEdition(edition_id, championship_id, year, host_country_id) VALUES
  (100,2,2006,6),
  (101,2,2010,4),
  (102,2,2014,2),
  (103,2,2019,2);

INSERT OR IGNORE INTO ChampionshipEdition(edition_id, championship_id, year, host_country_id) VALUES
  (200,3,2018,2),
  (201,3,2019,6),
  (202,3,2020,4),
  (203,3,2021,1),
  (204,3,2022,2);

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (500,'2002-09-08T20:00:00','Istanbul','championship',
   NULL,NULL,
   1,'Final',1);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (500,1,'home',75),  -- Spain NT
  (500,2,'away',70);  -- France NT

INSERT OR IGNORE INTO PlayerGameStats(player_id, game_id,
  fg3_made, fg2_made, fg3_att, fg2_att, ft_made, ft_att, assists, rebounds, blocks, fouls)
VALUES
  (1,500, 2,5, 5,10, 6,6, 3,5,0,2),    -- 100%
  (4,500, 1,4, 3,9,  1,2, 2,6,0,1),    -- 50%
  (30,500,3,3, 6,7,  8,9, 5,4,0,2),    -- 88.9%
  (2,500, 1,6, 4,12, 7,8, 5,7,1,3),    -- 87.5%
  (32,500,0,5, 1,10, 4,4, 6,8,1,2),    -- 100% (mais moins d'FT)
  (33,500,1,2, 2,6,  2,3, 2,3,0,1);    -- 66.7%

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (510,'2006-09-03T20:00:00','Athens','championship',NULL,NULL,100,'Final',1);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (510,12,'home',83),
  (510,11,'away',79);

INSERT OR IGNORE INTO PlayerGameStats(player_id, game_id,
  fg3_made, fg2_made, fg3_att, fg2_att, ft_made, ft_att, assists, rebounds, blocks, fouls)
VALUES
  (39,510,2,6,5,12,5,6,7,5,0,2),
  (40,510,1,5,3,10,4,4,4,9,1,3),
  (37,510,1,7,4,13,3,4,3,10,1,4),
  (38,510,2,4,6,9, 2,2,5,4,0,2);

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (511,'2010-09-12T20:00:00','Istanbul','championship',NULL,NULL,101,'Final',1);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (511,1,'home',80),
  (511,3,'away',78);

INSERT OR IGNORE INTO PlayerGameStats(player_id, game_id,
  fg3_made, fg2_made, fg3_att, fg2_att, ft_made, ft_att, assists, rebounds, blocks, fouls)
VALUES
  (1,511,3,4,7,9, 4,5, 4,4,0,2),
  (30,511,2,5,6,10,6,7,6,6,0,2),
  (3,511,2,5,6,11,3,4,6,7,1,3),
  (34,511,3,4,8,9, 2,2,5,5,0,2);

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (512,'2014-09-14T20:00:00','Madrid','championship',NULL,NULL,102,'Final',1);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (512,3,'home',85),
  (512,2,'away',72);

INSERT OR IGNORE INTO PlayerGameStats(player_id, game_id,
  fg3_made, fg2_made, fg3_att, fg2_att, ft_made, ft_att, assists, rebounds, blocks, fouls)
VALUES
  (3,512,4,6,9,12,5,6,5,7,1,2),
  (34,512,2,5,6,9, 6,6,7,6,0,2),
  (2,512,2,5,6,10,4,5,4,5,0,3),
  (32,512,1,4,4,8, 3,3,3,7,1,2);

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (513,'2019-09-15T20:00:00','Madrid','championship',NULL,NULL,103,'Final',1);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (513,11,'home',79),
  (513,10,'away',74);

INSERT OR IGNORE INTO PlayerGameStats(player_id, game_id,
  fg3_made, fg2_made, fg3_att, fg2_att, ft_made, ft_att, assists, rebounds, blocks, fouls)
VALUES
  (37,513,1,8,4,14,4,6,6,11,1,3),
  (38,513,3,3,7,8, 2,2,7,5,0,2),
  (35,513,2,4,6,9, 3,3,5,4,0,2),
  (36,513,1,6,4,12,1,2,4,8,1,4);

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (520,'2018-05-20T20:30:00','Madrid','championship',NULL,NULL,200,'Final',1);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (520,4,'home',85),
  (520,22,'away',80);

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (521,'2019-05-19T20:30:00','Athens','championship',NULL,NULL,201,'Final',1);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (521,4,'home',90),
  (521,21,'away',83);

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (522,'2020-10-11T20:30:00','Istanbul','championship',NULL,NULL,202,'Final',1);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (522,4,'home',88),
  (522,20,'away',84);

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (523,'2021-05-30T20:30:00','Paris','championship',NULL,NULL,203,'Final',1);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (523,23,'home',82),
  (523,4,'away',79);

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (524,'2022-05-29T20:30:00','Madrid','championship',NULL,NULL,204,'Final',1);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (524,4,'home',86),
  (524,21,'away',81);

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (600,'2025-10-10T19:30:00','Madrid','league',1,1,NULL,'Regular',0);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (600,4,'home',92),
  (600,5,'away',88);

INSERT OR IGNORE INTO PlayerGameStats(player_id, game_id,
  fg3_made, fg2_made, fg3_att, fg2_att, ft_made, ft_att, assists, rebounds, blocks, fouls)
VALUES
  (1,600, 4,3, 8,7, 2,2, 7,6,0,2),   -- excellent 3P + assists
  (3,600, 1,4, 5,7, 1,2, 9,5,1,3),   -- beaucoup d'assists
  (4,600, 0,6, 2,10,0,0, 3,9,0,2),
  (30,600,2,4, 6,8, 4,4, 6,5,0,2),
  (2,600, 2,3, 6,6, 3,4, 5,4,0,3),
  (32,600,1,5, 3,9, 2,2, 2,8,1,2),
  (33,600,3,2, 7,5, 1,2, 4,3,0,1);

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (601,'2025-11-02T20:00:00','Madrid','league',1,1,NULL,'Regular',0);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (601,4,'home',89),
  (601,20,'away',86);

INSERT OR IGNORE INTO PlayerGameStats(player_id, game_id,
  fg3_made, fg2_made, fg3_att, fg2_att, ft_made, ft_att, assists, rebounds, blocks, fouls)
VALUES
  (1,601, 3,4, 7,9, 1,1, 8,5,0,2),
  (3,601, 2,3, 6,6, 4,4, 10,4,0,2),
  (30,601,4,2, 9,5, 2,2, 5,4,0,2),
  (31,601,2,5, 5,10,3,3, 7,6,0,3);

INSERT OR IGNORE INTO Game(game_id, date_time, location, competition_type,
                           league_season_id_league, league_season_id_season,
                           edition_id, stage, is_final)
VALUES
  (602,'2025-11-15T19:00:00','Istanbul','league',1,1,NULL,'Regular',0);

INSERT OR IGNORE INTO GameParticipant(game_id, team_id, role, score) VALUES
  (602,22,'home',84),
  (602,21,'away',80);

INSERT OR IGNORE INTO PlayerGameStats(player_id, game_id,
  fg3_made, fg2_made, fg3_att, fg2_att, ft_made, ft_att, assists, rebounds, blocks, fouls)
VALUES
  (35,602,3,3, 7,7, 2,2, 6,4,0,2),
  (36,602,1,6, 4,11,1,2, 8,8,1,3),
  (37,602,2,5, 6,10,3,4, 4,11,1,3),
  (38,602,4,2, 9,6, 0,0, 7,5,0,2);

COMMIT;

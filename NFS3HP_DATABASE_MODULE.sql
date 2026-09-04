-- HOSS NFS3: Hot Pursuit database module
-- MySQL 8.0+ / MariaDB 10.5+. Safe to run repeatedly.
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS NFS3_Classes (
  Class_ID TINYINT UNSIGNED PRIMARY KEY COMMENT 'HOSS lookup key; not a raw game-memory value',
  Class_Code VARCHAR(8) NOT NULL UNIQUE COMMENT 'Displayed vehicle class: A, B, C, or B*',
  Class_Name VARCHAR(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='NFS3 vehicle class lookup';

INSERT INTO NFS3_Classes (Class_ID, Class_Code, Class_Name) VALUES
  (1,'A','Class A'),(2,'B','Class B'),(3,'C','Class C'),(4,'B*','Class B (special)')
ON DUPLICATE KEY UPDATE Class_Code=VALUES(Class_Code), Class_Name=VALUES(Class_Name);

CREATE TABLE IF NOT EXISTS NFS3_Difficulties (
  Difficulty_ID TINYINT UNSIGNED PRIMARY KEY COMMENT 'Raw nfs3.exe value: 0 Beginner, 1 Expert',
  Difficulty_Name VARCHAR(32) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='NFS3 race difficulty lookup from nfs3.exe+2FD470';

INSERT INTO NFS3_Difficulties VALUES (0,'Beginner'),(1,'Expert')
ON DUPLICATE KEY UPDATE Difficulty_Name=VALUES(Difficulty_Name);

CREATE TABLE IF NOT EXISTS NFS3_Tracks (
  Track_ID TINYINT UNSIGNED PRIMARY KEY COMMENT 'Raw selected-track value from nfs3.exe+2FD4AC',
  Track_Name VARCHAR(64) NOT NULL UNIQUE,
  Enabled BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Nine confirmed NFS3 track identifiers';

INSERT INTO NFS3_Tracks (Track_ID,Track_Name) VALUES
  (0,'Hometown'),(1,'Redrock Ridge'),(2,'Atlantica'),(3,'Rocky Pass'),
  (4,'Country Woods'),(5,'Lost Canyons'),(6,'Aquatica'),(7,'Summit'),(8,'Empire City')
ON DUPLICATE KEY UPDATE Track_Name=VALUES(Track_Name);

CREATE TABLE IF NOT EXISTS NFS3_Cars (
  Car_ID TINYINT UNSIGNED PRIMARY KEY COMMENT 'Raw selected-car value from nfs3.exe+2FD2BC',
  Car_Code VARCHAR(8) NULL COMMENT 'Four-character result/installation vehicle code',
  Car_Name VARCHAR(80) NOT NULL,
  Class_Code VARCHAR(8) NULL,
  Car_Type VARCHAR(32) NOT NULL DEFAULT 'Normal' COMMENT 'Normal, add-on, special, regional, or pursuit/police classification',
  Enabled BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE KEY uq_nfs3_car_name (Car_Name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Confirmed NFS3 selectable cars and decoded result codes';

INSERT INTO NFS3_Cars (Car_ID,Car_Code,Car_Name,Class_Code,Car_Type) VALUES
 (0,'WALM','98 Indy 500 Pace Car','B','Special'),
 (1,'AMD7','Aston Martin DB7','C','Normal'),
 (2,'CORV','Chevrolet Corvette','B','Normal'),
 (3,'ELNI','El Niño','A','Bonus/Normal'),
 (4,'F355','Ferrari 355 F1 Spider','B','Normal'),
 (5,'456G','Ferrari 456M GT','B','Official EA add-on'),
 (6,'FM50','Ferrari 550 Maranello','A','Normal'),
 (7,'FFAL','Ford Falcon GT','C','Australian exclusive'),
 (8,'HGTS','HSV VT GTS','C','Australian exclusive'),
 (9,'SCIG','Italdesign Scighera','A','Normal'),
 (10,'JXJR','Jaguar XJR-15','A','Normal'),
 (11,'JXK8','Jaguar XK8','C','Normal'),
 (12,'JXKR','Jaguar XKR','C','Official EA add-on'),
 (13,'COUT','Lamborghini Countach','B','Normal'),
 (14,'DIAB','Lamborghini Diablo SV','A','Normal'),
 (15,'LSTM','Lister Storm','A','Official EA add-on'),
 (16,'MERC','Mercedes CLK-GTR','A','Normal'),
 (17,'SL60','Mercedes SL600','C','Normal'),
 (18,'SR42','Spectre R42','B*','Official EA add-on'),
 (19,'VCOP','Pursuit Corvette','B','Pursuit/police'),
 (20,'LCOP','Pursuit Diablo SV','A','Pursuit/police'),
 (21,'PELN','Pursuit El Niño','A','Pursuit/police')
ON DUPLICATE KEY UPDATE Car_Code=VALUES(Car_Code),Car_Name=VALUES(Car_Name),
 Class_Code=VALUES(Class_Code),Car_Type=VALUES(Car_Type);

CREATE TABLE IF NOT EXISTS NFS3_Race_Modes (
  Race_Mode_ID TINYINT UNSIGNED PRIMARY KEY COMMENT 'Raw value from nfs3.exe+2FD3B8',
  Race_Mode_Name VARCHAR(32) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='NFS3 race mode lookup: Single, Tournament, Knockout, Hot Pursuit';
INSERT INTO NFS3_Race_Modes VALUES (0,'Single Race'),(1,'Tournament'),(2,'Knockout'),(3,'Hot Pursuit')
ON DUPLICATE KEY UPDATE Race_Mode_Name=VALUES(Race_Mode_Name);

CREATE TABLE IF NOT EXISTS NFS3_Tournaments (
  Tournament_ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  Tournament_Name VARCHAR(100) NOT NULL,
  Difficulty_ID TINYINT UNSIGNED NOT NULL,
  Season_Year SMALLINT UNSIGNED NULL COMMENT 'Website season year; not read from game memory',
  Starts_At DATETIME NULL,
  Ends_At DATETIME NULL,
  Enabled BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE KEY uq_nfs3_tournament (Tournament_Name,Difficulty_ID,Season_Year),
  CONSTRAINT fk_nfs3_tournament_difficulty FOREIGN KEY (Difficulty_ID) REFERENCES NFS3_Difficulties(Difficulty_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Website tournament definitions; add rows only after official data is confirmed';

CREATE TABLE IF NOT EXISTS NFS3_Races (
  Race_ID BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  Captured_At DATETIME(6) NOT NULL COMMENT 'Scanner-local capture timestamp supplied by the ingest payload',
  Scanner_ID BIGINT UNSIGNED NULL COMMENT 'Future registered capture-tool identifier',
  Race_Mode_ID TINYINT UNSIGNED NOT NULL,
  Race_Mode_Mirror_ID TINYINT UNSIGNED NULL COMMENT 'Diagnostic mirror value from nfs3.exe+159260',
  Difficulty_ID TINYINT UNSIGNED NOT NULL,
  Tournament_ID INT UNSIGNED NULL,
  Track_ID TINYINT UNSIGNED NOT NULL,
  Laps TINYINT UNSIGNED NOT NULL,
  Direction ENUM('Forward','Backward') NOT NULL COMMENT 'Decoded sticky in-race direction: raw 7 forward or 5 backward',
  Mirrored BOOLEAN NOT NULL DEFAULT FALSE,
  Time_Of_Day ENUM('Day','Night') NOT NULL DEFAULT 'Day',
  Weather BOOLEAN NOT NULL DEFAULT FALSE,
  Traffic BOOLEAN NOT NULL DEFAULT TRUE,
  Collision_Setting VARCHAR(24) NULL,
  Damage_Setting VARCHAR(24) NULL,
  Braking_Assist BOOLEAN NULL, Collision_Recovery BOOLEAN NULL,
  Traction_Control BOOLEAN NULL, Transmission VARCHAR(16) NULL,
  Best_Line BOOLEAN NULL, Navigator BOOLEAN NULL,
  Assistance BOOLEAN NULL COMMENT 'True when braking, collision recovery, traction, best line, or navigator is enabled',
  Pursuit_Assistance BOOLEAN NULL,
  Selected_Car_ID TINYINT UNSIGNED NULL,
  Opponents VARCHAR(24) NULL, Opponent_Skill VARCHAR(24) NULL,
  Opponent_Car_ID TINYINT UNSIGNED NULL COMMENT 'Menu selector: 0 none, 1-3 class, 4-22 car',
  Opponent_Car_Mirror_ID TINYINT UNSIGNED NULL COMMENT 'Diagnostic mirror from nfs3.exe+15925C',
  Created_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY ix_nfs3_race_date (Captured_At), KEY ix_nfs3_race_track (Track_ID),
  CONSTRAINT fk_nfs3_race_mode FOREIGN KEY (Race_Mode_ID) REFERENCES NFS3_Race_Modes(Race_Mode_ID),
  CONSTRAINT fk_nfs3_race_difficulty FOREIGN KEY (Difficulty_ID) REFERENCES NFS3_Difficulties(Difficulty_ID),
  CONSTRAINT fk_nfs3_race_track FOREIGN KEY (Track_ID) REFERENCES NFS3_Tracks(Track_ID),
  CONSTRAINT fk_nfs3_race_tournament FOREIGN KEY (Tournament_ID) REFERENCES NFS3_Tournaments(Tournament_ID),
  CONSTRAINT fk_nfs3_race_car FOREIGN KEY (Selected_Car_ID) REFERENCES NFS3_Cars(Car_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='One NFS3 race and its configuration; participants are stored in NFS3_Results';

CREATE TABLE IF NOT EXISTS NFS3_Results (
  Result_ID BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  Race_ID BIGINT UNSIGNED NOT NULL,
  Player VARCHAR(80) NOT NULL,
  Participant_Slot TINYINT UNSIGNED NOT NULL COMMENT 'Roster/result slot 0-7; slot 0 is local in confirmed captures',
  Is_AI BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Scanner participant classification',
  Position TINYINT UNSIGNED NULL,
  Car_ID TINYINT UNSIGNED NULL,
  Car_Code VARCHAR(8) NULL, Car_Name VARCHAR(80) NULL,
  Class_Code VARCHAR(8) NULL, Result_Type VARCHAR(32) NULL,
  Total_Ticks INT UNSIGNED NULL COMMENT 'Native NFS3 race-time ticks; display time is derived',
  Lap1_Ticks INT UNSIGNED NULL, Lap2_Ticks INT UNSIGNED NULL,
  Lap3_Ticks INT UNSIGNED NULL, Lap4_Ticks INT UNSIGNED NULL,
  Lap5_Ticks INT UNSIGNED NULL, Lap6_Ticks INT UNSIGNED NULL,
  Lap7_Ticks INT UNSIGNED NULL, Lap8_Ticks INT UNSIGNED NULL,
  Lap1_Top_Speed_MPH DECIMAL(7,2) NULL, Lap2_Top_Speed_MPH DECIMAL(7,2) NULL,
  Lap3_Top_Speed_MPH DECIMAL(7,2) NULL, Lap4_Top_Speed_MPH DECIMAL(7,2) NULL,
  Lap5_Top_Speed_MPH DECIMAL(7,2) NULL, Lap6_Top_Speed_MPH DECIMAL(7,2) NULL,
  Lap7_Top_Speed_MPH DECIMAL(7,2) NULL, Lap8_Top_Speed_MPH DECIMAL(7,2) NULL,
  Top_Speed_MPH DECIMAL(7,2) NULL COMMENT 'Maximum populated per-lap top speed',
  Tickets_Received SMALLINT UNSIGNED NULL COMMENT 'Counter at 0x005E13E8 + slot*0x9AC',
  Tickets_Issued SMALLINT UNSIGNED NULL COMMENT 'Adjacent counter at tickets-received address +4',
  Created_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_nfs3_race_slot (Race_ID,Participant_Slot),
  KEY ix_nfs3_result_player (Player), KEY ix_nfs3_result_position (Position),
  CONSTRAINT fk_nfs3_result_race FOREIGN KEY (Race_ID) REFERENCES NFS3_Races(Race_ID) ON DELETE CASCADE,
  CONSTRAINT fk_nfs3_result_car FOREIGN KEY (Car_ID) REFERENCES NFS3_Cars(Car_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='One participant per race; fixed lap columns mirror the scanner CSV';

CREATE TABLE IF NOT EXISTS NFS3_Annual_Ratings (
  Rating_Year SMALLINT UNSIGNED NOT NULL COMMENT 'Calendar or competition year used by HOSS',
  Player VARCHAR(80) NOT NULL,
  Races INT UNSIGNED NOT NULL DEFAULT 0,
  Wins INT UNSIGNED NOT NULL DEFAULT 0,
  Podiums INT UNSIGNED NOT NULL DEFAULT 0,
  Points INT NOT NULL DEFAULT 0,
  Tickets_Received INT UNSIGNED NOT NULL DEFAULT 0,
  Tickets_Issued INT UNSIGNED NOT NULL DEFAULT 0,
  Best_Rating DECIMAL(10,3) NULL COMMENT 'Website-computed rating; no formula is inferred by the scanner',
  Updated_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (Rating_Year,Player), KEY ix_nfs3_rating_points (Rating_Year,Points)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Rebuildable aggregate; NFS3_Results remains the source of truth';

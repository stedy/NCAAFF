CREATE TABLE allconf
( row_names TEXT,
	X TEXT,
	school TEXT,
	conference TEXT,
	picker TEXT,
	NA_ TEXT,
	conf TEXT,
	overall TEXT,
	confwins TEXT,
	confloss TEXT,
	confpercent TEXT,
	points TEXT,
	X_1 TEXT
);
CREATE TABLE allscores (Away text, Home text,				
  Away_score int, Home_score int, Gameday date);
CREATE TABLE indivpicks 
( row_names TEXT,
	conf TEXT,
	team TEXT,
	picker TEXT 
);
CREATE TABLE picks (Conf text, Team text, 				i
  Picker text);
CREATE TABLE standings
( row_names TEXT,
	picker TEXT,
	score REAL 
);
CREATE TABLE standingsplot
( row_names TEXT,
	picker TEXT,
	score REAL,
	"date" INTEGER
);

CREATE TABLE raw_conference (Team text, allstandings text, confstandings text);

CREATE DATABASE MoviesApp; 

USE MoviesApp;

CREATE TABLE Directors (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Surname NVARCHAR(100)
);

CREATE TABLE Movies (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Description NVARCHAR(MAX),
    CoverPhoto NVARCHAR(255),
    LanguageId INT,
    FOREIGN KEY (LanguageId) REFERENCES Languages(Id)
);

CREATE TABLE Actors (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Surname NVARCHAR(100)
);

CREATE TABLE Genres (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100)
);

CREATE TABLE Languages (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100)
);

CREATE TABLE MovieActors (
    MovieId INT,
    ActorId INT,
    PRIMARY KEY (MovieId, ActorId),
    FOREIGN KEY (MovieId) REFERENCES Movies(Id),
    FOREIGN KEY (ActorId) REFERENCES Actors(Id)
);

CREATE TABLE MovieGenres (
    MovieId INT,
    GenreId INT,
    PRIMARY KEY (MovieId, GenreId),
    FOREIGN KEY (MovieId) REFERENCES Movies(Id),
    FOREIGN KEY (GenreId) REFERENCES Genres(Id)
);

INSERT INTO Directors (Name, Surname) VALUES ('Christopher', 'Nolan');
INSERT INTO Directors (Name, Surname) VALUES ('Steven', 'Spielberg');

INSERT INTO Languages (Name) VALUES ('English');
INSERT INTO Languages (Name) VALUES ('Spanish');

INSERT INTO Genres (Name) VALUES ('Action');
INSERT INTO Genres (Name) VALUES ('Drama');

INSERT INTO Movies (Name, Description, CoverPhoto, LanguageId) VALUES ('Inception', 'A mind-bending thriller', 'cover1.jpg', 1);
INSERT INTO Movies (Name, Description, CoverPhoto, LanguageId) VALUES ('Jurassic Park', 'Dinosaurs brought to life', 'cover2.jpg', 1);

INSERT INTO Actors (Name, Surname) VALUES ('Leonardo', 'DiCaprio');
INSERT INTO Actors (Name, Surname) VALUES ('Sam', 'Neill');

INSERT INTO MovieActors (MovieId, ActorId) VALUES (1, 1);
INSERT INTO MovieActors (MovieId, ActorId) VALUES (2, 2);

INSERT INTO MovieGenres (MovieId, GenreId) VALUES (1, 1);
INSERT INTO MovieGenres (MovieId, GenreId) VALUES (2, 1);
INSERT INTO MovieGenres (MovieId, GenreId) VALUES (2, 2);


CREATE PROCEDURE GetDirectorMoviesLanguage @directorId INT
AS
BEGIN
    SELECT m.Name AS MovieName, l.Name AS Language
    FROM Movies m
    JOIN MovieGenres mg ON m.Id = mg.MovieId
    JOIN Genres g ON mg.GenreId = g.Id
    JOIN Languages l ON m.LanguageId = l.Id
    WHERE m.Id IN (
        SELECT m.Id
        FROM Movies m
        JOIN Directors d ON m.Id = d.Id
        WHERE d.Id = @directorId
    );
END;




CREATE FUNCTION GetFilmCountByLanguage(@languageId INT)
RETURNS INT
AS
BEGIN
    DECLARE @filmCount INT;
    SELECT @filmCount = COUNT(*)
    FROM Movies
    WHERE LanguageId = @languageId;
    RETURN @filmCount;
END;

SELECT GetFilmCountByLanguage(1) AS FilmCount;  



CREATE PROCEDURE GetMoviesByGenreAndDirector @genreId INT
AS
BEGIN
    SELECT m.Name AS MovieName, d.Name AS DirectorName, d.Surname AS DirectorSurname
    FROM Movies m
    JOIN MovieGenres mg ON m.Id = mg.MovieId
    JOIN Genres g ON mg.GenreId = g.Id
    JOIN Directors d ON m.Id = d.Id
    WHERE g.Id = @genreId;
END;


CREATE FUNCTION ActorFilmCountCheck (@actorId INT)
RETURNS BIT
AS
BEGIN
    DECLARE @movieCount INT;
    SELECT @movieCount = COUNT(*)
    FROM MovieActors
    WHERE ActorId = @actorId;
    IF @movieCount > 3
        RETURN 1;
    ELSE
        RETURN 0;
END;


CREATE TRIGGER AfterInsertOnMovies
ON Movies
AFTER INSERT
AS
BEGIN
    SELECT m.Id, m.Name AS MovieName, d.Name AS DirectorName, d.Surname AS DirectorSurname, l.Name AS Language
    FROM Movies m
    JOIN Languages l ON m.LanguageId = l.Id
    LEFT JOIN Directors d ON m.Id = d.Id;
END;

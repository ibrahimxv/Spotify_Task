CREATE DATABASE SPOTIFYTASK

USE SPOTIFYTASK

CREATE TABLE users(
	id INT PRIMARY KEY IDENTITY,
	name NVARCHAR(50) NOT NULL,
	surname NVARCHAR (50) NOT NULL,
	username VARCHAR (30) NOT NULL UNIQUE,
	password VARCHAR (100) NOT NULL CHECK (LEN (password) >= 8),
	gender VARCHAR (20) NOT NULL CHECK (gender IN ('male', 'female', 'other'))
)

CREATE TABLE artists(
    id INT PRIMARY KEY IDENTITY,
	name NVARCHAR(50) NOT NULL,
	surname NVARCHAR (50) NOT NULL,
	birthday DATE NOT NULL,
	gender VARCHAR (20) NOT NULL CHECK (gender IN ('male', 'female', 'other'))
)

CREATE TABLE categories(
	id INT PRIMARY KEY IDENTITY,
	name VARCHAR (50) NOT NULL
)

CREATE TABLE musics(
	id INT PRIMARY KEY IDENTITY,
	name VARCHAR (100) NOT NULL,
	duration INT NOT NULL,

	category_id INT REFERENCES categories(id)
)

CREATE TABLE playlist(
	music_id INT REFERENCES musics(id),
	user_id INT REFERENCES users(id),

	PRIMARY KEY (music_id, user_id)
)

CREATE TABLE artists_music(
	artist_id INT REFERENCES artists(id),
	music_id INT REFERENCES musics(id),

	PRIMARY KEY (artist_id, music_id)
)

--1--
CREATE VIEW music_details
AS
SELECT
	musics.name AS Name,
	musics.duration AS Duration,
	categories.name AS CategoryName,
	CONCAT(artists.name,' ',artists.surname) AS ArtistName
FROM musics
JOIN categories
	ON musics.category_id = categories.id
JOIN artists_music	
	ON musics.id = artists_music.music_id
JOIN artists
	ON artists_music.artist_id = artists.id

SELECT * FROM music_details


--2--
SELECT TOP 1 WITH TIES
	artists.id AS Id,
	artists.name AS Name,
	artists.surname AS Surname,
	COUNT (artists_music.music_id) AS MusicCount
FROM artists 
JOIN artists_music 
	ON artists_music.artist_id = artist_id
GROUP BY artists.id, artists.name, artists.surname
ORDER BY COUNT (artists_music.music_id) DESC


--3--
CREATE PROCEDURE get_user_playlist
	@UserId INT
AS
BEGIN
	SELECT
		musics.id,
		musics.name,
		musics.duration
	FROM playlist
	JOIN musics
		ON playlist.music_id = musics.id
	WHERE playlist.user_id = @UserId
END

EXEC get_user_playlist 3


--4--
CREATE PROCEDURE usp_CreateMusic
	@Name VARCHAR(100),
	@Duration INT,
	@CategoryId INT
AS
BEGIN
	INSERT INTO musics (name, duration, category_id)
	VALUES (@Name, @Duration, @CategoryId)
END

EXEC usp_CreateMusic
	'Something in the Way',
	232,
	1

------------------------------
CREATE PROCEDURE usp_CreateUser
	@Name NVARCHAR(50),
	@Surname NVARCHAR (50),
	@Username VARCHAR (30),
	@Password VARCHAR (100),
	@Gender VARCHAR (20)
AS
BEGIN
	INSERT INTO users (name, surname, username, password, gender)
	VALUES (@Name, @Surname, @Username, @Password, @Gender)
END

EXEC usp_CreateUser
	'Merdan',
	'Memmedov',
	'mardan_m',
	'mardan123',
	'Male'


------------------------------
CREATE PROCEDURE usp_CreateCategory
	@Name VARCHAR (50)
AS
BEGIN
	INSERT INTO categories (name)
	VALUES (@Name)
END

EXEC usp_CreateCategory
	'Jazz'

--5--
CREATE FUNCTION get_user_artists_count
(
	@UserId INT
)
RETURNS INT
AS
BEGIN
	DECLARE @ArtistCount INT

	SELECT @ArtistCount = COUNT (DISTINCT artists_music.artist_id)
	FROM playlist
	JOIN artists_music
		ON playlist.music_id = artists_music.artist_id
	WHERE playlist.user_id = @UserId

	RETURN @ArtistCount
END

SELECT dbo.get_user_artists_count(1) AS ArtistCount

--6--
ALTER TABLE users
ADD is_deleted BIT NOT NULL DEFAULT 0

CREATE TRIGGER tr_Users_SoftDelete
ON users
INSTEAD OF DELETE
AS
BEGIN
    UPDATE users
    SET is_deleted = 1
    WHERE id IN (SELECT id FROM deleted)
END

DELETE FROM users WHERE id = 5

SELECT * FROM users

SELECT * FROM users WHERE is_deleted = 0
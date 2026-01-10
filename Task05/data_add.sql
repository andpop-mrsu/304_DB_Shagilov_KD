-- Добавляем 5 пользователей (тебя и 4 других)
INSERT INTO users (name, email, gender, occupation) VALUES
('Shagil Kirillov', 'shagil.kirillov@example.com', 'male', 'student'),
('Ivan Ivanov', 'ivan@example.com', 'male', 'student'),
('Maria Petrova', 'maria@example.com', 'female', 'student'),
('Alexey Smirnov', 'alexey@example.com', 'male', 'student'),
('Elena Kuznetsova', 'elena@example.com', 'female', 'student');

-- Добавляем 3 фильма
INSERT INTO movies (title, year) VALUES
('Inception 2', 2026),
('The Matrix 5', 2027),
('Interstellar 2', 2028);

-- Убеждаемся, что нужные жанры существуют
INSERT OR IGNORE INTO genres (name) VALUES ('Sci-Fi'), ('Action'), ('Drama');

-- Привязываем жанры к фильмам
INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m, genres g
WHERE m.title = 'Inception 2' AND g.name = 'Sci-Fi';

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m, genres g
WHERE m.title = 'The Matrix 5' AND g.name = 'Action';

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m, genres g
WHERE m.title = 'Interstellar 2' AND g.name = 'Drama';

-- Добавляем 3 отзыва от тебя (Shagil Kirillov)
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 5.0, strftime('%s', 'now')
FROM users u, movies m
WHERE u.email = 'shagil.kirillov@example.com' AND m.title = 'Inception 2';

INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 4.5, strftime('%s', 'now')
FROM users u, movies m
WHERE u.email = 'shagil.kirillov@example.com' AND m.title = 'The Matrix 5';

INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 4.0, strftime('%s', 'now')
FROM users u, movies m
WHERE u.email = 'shagil.kirillov@example.com' AND m.title = 'Interstellar 2';

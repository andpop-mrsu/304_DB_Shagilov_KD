PRAGMA foreign_keys = ON;

-- Таблица жанров (справочник)
CREATE TABLE genres (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- Пользователи
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    gender TEXT CHECK(gender IN ('male', 'female')),
    occupation TEXT,
    register_date DATE DEFAULT (date('now'))
);

-- Фильмы
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    year INTEGER
);

-- Связь фильмов и жанров (многие-ко-многим)
CREATE TABLE movie_genres (
    movie_id INTEGER,
    genre_id INTEGER,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
);

-- Оценки
CREATE TABLE ratings (
    user_id INTEGER,
    movie_id INTEGER,
    rating REAL CHECK(rating BETWEEN 0 AND 5),
    timestamp INTEGER,
    PRIMARY KEY (user_id, movie_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE RESTRICT
);

-- Теги
CREATE TABLE tags (
    user_id INTEGER,
    movie_id INTEGER,
    tag TEXT,
    timestamp INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

-- Индексы для быстрого поиска
CREATE INDEX idx_users_lastname ON users(name);
CREATE INDEX idx_movies_title_year ON movies(title, year);

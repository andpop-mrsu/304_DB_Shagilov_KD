#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < Task04/db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они ценили. В списке оставить первые 100 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
SELECT u1.name, u2.name, m.title
FROM ratings r1
JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id
JOIN users u1 ON r1.user_id = u1.id
JOIN users u2 ON r2.user_id = u2.id
JOIN movies m ON r1.movie_id = m.id
LIMIT 100;
"
echo " "

echo "2. Найти 10 самых старых оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
WITH ranked AS (
    SELECT u.name, m.title, r.rating, date(r.timestamp, 'unixepoch') AS dt, r.timestamp,
           ROW_NUMBER() OVER (PARTITION BY r.user_id ORDER BY r.timestamp) AS rn
    FROM ratings r
    JOIN users u ON r.user_id = u.id
    JOIN movies m ON r.movie_id = m.id
)
SELECT title, name, rating, dt
FROM ranked
WHERE rn = 1
ORDER BY timestamp
LIMIT 10;
"
echo " "

echo "3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке \"Рекомендуем\" для фильмов должно быть написано \"Да\" или \"Нет\"."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
WITH avg_ratings AS (
    SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_r
    FROM movies m
    JOIN ratings r ON m.id = r.movie_id
    GROUP BY m.id
),
extremes AS (
    SELECT MAX(avg_r) AS max_avg, MIN(avg_r) AS min_avg
    FROM avg_ratings
)
SELECT title, year,
       CASE WHEN avg_r = (SELECT max_avg FROM extremes) THEN 'Да' ELSE 'Нет' END AS \"Рекомендуем\"
FROM avg_ratings, extremes
WHERE avg_r IN (max_avg, min_avg)
ORDER BY year, title;
"
echo " "

echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-мужчины в период с 2011 по 2014 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
SELECT COUNT(*) AS cnt, ROUND(AVG(r.rating), 2) AS avg_rating
FROM ratings r
JOIN users u ON r.user_id = u.id
WHERE u.gender = 'male'
  AND date(r.timestamp, 'unixepoch') BETWEEN '2011-01-01' AND '2014-12-31';
"
echo " "

echo "5. Составить список фильмов с указанием средней оценки и количества пользователей, которые их оценили. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
SELECT m.title, m.year, ROUND(AVG(r.rating), 2) AS avg_rating, COUNT(r.id) AS num_ratings
FROM movies m
JOIN ratings r ON m.id = r.movie_id
GROUP BY m.id
ORDER BY m.year, m.title
LIMIT 20;
"
echo " "

echo "6. Определить самый распространенный жанр фильма и количество фильмов в этом жанре. Отдельную таблицу для жанров не использовать, жанры нужно извлекать из таблицы movies."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
WITH split_genres AS (
    SELECT trim(substr(genres, 1, instr(genres || '|', '|') - 1)) AS genre
    FROM movies
    WHERE genres != '(no genres listed)'
    UNION ALL
    SELECT trim(substr(genres, instr(genres || '|', '|') + 1))
    FROM movies
    WHERE genres != '(no genres listed)' AND instr(genres, '|') > 0
)
SELECT genre, COUNT(*) AS cnt
FROM split_genres
GROUP BY genre
ORDER BY cnt DESC
LIMIT 1;
"
echo " "

echo "7. Вывести список из 10 последних зарегистрированных пользователей в формате \"Фамилия Имя|Дата регистрации\" (сначала фамилия, потом имя)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
SELECT 
    CASE 
        WHEN instr(name, ' ') > 0 THEN 
            substr(name, instr(name, ' ') + 1) || ' ' || substr(name, 1, instr(name, ' ') - 1)
        ELSE name
    END || '|' || register_date AS \"Фамилия Имя|Дата регистрации\"
FROM users
ORDER BY register_date DESC
LIMIT 10;
"
echo " "

echo "8. С помощью рекурсивного CTE определить, на какие дни недели приходился ваш день рождения в каждом году."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "
WITH RECURSIVE years(y) AS (
    VALUES(2010)
    UNION ALL
    SELECT y + 1 FROM years WHERE y < 2025
)
SELECT y AS year,
       CASE strftime('%w', y || '-09-25')
         WHEN '0' THEN 'Воскресенье'
         WHEN '1' THEN 'Понедельник'
         WHEN '2' THEN 'Вторник'
         WHEN '3' THEN 'Среда'
         WHEN '4' THEN 'Четверг'
         WHEN '5' THEN 'Пятница'
         WHEN '6' THEN 'Суббота'
       END AS weekday
FROM years;
"
echo " "

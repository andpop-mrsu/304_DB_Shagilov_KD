import csv
import re

def escape_sql(s):
    return s.replace("'", "''") if s else ''

with open("db_init.sql", "w", encoding="utf-8") as f:
    # Удаление таблиц
    for t in ["movies", "ratings", "tags", "users"]:
        f.write(f"DROP TABLE IF EXISTS {t};\n")
    f.write("\n")

    # --- MOVIES ---
    f.write("""CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT,
    year INTEGER,
    genres TEXT
);\n\n""")
    with open("dataset/movies.csv", "r", encoding="utf-8") as cf:
        reader = csv.reader(cf)
        next(reader)
        for row in reader:
            movie_id, title_raw, genres = row
            m = re.search(r'\((\d{4})\)\s*$', title_raw)
            if m:
                year = m.group(1)
                title = title_raw[:m.start()].rstrip()
            else:
                year = "NULL"
                title = title_raw
            f.write(f"INSERT INTO movies VALUES ({movie_id}, '{escape_sql(title)}', {year}, '{escape_sql(genres)}');\n")
    f.write("\n")

    # --- RATINGS ---
    f.write("""CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    rating REAL,
    timestamp INTEGER
);\n\n""")
    rid = 1
    with open("dataset/ratings.csv", "r", encoding="utf-8") as cf:
        reader = csv.reader(cf)
        next(reader)
        for row in reader:
            uid, mid, r, ts = row
            f.write(f"INSERT INTO ratings VALUES ({rid}, {uid}, {mid}, {r}, {ts});\n")
            rid += 1
    f.write("\n")

    # --- TAGS ---
    f.write("""CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    tag TEXT,
    timestamp INTEGER
);\n\n""")
    tid = 1
    with open("dataset/tags.csv", "r", encoding="utf-8") as cf:
        reader = csv.reader(cf)
        next(reader)
        for row in reader:
            uid, mid, tag, ts = row
            f.write(f"INSERT INTO tags VALUES ({tid}, {uid}, {mid}, '{escape_sql(tag)}', {ts});\n")
            tid += 1
    f.write("\n")

    # --- USERS ---
    f.write("""CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT,
    gender TEXT,
    register_date TEXT,
    occupation TEXT
);\n\n""")
    with open("dataset/users.csv", "r", encoding="utf-8") as cf:
        reader = csv.reader(cf, delimiter='|')
        for row in reader:
            uid, name, email, gender, reg_date, occ = row
            f.write(f"INSERT INTO users VALUES ({uid}, '{escape_sql(name)}', '{escape_sql(email)}', '{gender}', '{reg_date}', '{escape_sql(occ)}');\n")

print("✅ db_init.sql создан")

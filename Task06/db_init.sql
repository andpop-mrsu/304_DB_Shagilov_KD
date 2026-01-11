PRAGMA foreign_keys = ON;

-- 1. Справочник категорий услуг (по спецификации: имплантация, терапевтическая и т.д.)
CREATE TABLE service_categories (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- 2. Справочник специализаций врачей
CREATE TABLE specializations (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- 3. Врачи (с датой увольнения для сохранения истории)
CREATE TABLE doctors (
    id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    hire_date DATE NOT NULL,
    fire_date DATE,                          -- NULL = работает сейчас
    salary_percent REAL NOT NULL CHECK(salary_percent BETWEEN 0 AND 100)
);

-- 4. Связь многие-ко-многим: врачи ↔ специализации
CREATE TABLE doctor_specializations (
    doctor_id INTEGER,
    specialization_id INTEGER,
    PRIMARY KEY (doctor_id, specialization_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    FOREIGN KEY (specialization_id) REFERENCES specializations(id) ON DELETE CASCADE
);

-- 5. Услуги (привязаны к категории и специализации)
CREATE TABLE services (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK(duration_minutes > 0),
    price REAL NOT NULL CHECK(price >= 0),
    category_id INTEGER NOT NULL,
    specialization_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES service_categories(id) ON DELETE RESTRICT,
    FOREIGN KEY (specialization_id) REFERENCES specializations(id) ON DELETE RESTRICT
);

-- 6. Записи на приём + учёт выполнения для расчёта ЗП
CREATE TABLE appointments (
    id INTEGER PRIMARY KEY,
    patient_name TEXT NOT NULL,
    patient_phone TEXT NOT NULL,
    doctor_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    appointment_time DATETIME NOT NULL,
    status TEXT CHECK(status IN ('planned', 'completed', 'cancelled')) DEFAULT 'planned',
    performed BOOLEAN DEFAULT FALSE,               -- выполнена ли процедура
    actual_price REAL,                             -- фактическая стоимость (для расчёта ЗП)
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT,
    UNIQUE (doctor_id, appointment_time)           -- один приём у врача в одно время
);

-- Тестовые данные

INSERT INTO service_categories (id, name) VALUES
(1, 'Терапевтическая стоматология'),
(2, 'Хирургическая стоматология'),
(3, 'Ортодонтия');

INSERT INTO specializations (id, name) VALUES
(1, 'Терапевт'),
(2, 'Хирург'),
(3, 'Ортодонт');

INSERT INTO doctors (id, full_name, hire_date, fire_date, salary_percent) VALUES
(1, 'Иванов Иван Иванович', '2020-01-15', NULL, 30.0),
(2, 'Петрова Анна Сергеевна', '2019-03-10', '2025-06-01', 25.0);

INSERT INTO doctor_specializations (doctor_id, specialization_id) VALUES
(1, 1), (1, 2),
(2, 1);

INSERT INTO services (id, name, duration_minutes, price, category_id, specialization_id) VALUES
(1, 'Лечение кариеса',          40, 2500.0, 1, 1),
(2, 'Удаление зуба',            30, 3000.0, 2, 2),
(3, 'Установка брекетов',       60, 25000.0, 3, 3);

INSERT INTO appointments (patient_name, patient_phone, doctor_id, service_id, appointment_time, status, performed, actual_price) VALUES
('Сидоров Алексей',   '+79001234567', 1, 1, '2026-01-15 10:00:00', 'completed', TRUE,  2500.0),
('Кузнецова Мария',   '+79009876543', 2, 1, '2025-05-20 14:30:00', 'completed', TRUE,  2500.0),
('Смирнов Дмитрий',   '+79001112233', 1, 2, '2026-01-20 11:00:00', 'planned',  FALSE, NULL);

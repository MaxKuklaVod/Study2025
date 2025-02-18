-- Создание схемы "Maximiliano", если она не существует
CREATE SCHEMA IF NOT EXISTS "Maximiliano";

-- ==============================
-- Создание справочника должностей
-- ==============================
CREATE TABLE IF NOT EXISTS "Maximiliano".military_ranks (
    id SERIAL PRIMARY KEY, -- Используем SERIAL для автоматической генерации ID
    description VARCHAR(255) NOT NULL -- Описание должности
);

-- Заполнение начальными данными
INSERT INTO "Maximiliano".military_ranks (id, description)
VALUES 
    (1, 'Рядовой'),
    (2, 'Лейтенант');

-- Проверка содержимого таблицы
SELECT * FROM "Maximiliano".military_ranks;

-- ==============================
-- Создание таблицы сотрудников
-- ==============================
CREATE TABLE IF NOT EXISTS "Maximiliano".employees (
    id SERIAL PRIMARY KEY, -- Используем SERIAL для автоматической генерации ID
    name TEXT NOT NULL, -- ФИО сотрудника
    birthday DATE, -- Дата рождения
    military_rank_id INTEGER REFERENCES "Maximiliano".military_ranks(id) -- Связь с таблицей должностей
);

-- Заполнение начальными данными
INSERT INTO "Maximiliano".employees (id, name, birthday, military_rank_id)
VALUES 
    (1, 'Воловиков Александр Сергеевич', '1978-06-24', 2);

-- Проверка содержимого таблицы
SELECT * FROM "Maximiliano".employees;

-- ==============================
-- Создание справочника типов измерительных устройств
-- ==============================
CREATE TABLE IF NOT EXISTS "Maximiliano".measurment_types (
    id SERIAL PRIMARY KEY, -- Используем SERIAL для автоматической генерации ID
    short_name VARCHAR(50) NOT NULL, -- Краткое название устройства
    description TEXT -- Полное описание устройства
);

-- Заполнение начальными данными
INSERT INTO "Maximiliano".measurment_types (id, short_name, description)
VALUES 
    (1, 'ДМК', 'Десантный метео комплекс'),
    (2, 'ВР', 'Ветровое ружье');

-- Проверка содержимого таблицы
SELECT * FROM "Maximiliano".measurment_types;

-- ==============================
-- Создание таблицы параметров измерений
-- ==============================
CREATE TABLE IF NOT EXISTS "Maximiliano".measurment_input_params (
    id SERIAL PRIMARY KEY, -- Используем SERIAL для автоматической генерации ID
    measurment_type_id INTEGER NOT NULL REFERENCES "Maximiliano".measurment_types(id), -- Связь с типами устройств
    height NUMERIC(8, 2) DEFAULT 0, -- Высота
    temperature NUMERIC(8, 2) DEFAULT 0, -- Температура
    pressure NUMERIC(8, 2) DEFAULT 0, -- Давление
    wind_direction NUMERIC(8, 2) DEFAULT 0, -- Направление ветра
    wind_speed NUMERIC(8, 2) DEFAULT 0 -- Скорость ветра
);

-- Заполнение начальными данными
INSERT INTO "Maximiliano".measurment_input_params (id, measurment_type_id, height, temperature, pressure, wind_direction, wind_speed)
VALUES 
    (1, 1, 100, 12, 34, 0.2, 45);

-- Проверка содержимого таблицы
SELECT * FROM "Maximiliano".measurment_input_params;

-- ==============================
-- Создание таблицы истории измерений
-- ==============================
CREATE TABLE IF NOT EXISTS "Maximiliano".measurment_baths (
    id SERIAL PRIMARY KEY, -- Используем SERIAL для автоматической генерации ID
    emploee_id INTEGER NOT NULL REFERENCES "Maximiliano".employees(id), -- Связь с сотрудниками
    measurment_input_param_id INTEGER NOT NULL REFERENCES "Maximiliano".measurment_input_params(id), -- Связь с параметрами измерений
    started TIMESTAMP DEFAULT NOW() -- Время начала измерения
);

-- Заполнение начальными данными
INSERT INTO "Maximiliano".measurment_baths (id, emploee_id, measurment_input_param_id)
VALUES 
    (1, 1, 1);

-- Проверка содержимого таблицы
SELECT * FROM "Maximiliano".measurment_baths;

-- ==============================
-- Готово!
-- ==============================
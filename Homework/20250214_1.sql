-- ==============================
-- 1. Создание схемы "Maximiliano"
-- ==============================
CREATE SCHEMA IF NOT EXISTS "Maximiliano";

-- ==============================
-- 2. Справочник должностей
-- ==============================
CREATE TABLE IF NOT EXISTS "Maximiliano".military_ranks
(
    id INTEGER PRIMARY KEY NOT NULL,
    description CHARACTER VARYING(255)
);

-- Создание последовательности для автоматической генерации ID
CREATE SEQUENCE IF NOT EXISTS "Maximiliano".military_ranks_seq START 3;
ALTER TABLE "Maximiliano".military_ranks ALTER COLUMN id SET DEFAULT nextval('"Maximiliano".military_ranks_seq');

-- Заполнение начальными данными
INSERT INTO "Maximiliano".military_ranks(id, description)
VALUES (1, 'Рядовой'), (2, 'Лейтенант')
ON CONFLICT (id) DO NOTHING;

-- ==============================
-- 3. Таблица сотрудников
-- ==============================
CREATE TABLE IF NOT EXISTS "Maximiliano".employees
(
    id INTEGER PRIMARY KEY NOT NULL,
    name TEXT,
    birthday TIMESTAMP,
    military_rank_id INTEGER
);

-- Создание последовательности для автоматической генерации ID
CREATE SEQUENCE IF NOT EXISTS "Maximiliano".employees_seq START 2;
ALTER TABLE "Maximiliano".employees ALTER COLUMN id SET DEFAULT nextval('"Maximiliano".employees_seq');

-- Заполнение начальными данными
INSERT INTO "Maximiliano".employees(id, name, birthday, military_rank_id)
VALUES (1, 'Воловиков Александр Сергеевич', '1978-06-24', 2)
ON CONFLICT (id) DO NOTHING;

-- ==============================
-- 4. Устройства для измерения
-- ==============================
CREATE TABLE IF NOT EXISTS "Maximiliano".measurment_types
(
    id INTEGER PRIMARY KEY NOT NULL,
    short_name CHARACTER VARYING(50),
    description TEXT
);

-- Создание последовательности для автоматической генерации ID
CREATE SEQUENCE IF NOT EXISTS "Maximiliano".measurment_types_seq START 3;
ALTER TABLE "Maximiliano".measurment_types ALTER COLUMN id SET DEFAULT nextval('"Maximiliano".measurment_types_seq');

-- Заполнение начальными данными
INSERT INTO "Maximiliano".measurment_types(id, short_name, description)
VALUES (1, 'ДМК', 'Десантный метео комплекс'), (2, 'ВР', 'Ветровое ружье')
ON CONFLICT (id) DO NOTHING;

-- ==============================
-- 5. Таблица с параметрами
-- ==============================
CREATE TABLE IF NOT EXISTS "Maximiliano".measurment_input_params
(
    id INTEGER PRIMARY KEY NOT NULL,
    measurment_type_id INTEGER NOT NULL,
    height NUMERIC(8, 2) DEFAULT 0,
    temperature NUMERIC(8, 2) DEFAULT 0,
    pressure NUMERIC(8, 2) DEFAULT 0,
    wind_direction NUMERIC(8, 2) DEFAULT 0,
    wind_speed NUMERIC(8, 2) DEFAULT 0
);

-- Создание последовательности для автоматической генерации ID
CREATE SEQUENCE IF NOT EXISTS "Maximiliano".measurment_input_params_seq START 2;
ALTER TABLE "Maximiliano".measurment_input_params ALTER COLUMN id SET DEFAULT nextval('"Maximiliano".measurment_input_params_seq');

-- Заполнение начальными данными
INSERT INTO "Maximiliano".measurment_input_params(id, measurment_type_id, height, temperature, pressure, wind_direction, wind_speed)
VALUES (1, 1, 100, 12, 34, 0.2, 45)
ON CONFLICT (id) DO NOTHING;

-- ==============================
-- 6. Таблица с историей
-- ==============================
CREATE TABLE IF NOT EXISTS "Maximiliano".measurment_baths
(
    id INTEGER PRIMARY KEY NOT NULL,
    emploee_id INTEGER NOT NULL,
    measurment_input_param_id INTEGER NOT NULL,
    started TIMESTAMP DEFAULT NOW()
);

-- Создание последовательности для автоматической генерации ID
CREATE SEQUENCE IF NOT EXISTS "Maximiliano".measurment_baths_seq START 2;
ALTER TABLE "Maximiliano".measurment_baths ALTER COLUMN id SET DEFAULT nextval('"Maximiliano".measurment_baths_seq');

-- Заполнение начальными данными
INSERT INTO "Maximiliano".measurment_baths(id, emploee_id, measurment_input_param_id)
VALUES (1, 1, 1)
ON CONFLICT (id) DO NOTHING;

-- ==============================
-- 7. Расчетные структуры
-- ==============================
DROP TABLE IF EXISTS "Maximiliano".calc_temperatures_correction;
CREATE TABLE IF NOT EXISTS "Maximiliano".calc_temperatures_correction
(
    temperature NUMERIC(8, 2) PRIMARY KEY,
    correction NUMERIC(8, 2)
);

-- Заполнение начальными данными
INSERT INTO "Maximiliano".calc_temperatures_correction(temperature, correction)
VALUES (0, 0.5), (5, 0.5), (10, 1), (20, 1), (25, 2), (30, 3.5), (40, 4.5)
ON CONFLICT (temperature) DO NOTHING;

-- Создание пользовательского типа
DROP TYPE IF EXISTS "Maximiliano".interpolation_type;
CREATE TYPE "Maximiliano".interpolation_type AS
(
    x0 NUMERIC(8, 2),
    x1 NUMERIC(8, 2),
    y0 NUMERIC(8, 2),
    y1 NUMERIC(8, 2)
);

-- ==============================
-- 8. Создание связей
-- ==============================
DO $$
BEGIN
    -- Добавление внешних ключей
    ALTER TABLE "Maximiliano".measurment_baths
    ADD CONSTRAINT emploee_id_fk
    FOREIGN KEY (emploee_id)
    REFERENCES "Maximiliano".employees (id);

    ALTER TABLE "Maximiliano".measurment_baths
    ADD CONSTRAINT measurment_input_param_id_fk
    FOREIGN KEY (measurment_input_param_id)
    REFERENCES "Maximiliano".measurment_input_params (id);

    ALTER TABLE "Maximiliano".measurment_input_params
    ADD CONSTRAINT measurment_type_id_fk
    FOREIGN KEY (measurment_type_id)
    REFERENCES "Maximiliano".measurment_types (id);

    ALTER TABLE "Maximiliano".employees
    ADD CONSTRAINT military_rank_id_fk
    FOREIGN KEY (military_rank_id)
    REFERENCES "Maximiliano".military_ranks (id);

    RAISE NOTICE 'Связи сформированы';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при создании связей: %', SQLERRM;
END $$;

RAISE NOTICE 'Структура сформирована успешно';

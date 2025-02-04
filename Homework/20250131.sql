-- Создание схемы "Maximiliano", если она не существует
CREATE SCHEMA IF NOT EXISTS "Maximiliano";

-- Создание последовательностей для автоматической генерации ID
CREATE SEQUENCE IF NOT EXISTS "Maximiliano".measurement_batch_seq;
CREATE SEQUENCE IF NOT EXISTS "Maximiliano".measurement_params_seq;

-- Создание таблицы "measurement_type"
-- Хранит типы измерений
CREATE TABLE IF NOT EXISTS "Maximiliano".measurement_type
(
    id integer NOT NULL,
    name character varying(100) NOT NULL, -- Название типа измерения (обязательное поле)
    CONSTRAINT measurement_type_pkey PRIMARY KEY (id)
);

-- Создание таблицы "measurement_batch"
-- Хранит пакеты измерений
CREATE TABLE IF NOT EXISTS "Maximiliano".measurement_batch
(
    id integer NOT NULL DEFAULT nextval('"Maximiliano".measurement_batch_seq'::regclass), -- Автоматическая генерация ID
    start_period timestamp without time zone DEFAULT now(), -- Время начала измерений (по умолчанию текущее время)
    position_x numeric(3,2), -- Координата X
    position_y numeric(3,2), -- Координата Y
    username character varying(100) NOT NULL, -- Имя пользователя (обязательное поле)
    CONSTRAINT measurement_batch_pkey PRIMARY KEY (id)
);

-- Создание таблицы "measurement_params"
-- Хранит параметры измерений
CREATE TABLE IF NOT EXISTS "Maximiliano".measurement_params
(
    id integer NOT NULL DEFAULT nextval('"Maximiliano".measurement_params_seq'::regclass), -- Автоматическая генерация ID
    measurement_type_id integer NOT NULL, -- Ссылка на тип измерения
    measurement_batch_id integer NOT NULL, -- Ссылка на пакет измерений
    height numeric(8,2), -- Высота
    temperature numeric(8,2), -- Температура
    wind_speed numeric(8,2), -- Скорость ветра
    wind_direction numeric(8,2), -- Направление ветра
    bullet_speed numeric(8,2), -- Скорость пули
    CONSTRAINT measurement_params_pkey PRIMARY KEY (id),
);

-- Создание таблицы "users"
-- Хранит данные пользователя
CREATE TABLE IF NOT EXISTS "Maximiliano".users (
    id SERIAL PRIMARY KEY, -- Уникальный ID пользователя
    username VARCHAR(50) NOT NULL UNIQUE, -- Логин пользователя
    password_hash VARCHAR(255) NOT NULL, -- Хэш пароля
    military_position_id integer NOT NULL, -- Id должности
    created_at timestamp without time zone DEFAULT now(), -- Дата регистрации
    is_active BOOLEAN DEFAULT TRUE -- Флаг активности пользователя
);

-- Создание таблицы "military_position"
-- Хранит данные должности
CREATE TABLE IF NOT EXISTS "Maximiliano".military_position (
    id SERIAL PRIMARY KEY, -- Уникальный ID должности
    position_name VARCHAR(100) NOT NULL UNIQUE, -- Наименование должности
    category VARCHAR(50) NOT NULL, -- Категория должности (например, "Командный состав")
    rank VARCHAR(50), -- Ранг/звание (например, "Майор", "Лейтенант")
    created_at timestamp without time zone DEFAULT now() -- Дата добавления записи
);

-- Изменение имени поля "username" на "user_name" в таблице "measurement_batch"
ALTER TABLE "Maximiliano".measurement_batch
RENAME COLUMN username TO user_name;

-- Изменение длины поля "user_name" и установка его как обязательного
ALTER TABLE "Maximiliano".measurement_batch
ALTER COLUMN user_name TYPE VARCHAR(100),
ALTER COLUMN user_name SET NOT NULL;
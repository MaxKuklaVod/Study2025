CREATE TABLE IF NOT EXISTS "Maximiliano".users (
    id SERIAL PRIMARY KEY, -- Уникальный ID пользователя
    username VARCHAR(50) NOT NULL UNIQUE, -- Логин пользователя
    password_hash VARCHAR(255) NOT NULL, -- Хэш пароля
    military_position_id integer NOT NULL, -- Id должности
    created_at timestamp without time zone DEFAULT now(), -- Дата регистрации
    is_active BOOLEAN DEFAULT TRUE -- Флаг активности пользователя
);

CREATE TABLE IF NOT EXISTS "Maximiliano".military_position (
    id SERIAL PRIMARY KEY, -- Уникальный ID должности
    position_name VARCHAR(100) NOT NULL UNIQUE, -- Наименование должности
    category VARCHAR(50) NOT NULL, -- Категория должности (например, "Командный состав")
    rank VARCHAR(50), -- Ранг/звание (например, "Майор", "Лейтенант")
    created_at timestamp without time zone DEFAULT now() -- Дата добавления записи
);

ALTER TABLE "Maximiliano".measurement_batch
RENAME COLUMN username TO user_name;

ALTER TABLE "Maximiliano".measurement_batch
ALTER COLUMN user_name TYPE VARCHAR(100),
ALTER COLUMN user_name SET NOT NULL;
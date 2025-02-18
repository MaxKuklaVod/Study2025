-- ==============================
-- 14. Генерация тестовых данных
-- ==============================
DO $$
DECLARE
    user_count INTEGER := 5; -- Количество пользователей
    measurement_count INTEGER := 100; -- Количество измерений на пользователя
    i INTEGER;
    j INTEGER;
    random_height NUMERIC(8, 2);
    random_temperature NUMERIC(8, 2);
    random_pressure NUMERIC(8, 2);
    random_wind_direction NUMERIC(8, 2);
    random_wind_speed NUMERIC(8, 2);
BEGIN
    -- Добавление пользователей
    FOR i IN 1..user_count LOOP
        INSERT INTO "Maximiliano".employees(id, name, birthday, military_rank_id)
        VALUES (i, 'User ' || i, NOW() - INTERVAL '1 year' * (RANDOM() * 50), FLOOR(RANDOM() * 2 + 1))
        ON CONFLICT (id) DO NOTHING;
    END LOOP;

    -- Добавление измерений
    FOR i IN 1..user_count LOOP
        FOR j IN 1..measurement_count LOOP
            -- Генерация случайных значений
            random_height := RANDOM() * 1000;
            random_temperature := -58 + RANDOM() * 116; -- Диапазон -58 до 58
            random_pressure := 500 + RANDOM() * 400;    -- Диапазон 500 до 900
            random_wind_direction := RANDOM() * 360;   -- Диапазон 0 до 360
            random_wind_speed := RANDOM() * 59;        -- Диапазон 0 до 59

            -- Вставка данных
            INSERT INTO "Maximiliano".measurment_input_params(id, measurment_type_id, height, temperature, pressure, wind_direction, wind_speed)
            VALUES ((i - 1) * measurement_count + j, FLOOR(RANDOM() * 2 + 1), random_height, random_temperature, random_pressure, random_wind_direction, random_wind_speed);
        END LOOP;
    END LOOP;

    RAISE NOTICE 'Тестовые данные успешно сгенерированы';
END $$;
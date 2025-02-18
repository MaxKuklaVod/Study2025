DO $$
BEGIN
    RAISE NOTICE 'Запускаем создание новой структуры базы данных Maximiliano';

    /*
     * 1. Удаляем старые элементы
     * ======================================
     */
    BEGIN
        -- Удаление внешних ключей
        ALTER TABLE IF EXISTS "Maximiliano".measurment_baths
        DROP CONSTRAINT IF EXISTS emploee_id_fk;

        ALTER TABLE IF EXISTS "Maximiliano".measurment_baths
        DROP CONSTRAINT IF EXISTS measurment_input_param_id_fk;

        ALTER TABLE IF EXISTS "Maximiliano".measurment_input_params
        DROP CONSTRAINT IF EXISTS measurment_type_id_fk;

        ALTER TABLE IF EXISTS "Maximiliano".employees
        DROP CONSTRAINT IF EXISTS military_rank_id_fk;

        -- Удаление таблиц
        DROP TABLE IF EXISTS "Maximiliano".measurment_baths;
        DROP TABLE IF EXISTS "Maximiliano".measurment_input_params;
        DROP TABLE IF EXISTS "Maximiliano".measurment_types;
        DROP TABLE IF EXISTS "Maximiliano".employees;
        DROP TABLE IF EXISTS "Maximiliano".military_ranks;
        DROP TABLE IF EXISTS "Maximiliano".calc_temperatures_correction;
        DROP TABLE IF EXISTS "Maximiliano".measure_settings;

        -- Удаление последовательностей
        DROP SEQUENCE IF EXISTS "Maximiliano".measurment_baths_seq;
        DROP SEQUENCE IF EXISTS "Maximiliano".measurment_input_params_seq;
        DROP SEQUENCE IF EXISTS "Maximiliano".measurment_types_seq;
        DROP SEQUENCE IF EXISTS "Maximiliano".employees_seq;
        DROP SEQUENCE IF EXISTS "Maximiliano".military_ranks_seq;

        RAISE NOTICE 'Удаление старых данных выполнено успешно';
    END;

    /*
     * 2. Создание новых структур данных
     * ======================================
     */

    -- 2.1. Справочник должностей
    CREATE TABLE IF NOT EXISTS "Maximiliano".military_ranks
    (
        id INTEGER PRIMARY KEY NOT NULL,
        description CHARACTER VARYING(255)
    );

    CREATE SEQUENCE IF NOT EXISTS "Maximiliano".military_ranks_seq START 3;
    ALTER TABLE "Maximiliano".military_ranks ALTER COLUMN id SET DEFAULT nextval('"Maximiliano".military_ranks_seq');

    INSERT INTO "Maximiliano".military_ranks(id, description)
    VALUES (1, 'Рядовой'), (2, 'Лейтенант')
    ON CONFLICT (id) DO NOTHING;

    -- 2.2. Таблица сотрудников
    CREATE TABLE IF NOT EXISTS "Maximiliano".employees
    (
        id INTEGER PRIMARY KEY NOT NULL,
        name TEXT,
        birthday TIMESTAMP,
        military_rank_id INTEGER
    );

    CREATE SEQUENCE IF NOT EXISTS "Maximiliano".employees_seq START 2;
    ALTER TABLE "Maximiliano".employees ALTER COLUMN id SET DEFAULT nextval('"Maximiliano".employees_seq');

    -- 2.3. Устройства для измерения
    CREATE TABLE IF NOT EXISTS "Maximiliano".measurment_types
    (
        id INTEGER PRIMARY KEY NOT NULL,
        short_name CHARACTER VARYING(50),
        description TEXT
    );

    CREATE SEQUENCE IF NOT EXISTS "Maximiliano".measurment_types_seq START 3;
    ALTER TABLE "Maximiliano".measurment_types ALTER COLUMN id SET DEFAULT nextval('"Maximiliano".measurment_types_seq');

    INSERT INTO "Maximiliano".measurment_types(id, short_name, description)
    VALUES (1, 'ДМК', 'Десантный метео комплекс'), (2, 'ВР', 'Ветровое ружье')
    ON CONFLICT (id) DO NOTHING;

    -- 2.4. Таблица с параметрами
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

    CREATE SEQUENCE IF NOT EXISTS "Maximiliano".measurment_input_params_seq START 2;
    ALTER TABLE "Maximiliano".measurment_input_params ALTER COLUMN id SET DEFAULT nextval('"Maximiliano".measurment_input_params_seq');

    -- 2.5. Таблица с историей
    CREATE TABLE IF NOT EXISTS "Maximiliano".measurment_baths
    (
        id INTEGER PRIMARY KEY NOT NULL,
        emploee_id INTEGER NOT NULL,
        measurment_input_param_id INTEGER NOT NULL,
        started TIMESTAMP DEFAULT NOW()
    );

    CREATE SEQUENCE IF NOT EXISTS "Maximiliano".measurment_baths_seq START 2;
    ALTER TABLE "Maximiliano".measurment_baths ALTER COLUMN id SET DEFAULT nextval('"Maximiliano".measurment_baths_seq');

    RAISE NOTICE 'Создание общих справочников и наполнение выполнено успешно';

    /*
     * 3. Подготовка расчетных структур
     * ======================================
     */

    -- 3.1. Таблица корректировок температуры
    DROP TABLE IF EXISTS "Maximiliano".calc_temperatures_correction;
    CREATE TABLE IF NOT EXISTS "Maximiliano".calc_temperatures_correction
    (
        temperature NUMERIC(8, 2) PRIMARY KEY,
        correction NUMERIC(8, 2)
    );

    INSERT INTO "Maximiliano".calc_temperatures_correction(temperature, correction)
    VALUES (0, 0.5), (5, 0.5), (10, 1), (20, 1), (25, 2), (30, 3.5), (40, 4.5)
    ON CONFLICT (temperature) DO NOTHING;

    -- 3.2. Пользовательский тип для интерполяции
    DROP TYPE IF EXISTS "Maximiliano".interpolation_type;
    CREATE TYPE "Maximiliano".interpolation_type AS
    (
        x0 NUMERIC(8, 2),
        x1 NUMERIC(8, 2),
        y0 NUMERIC(8, 2),
        y1 NUMERIC(8, 2)
    );

    -- 3.3. Настройки для проверки входных данных
    CREATE TABLE IF NOT EXISTS "Maximiliano".measure_settings
    (
        parameter_name TEXT PRIMARY KEY,
        min_value NUMERIC(8, 2),
        max_value NUMERIC(8, 2)
    );

    INSERT INTO "Maximiliano".measure_settings(parameter_name, min_value, max_value)
    VALUES 
        ('temperature', -58, 58),
        ('pressure', 500, 900),
        ('wind_direction', 0, 360),
        ('wind_speed', 0, 59);

    -- 3.4. Пользовательский тип для входных параметров
    DROP TYPE IF EXISTS "Maximiliano".input_params_type;
    CREATE TYPE "Maximiliano".input_params_type AS
    (
        height NUMERIC(8, 2),
        temperature NUMERIC(8, 2),
        pressure NUMERIC(8, 2),
        wind_direction NUMERIC(8, 2),
        wind_speed NUMERIC(8, 2)
    );

    RAISE NOTICE 'Расчетные структуры сформированы';

    /*
     * 4. Создание связей
     * ======================================
     */
    BEGIN
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
    END;

    /*
     * 5. Функции для расчетов
     * ======================================
     */

    -- 5.1. Функция для проверки входных параметров
    CREATE OR REPLACE FUNCTION "Maximiliano".validate_input_params(input_data "Maximiliano".input_params_type)
    RETURNS BOOLEAN AS $$
    DECLARE
        temp_min NUMERIC(8, 2);
        temp_max NUMERIC(8, 2);
        pressure_min NUMERIC(8, 2);
        pressure_max NUMERIC(8, 2);
        wind_dir_min NUMERIC(8, 2);
        wind_dir_max NUMERIC(8, 2);
        wind_speed_min NUMERIC(8, 2);
        wind_speed_max NUMERIC(8, 2);
    BEGIN
        -- Получение граничных значений из таблицы measure_settings
        SELECT min_value, max_value INTO temp_min, temp_max
        FROM "Maximiliano".measure_settings
        WHERE parameter_name = 'temperature';

        SELECT min_value, max_value INTO pressure_min, pressure_max
        FROM "Maximiliano".measure_settings
        WHERE parameter_name = 'pressure';

        SELECT min_value, max_value INTO wind_dir_min, wind_dir_max
        FROM "Maximiliano".measure_settings
        WHERE parameter_name = 'wind_direction';

        SELECT min_value, max_value INTO wind_speed_min, wind_speed_max
        FROM "Maximiliano".measure_settings
        WHERE parameter_name = 'wind_speed';

        -- Проверка температуры
        IF input_data.temperature < temp_min OR input_data.temperature > temp_max THEN
            RAISE EXCEPTION 'Температура вне допустимого диапазона: %–%', temp_min, temp_max;
        END IF;

        -- Проверка давления
        IF input_data.pressure < pressure_min OR input_data.pressure > pressure_max THEN
            RAISE EXCEPTION 'Давление вне допустимого диапазона: %–%', pressure_min, pressure_max;
        END IF;

        -- Проверка направления ветра
        IF input_data.wind_direction < wind_dir_min OR input_data.wind_direction > wind_dir_max THEN
            RAISE EXCEPTION 'Направление ветра вне допустимого диапазона: %–%', wind_dir_min, wind_dir_max;
        END IF;

        -- Проверка скорости ветра
        IF input_data.wind_speed < wind_speed_min OR input_data.wind_speed > wind_speed_max THEN
            RAISE EXCEPTION 'Скорость ветра вне допустимого диапазона: %–%', wind_speed_min, wind_speed_max;
        END IF;

        RETURN TRUE;
    END;

    -- 5.2. Функция для расчета метео-среднего
    CREATE OR REPLACE FUNCTION "Maximiliano".calculate_meteo_bulletin(measure_id INTEGER)
    RETURNS TABLE (
        bulletin_header TEXT,
        pressure_deviation TEXT,
        temperature_deviation TEXT
    ) AS $$
    DECLARE
        var_date TIMESTAMP;
        var_height NUMERIC(8, 2);
        var_pressure NUMERIC(8, 2);
        var_temperature NUMERIC(8, 2);
        var_virtual_correction NUMERIC(8, 2);
        var_virtual_temperature NUMERIC(8, 2);
        var_pressure_deviation NUMERIC(8, 2);
        var_temperature_deviation NUMERIC(8, 2);
    BEGIN
        -- Получение данных из таблицы measurment_input_params
        SELECT 
            started, 
            height, 
            pressure, 
            temperature
        INTO 
            var_date, 
            var_height, 
            var_pressure, 
            var_temperature
        FROM "Maximiliano".measurment_input_params
        WHERE id = measure_id;

        -- 1. Формирование заголовка бюллетеня (ДДЧЧМ)
        bulletin_header := TO_CHAR(var_date, 'DDHH24MI');

        -- 2. Расчет отклонения давления (ΔНо)
        var_pressure_deviation := var_pressure - 750;

        -- Форматирование давления
        IF var_pressure_deviation >= 0 THEN
            pressure_deviation := LPAD(TRIM(TO_CHAR(var_pressure_deviation, '999')), 3, '0');
        ELSE
            pressure_deviation := '5' || LPAD(TRIM(TO_CHAR(ABS(var_pressure_deviation), '999')), 2, '0');
        END IF;

        -- 3. Расчет виртуальной поправки ($ΔТ_{V}$)
        SELECT correction
        INTO var_virtual_correction
        FROM "Maximiliano".calc_temperatures_correction
        WHERE temperature = (
            SELECT MAX(temperature)
            FROM "Maximiliano".calc_temperatures_correction
            WHERE temperature <= var_temperature
        );

        -- 4. Расчет виртуальной температуры (T0)
        var_virtual_temperature := var_temperature + var_virtual_correction;

        -- 5. Расчет отклонения температуры ($ΔT_{0}^{мп}$)
        var_temperature_deviation := var_virtual_temperature - 15.9;

        -- Округление до целого значения
        var_temperature_deviation := ROUND(var_temperature_deviation);

        -- Форматирование температуры
        IF var_temperature_deviation >= 0 THEN
            temperature_deviation := LPAD(TRIM(TO_CHAR(var_temperature_deviation, '99')), 2, '0');
        ELSE
            temperature_deviation := '5' || LPAD(TRIM(TO_CHAR(ABS(var_temperature_deviation), '99')), 1, '0');
        END IF;

        -- Возвращаем результаты
        RETURN QUERY
        SELECT 
            bulletin_header,
            pressure_deviation,
            temperature_deviation;
    END;

    -- 5.3. Функция для расчета интерполяции
    CREATE OR REPLACE FUNCTION "Maximiliano".calculate_interpolation(var_temperature NUMERIC(8, 2))
    RETURNS NUMERIC(8, 2) AS $$
    DECLARE 
        var_interpolation "Maximiliano".interpolation_type;
        var_result NUMERIC(8, 2) DEFAULT 0;
        var_min_temperature NUMERIC(8, 2) DEFAULT 0;
        var_max_temperature NUMERIC(8, 2) DEFAULT 0;
        var_denominator NUMERIC(8, 2) DEFAULT 0;
    BEGIN
        RAISE NOTICE 'Расчет интерполяции для температуры %', var_temperature;

        -- Проверим, возможно температура совпадает со значением в справочнике
        IF EXISTS (SELECT 1 FROM "Maximiliano".calc_temperatures_correction WHERE temperature = var_temperature) THEN
            SELECT correction 
            INTO var_result 
            FROM "Maximiliano".calc_temperatures_correction
            WHERE temperature = var_temperature;
        ELSE    
            -- Получим диапазон, в котором работают поправки
            SELECT MIN(temperature), MAX(temperature) 
            INTO var_min_temperature, var_max_temperature
            FROM "Maximiliano".calc_temperatures_correction;

            IF var_temperature < var_min_temperature OR var_temperature > var_max_temperature THEN
                RAISE EXCEPTION 'Некорректно передан параметр! Невозможно рассчитать поправку. Значение должно укладываться в диапазон: %, %',
                    var_min_temperature, var_max_temperature;
            END IF;   

            -- Получим граничные параметры
            SELECT x0, y0, x1, y1 
            INTO var_interpolation.x0, var_interpolation.y0, var_interpolation.x1, var_interpolation.y1
            FROM (
                SELECT t1.temperature AS x0, t1.correction AS y0, t2.temperature AS x1, t2.correction AS y1
                FROM "Maximiliano".calc_temperatures_correction AS t1
                JOIN "Maximiliano".calc_temperatures_correction AS t2
                ON t1.temperature < t2.temperature
                WHERE t1.temperature <= var_temperature AND t2.temperature >= var_temperature
                ORDER BY t1.temperature
                LIMIT 1
            ) AS rightPart;

            RAISE NOTICE 'Граничные значения: %', var_interpolation;

            -- Расчет поправки
            var_denominator := var_interpolation.x1 - var_interpolation.x0;
            IF var_denominator = 0.0 THEN
                RAISE EXCEPTION 'Деление на нуль. Возможно, некорректные данные в таблице с поправками!';
            END IF;

            var_result := (var_temperature - var_interpolation.x0) * (var_interpolation.y1 - var_interpolation.y0) / var_denominator + var_interpolation.y0;
        END IF;

        RETURN var_result;
    END;

    RAISE NOTICE 'Функции для расчетов созданы успешно';

    RAISE NOTICE 'Структура сформирована успешно';
END $$;
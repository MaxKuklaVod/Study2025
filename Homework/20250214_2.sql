-- ==============================
-- 9. Пример скрипта для расчета интерполяции
-- ==============================
DO $$
DECLARE 
    var_interpolation "Maximiliano".interpolation_type;
    var_temperature INTEGER DEFAULT 22;
    var_result NUMERIC(8, 2) DEFAULT 0;
    var_min_temparure NUMERIC(8, 2) DEFAULT 0;
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
        INTO var_min_temparure, var_max_temperature
        FROM "Maximiliano".calc_temperatures_correction;

        IF var_temperature < var_min_temparure OR var_temperature > var_max_temperature THEN
            RAISE EXCEPTION 'Некорректно передан параметр! Невозможно рассчитать поправку. Значение должно укладываться в диапазон: %, %',
                var_min_temparure, var_max_temperature;
        END IF;   

        -- Получим граничные параметры
        SELECT x0, y0, x1, y1 
        INTO var_interpolation.x0, var_interpolation.y0, var_interpolation.x1, var_interpolation.y1
        FROM (
            SELECT t1.temperature AS x0, t1.correction AS y0
            FROM "Maximiliano".calc_temperatures_correction AS t1
            WHERE t1.temperature <= var_temperature
            ORDER BY t1.temperature DESC
            LIMIT 1
        ) AS leftPart
        CROSS JOIN (
            SELECT t1.temperature AS x1, t1.correction AS y1
            FROM "Maximiliano".calc_temperatures_correction AS t1
            WHERE t1.temperature >= var_temperature
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

    RAISE NOTICE 'Результат: %', var_result;
END $$;
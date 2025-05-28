
-- 1. Procedimiento que crea una vista con tareas asociadas a una categoría
CREATE OR REPLACE PROCEDURE crear_vista_por_categoria(categoria_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    nombre_vista TEXT := 'vista_categoria_' || categoria_id;
BEGIN
    EXECUTE format('
        CREATE OR REPLACE VIEW %I AS
        SELECT * FROM tareas WHERE categoria_id = %L
    ', nombre_vista, categoria_id);
END;
$$;

-- 2. Vista materializada con usuarios que tengan tareas pendientes
CREATE MATERIALIZED VIEW IF NOT EXISTS usuarios_con_tareas_pendientes AS
SELECT u.*
FROM users u
JOIN tareas t ON t.usuario_id = u.uid
WHERE t.estado = 'pendiente'
WITH DATA;

-- 3. Transacción que cierra tareas expiradas
DO $$
BEGIN
    UPDATE tareas
    SET estado = 'cerrada'
    WHERE fecha_limite < CURRENT_DATE AND estado != 'cerrada';
END;
$$;

-- 4. Transacción para clonar tareas de un usuario a otro
CREATE OR REPLACE PROCEDURE clonar_tareas(origen INT, destino INT)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO tareas (titulo, descripcion, fecha_limite, usuario_id, prioridad_id)
    SELECT titulo, descripcion, fecha_limite, destino, prioridad_id
    FROM tareas
    WHERE usuario_id = origen;
END;
$$;

-- 5. Tabla temporal con información de tareas
CREATE TEMP TABLE IF NOT EXISTS temp_tareas
ON COMMIT PRESERVE ROWS
AS
SELECT * FROM tareas;

-- 6. Procedimiento genérico para llenar cualquier tabla usando ciclos
CREATE OR REPLACE PROCEDURE llenar_tabla(tabla TEXT, veces INT)
LANGUAGE plpgsql AS $$
DECLARE
    i INT := 1;
BEGIN
    LOOP
        EXIT WHEN i > veces;
        EXECUTE format('INSERT INTO %I DEFAULT VALUES', tabla);
        i := i + 1;
    END LOOP;
END;
$$;

-- 7. Función que devuelve nombre y tarea
CREATE OR REPLACE FUNCTION persona_tarea()
RETURNS TABLE(nombre TEXT, tarea TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT u.name, t.titulo
    FROM users u
    JOIN tareas t ON t.usuario_id = u.uid;
END;
$$ LANGUAGE plpgsql;

-- 8. Procedimiento que concatena etiquetas y prioridad
CREATE OR REPLACE PROCEDURE resumen_tareas()
LANGUAGE plpgsql AS $$
DECLARE
    reg RECORD;
BEGIN
    FOR reg IN
        SELECT t.id, u.name, t.titulo, p.nombre AS prioridad,
               string_agg(e.nombre, ', ') AS etiquetas
        FROM tareas t
        JOIN users u ON t.usuario_id = u.uid
        JOIN prioridad p ON p.id = t.prioridad_id
        JOIN tareas_etiquetas te ON te.tarea_id = t.id
        JOIN etiquetas e ON e.id = te.etiqueta_id
        GROUP BY t.id, u.name, t.titulo, p.nombre
    LOOP
        RAISE NOTICE '#% - % - % - % – %', reg.id, reg.name, reg.titulo, reg.prioridad, reg.etiquetas;
    END LOOP;
END;
$$;

-- 9. Procedimiento para crear vistas dinámicas (normales o materializadas)
CREATE OR REPLACE PROCEDURE crear_vista_dinamica(tipo TEXT, nombre TEXT, consulta TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    CASE tipo
        WHEN 'materializada' THEN
            EXECUTE format('CREATE MATERIALIZED VIEW %I AS %s WITH DATA', nombre, consulta);
        WHEN 'normal' THEN
            EXECUTE format('CREATE OR REPLACE VIEW %I AS %s', nombre, consulta);
        ELSE
            RAISE EXCEPTION 'Tipo de vista no soportado';
    END CASE;
END;
$$;

-- 10. Procedimiento para clonar cualquier tabla en una tabla temporal
CREATE OR REPLACE PROCEDURE clonar_tabla(tabla_origen TEXT)
LANGUAGE plpgsql AS $$
DECLARE
    tabla_temp TEXT := 'temp_' || tabla_origen;
BEGIN
    EXECUTE format('CREATE TEMP TABLE %I AS TABLE %I', tabla_temp, tabla_origen);
END;
$$;

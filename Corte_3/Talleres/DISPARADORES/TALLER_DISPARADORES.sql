-- =============================================
-- TALLER BASE DE DATOS 2 - DISPARADORES
-- Autor: David Andrés Cuadrado
-- Fecha: Junio 2025
-- EXPLICACIÓN EN ESTE DOCUMENTO ANTES DE CADA CASO
-- =============================================

CREATE TABLE patient (
    pat_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    birthday DATE NOT NULL
);

CREATE TABLE doctor (
    doc_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    specialty_id INT,
    FOREIGN KEY (specialty_id) REFERENCES specialty(specialty_id)
);

CREATE TABLE specialty (
    specialty_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE appointment (
    app_id SERIAL PRIMARY KEY,
    doc_id INT NOT NULL,
    pat_id INT NOT NULL,
    date DATE NOT NULL,
    hour TIME NOT NULL,
    FOREIGN KEY (doc_id) REFERENCES doctor(doc_id),
    FOREIGN KEY (pat_id) REFERENCES patient(pat_id)
);

CREATE TABLE treatment (
    tre_id SERIAL PRIMARY KEY,
    pat_id INT NOT NULL,
    description TEXT NOT NULL,
    start_date DATE NOT NULL,
    FOREIGN KEY (pat_id) REFERENCES patient(pat_id)
);

INSERT INTO specialty (name) VALUES
('Pediatría'),
('Cardiología'),
('Dermatología');

INSERT INTO doctor (name, specialty_id) VALUES
('Dra. Juliana Torres', 1),
('Dr. Ricardo Gómez', 2),
('Dra. Camila Pérez', 3);

INSERT INTO patient (name, birthday) VALUES
('Mateo Rodríguez', '2010-06-12'),
('Laura Martínez', '1995-08-24'),
('Jorge González', '2007-12-01'),
('Ana María Salazar', '1989-03-03');

INSERT INTO appointment (doc_id, pat_id, date, hour) VALUES
(1, 1, '2025-06-03', '09:00'),
(2, 2, '2025-06-03', '10:00'),
(3, 4, '2025-06-04', '11:30');

INSERT INTO treatment (pat_id, description, start_date) VALUES
(1, 'Tratamiento para asma leve', '2025-06-01'),
(2, 'Control de presión arterial', '2025-06-02'),
(4, 'Crema para acné moderado', '2025-06-03');


-- =============================================
-- CASO 1: AUDITORÍA DE CAMBIOS EN TRATAMIENTOS
-- =============================================

-- Problema:
-- La clínica necesita llevar un registro histórico de los tratamientos asignados a cada paciente.
-- Cada vez que se actualice la descripción o la fecha de inicio de un tratamiento, se debe registrar 
-- qué cambió, cuándo y con qué valores.

-- Solución:
-- Se crea una tabla de auditoría llamada treatment_log y un disparador AFTER UPDATE sobre la tabla treatment.
-- El disparador compara los valores antiguos con los nuevos, y si hay cambios, guarda un registro en el log.

DROP TABLE IF EXISTS treatment_log CASCADE;
CREATE TABLE treatment_log (
    log_id SERIAL PRIMARY KEY,
    tre_id INT,
    old_description TEXT,
    new_description TEXT,
    old_start_date DATE,
    new_start_date DATE,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_treatment_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.description <> NEW.description OR OLD.start_date <> NEW.start_date THEN
        INSERT INTO treatment_log(tre_id, old_description, new_description, old_start_date, new_start_date)
        VALUES (OLD.tre_id, OLD.description, NEW.description, OLD.start_date, NEW.start_date);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_treatment ON treatment;
CREATE TRIGGER trg_update_treatment
AFTER UPDATE ON treatment
FOR EACH ROW
EXECUTE FUNCTION log_treatment_changes();

-- =============================================
-- CASO 2: EVITAR CITAS DUPLICADAS
-- =============================================

-- Problema:
-- En ocasiones, se intenta agendar más de una cita con el mismo paciente, médico, día y hora,
-- lo cual genera conflictos en la programación y duplicación de horarios.

-- Solución:
-- Se crea un disparador BEFORE INSERT sobre la tabla appointment que revisa si ya existe una cita
-- con los mismos datos. Si la encuentra, lanza una excepción y evita la inserción duplicada.

CREATE OR REPLACE FUNCTION prevent_duplicate_appointments()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM appointment
        WHERE doc_id = NEW.doc_id
          AND pat_id = NEW.pat_id
          AND date = NEW.date
          AND hour = NEW.hour
    ) THEN
        RAISE EXCEPTION 'Ya existe una cita registrada con este médico, paciente y horario.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_duplicate_appointments ON appointment;
CREATE TRIGGER trg_prevent_duplicate_appointments
BEFORE INSERT ON appointment
FOR EACH ROW
EXECUTE FUNCTION prevent_duplicate_appointments();


-- =============================================
-- CASO 3: ALERTA POR MENORES DE EDAD
-- =============================================

-- Problema:
-- La clínica necesita identificar automáticamente a los pacientes menores de 18 años 
-- para gestionar la autorización de un representante legal.

-- Solución:
-- Se crea una tabla auxiliar minor_alerts donde se insertan automáticamente los datos 
-- de pacientes menores cuando se agregan. Esto se logra con un AFTER INSERT sobre patient.

DROP TABLE IF EXISTS minor_alerts CASCADE;
CREATE TABLE minor_alerts (
    alert_id SERIAL PRIMARY KEY,
    pat_id INT,
    name TEXT,
    birthday DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION check_minor_patient()
RETURNS TRIGGER AS $$
BEGIN
    IF AGE(NEW.birthday) < INTERVAL '18 years' THEN
        INSERT INTO minor_alerts(pat_id, name, birthday)
        VALUES (NEW.pat_id, NEW.name, NEW.birthday);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_minor_patient ON patient;
CREATE TRIGGER trg_check_minor_patient
AFTER INSERT ON patient
FOR EACH ROW
EXECUTE FUNCTION check_minor_patient();

-- =============================================
-- PRUEBAS CASO 1: Auditoría de Cambios en Tratamientos
-- =============================================

-- Insertar tratamiento inicial
INSERT INTO treatment (pat_id, description, start_date)
VALUES (1, 'Terapia de rehabilitación', '2025-06-01');

-- Actualizar tratamiento (debería activarse el disparador)
UPDATE treatment
SET description = 'Terapia de rehabilitación avanzada',
    start_date = '2025-06-10'
WHERE tre_id = 1;

-- Consultar el log
SELECT * FROM treatment_log;

-- =============================================
-- PRUEBAS CASO 2: Evitar Citas Duplicadas
-- =============================================

-- Insertar una cita válida
INSERT INTO appointment (doc_id, pat_id, date, hour)
VALUES (1, 1, '2025-06-20', '10:00');

-- Intentar insertar la misma cita (debe fallar)
-- COMENTA ESTA LÍNEA PARA EVITAR INTERRUPCIÓN EN BLOQUES DE EJECUCIÓN
-- INSERT INTO appointment (doc_id, pat_id, date, hour)
-- VALUES (1, 1, '2025-06-20', '10:00');

-- Verificar que la cita única fue registrada
SELECT * FROM appointment;

-- =============================================
-- PRUEBAS CASO 3: Alerta por Menores de Edad
-- =============================================

-- Insertar un paciente menor de edad
INSERT INTO patient (name, birthday)
VALUES ('Carlos Niño', '2010-08-15');

-- Insertar un paciente mayor de edad
INSERT INTO patient (name, birthday)
VALUES ('Ana Mayor', '1995-03-10');

-- Consultar alertas por menores
SELECT * FROM minor_alerts;
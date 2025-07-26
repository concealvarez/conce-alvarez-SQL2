INSERT INTO medioDePago (tipo)
SELECT * FROM (SELECT 'Débito') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM medioDePago WHERE tipo = 'Débito')
UNION
SELECT * FROM (SELECT 'Crédito') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM medioDePago WHERE tipo = 'Crédito')
UNION
SELECT * FROM (SELECT 'Efectivo') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM medioDePago WHERE tipo = 'Efectivo')
UNION
SELECT * FROM (SELECT 'Qr') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM medioDePago WHERE tipo = 'Qr');

INSERT INTO profesor (nombre, direccion, telefono)
SELECT * FROM (SELECT 'Ignacio Farias', 'cerrito 20', '2333000') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM profesor WHERE nombre = 'Ignacio Farias')
UNION
SELECT * FROM (SELECT 'Veronica Balmaceda', 'Concorida 56', '4445555') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM profesor WHERE nombre = 'Veronica Balmaceda')
UNION
SELECT * FROM (SELECT 'Rodrigo Campos', 'neuquen 305', '44555322') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM profesor WHERE nombre = 'Rodrigo Campos')
UNION
SELECT * FROM (SELECT 'Julia Romero', 'villa los altos 90', '767687') AS tmp
WHERE NOT EXISTS (SELECT 1 FROM profesor WHERE nombre = 'Julia Romero');

INSERT INTO servicio (actividad, dias, costo, id_profe)
SELECT * FROM (
    SELECT 'Musculacion' AS actividad, '2' AS dias, 20000 AS costo, 1 AS id_profe
    UNION
    SELECT 'Musculacion', '3', 25000, 1
    UNION
    SELECT 'Musculacion', '5', 30000, 1
    UNION
    SELECT 'Pilates', '2', 15000, 4
    UNION
    SELECT 'Pilates', '4', 25000, 4
    UNION
    SELECT 'Natacion', '3', 30000, 2
    UNION
    SELECT 'Natacion', '5', 40000, 2
    UNION
    SELECT 'Entrenamiento Deportivo', '5', 30000, 3
) AS tmp
WHERE NOT EXISTS (
    SELECT 1 FROM servicio s
    WHERE s.actividad = tmp.actividad AND s.dias = tmp.dias
);

INSERT INTO cliente (nombre, apellido, fecha_nacimiento, direccion, telefono, id_actividad)
VALUES
('Micaela', 'Videla', '1990-07-20', 'cerrito 120', '222333444', 1),
('Sofia', 'Acuña', '2002-05-30', 'av.malvina 34', '333444555', 5),
('Candela', 'Perez', '1987-03-09', 'esq. San Martin', '444333222', 8),
('Mateo', 'Juarez', '2000-03-20', '9 de Julio 89', '00222333', 6),
('Juan', 'Perez', '1994-04-09', 'cangallo 321', '3339999', 2),
('Claudia', 'Sanchez', '2003-02-28', 'av. belgrano 97', '3097322', 3),
('Maximiliano', 'Castro', '2004-06-25', 'belgrano 455', '4628639', 7);

INSERT INTO plan (id_actividad, id_cliente, id_pago, estado, pagado, vencimiento, fecha_actualizacion)
VALUES
(1, 1, 3, 'pagado', TRUE, '2025-06-01', '2025-06-20'),
(5, 2, 3, 'pagado', TRUE, '2025-06-01', '2025-07-05'),
(8, 3, 4, 'pagado', TRUE, '2025-06-01', '2025-06-30'),
(6, 4, 1, 'pagado', TRUE, '2025-06-01', '2025-07-04'),
(2, 5, 4, 'pendiente', FALSE, '2025-06-01', '2025-06-01'),
(3, 6, 2, 'pagado', TRUE, '2025-06-01', '2025-07-12'),
(7, 7, 1, 'pendiente', FALSE, '2025-06-01', '2025-07-05');

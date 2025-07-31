-- funcion para calcular descuento
DELIMITER $$
CREATE FUNCTION calcular_descuento(idPlan INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE costo DECIMAL(10,2);
    DECLARE tipo_pago VARCHAR(50);

    SELECT s.costo, m.tipo INTO costo, tipo_pago
    FROM plan p
    JOIN servicio s ON s.id_actividad = p.id_actividad
    JOIN medioDePago m ON m.id_pago = p.id_pago
    WHERE p.id_plan = idPlan;

    IF tipo_pago = 'Efectivo' THEN
        RETURN costo * 0.90;
    ELSE
        RETURN costo;
    END IF;
END$$

-- Funcion para mostrar mensaje segun estado

CREATE FUNCTION mensaje_estado(nombre VARCHAR(100), estado VARCHAR(50))
RETURNS VARCHAR(150)
DETERMINISTIC
BEGIN
    IF estado = 'pendiente' THEN
        RETURN CONCAT('Estimado/a ', nombre, ', su pago está pendiente.');
    ELSEIF estado = 'pagado' THEN
        RETURN CONCAT('Gracias ', nombre, ', su pago está al día.');
    ELSE
        RETURN 'Estado desconocido';
    END IF;
END$$
DELIMITER ;

-- Procedimiento para agregar cliente

DELIMITER $$
CREATE PROCEDURE agregar_cliente (
    IN pnombre VARCHAR(100),
    IN papellido VARCHAR(100),
    IN pfecha_nac DATE,
    IN pdireccion TEXT,
    IN ptelefono VARCHAR(15),
    IN pid_actividad INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM cliente
        WHERE nombre = pnombre AND apellido = papellido AND fecha_nacimiento = pfecha_nac
    ) THEN
        INSERT INTO cliente (nombre, apellido, fecha_nacimiento, direccion, telefono, id_actividad)
        VALUES (pnombre, papellido, pfecha_nac, pdireccion, ptelefono, pid_actividad);
    END IF;
END$$

-- Procedimiento para actualizar estado

CREATE PROCEDURE registrar_pago (
    IN pid_plan INT,
    IN pestado VARCHAR(50),
    IN ppagado BOOLEAN
)
BEGIN
    START TRANSACTION;
    UPDATE plan
    SET estado = pestado,
        pagado = ppagado,
        fecha_actualizacion = NOW()
    WHERE id_plan = pid_plan;
    COMMIT;
END$$
DELIMITER ;

-- Trigger para evitar planes con fecha ya vencida
DELIMITER $$
CREATE TRIGGER before_insert_plan
BEFORE INSERT ON plan
FOR EACH ROW
BEGIN
    IF NEW.vencimiento < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede registrar un plan vencido';
    END IF;
END$$

-- Trigger para auditar cambios en los pagos

CREATE TRIGGER after_update_pago
AFTER UPDATE ON plan
FOR EACH ROW
BEGIN
    INSERT INTO log_pagos (id_plan, fecha, estado) VALUES (NEW.id_plan, NOW(), NEW.estado);
END$$
DELIMITER ;

-- Vista para mostrar clientes que tienen pagos pendientes
CREATE OR REPLACE VIEW vista_pendientes AS
SELECT c.nombre, c.apellido, p.estado, p.vencimiento
FROM cliente c
JOIN plan p ON c.id_cliente = p.id_cliente
WHERE p.estado = 'pendiente';

-- Vista para mostrar el costo del servicio, el medio de pago y el total con descuento si corresponde
CREATE OR REPLACE VIEW vista_descuentos AS
SELECT c.nombre, s.actividad, s.costo, m.tipo AS medio_pago,
       calcular_descuento(p.id_plan) AS total_a_pagar
FROM plan p
JOIN cliente c ON p.id_cliente = c.id_cliente
JOIN servicio s ON p.id_actividad = s.id_actividad
JOIN medioDePago m ON p.id_pago = m.id_pago;

-- Vista para mostrar clientes menores de edad
CREATE OR REPLACE VIEW vista_menores AS
SELECT id_cliente, nombre, apellido,
       TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) AS edad
FROM cliente
WHERE TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) < 18;

-- Vista para mostrar planes vencidos 
CREATE OR REPLACE VIEW vista_planes_vencidos AS
SELECT p.id_plan, c.nombre, p.vencimiento
FROM plan p
JOIN cliente c ON c.id_cliente = p.id_cliente
WHERE p.vencimiento < CURDATE();

-- Vista para ver cada profesor, la actividad que da y cuántos alumnos tiene
CREATE OR REPLACE VIEW vista_servicios_por_profe AS
SELECT pr.nombre AS profesor, s.actividad, COUNT(c.id_cliente) AS total_alumnos
FROM profesor pr
JOIN servicio s ON s.id_profe = pr.id_profe
JOIN cliente c ON c.id_actividad = s.id_actividad
GROUP BY pr.nombre, s.actividad;

-- Tabla para trigger
CREATE TABLE log_pagos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_plan INT,
    fecha DATETIME,
    estado VARCHAR(50),
    FOREIGN KEY (id_plan) REFERENCES plan(id_plan)
);

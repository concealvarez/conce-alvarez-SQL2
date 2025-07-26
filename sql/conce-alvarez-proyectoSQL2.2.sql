-- Vista de pendientes
CREATE OR REPLACE VIEW ver_pendientes AS
SELECT 
    c.id_cliente,
    c.nombre,
    c.apellido,
    p.estado,
    p.fecha_actualizacion
FROM cliente c  
JOIN plan p ON c.id_cliente = p.id_cliente
WHERE p.estado = 'pendiente';

-- Vista de menores de edad
CREATE OR REPLACE VIEW vista_menores_edad AS
SELECT 
    id_cliente,
    nombre,
    apellido,
    fecha_nacimiento,
    TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) AS edad
FROM cliente
WHERE TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) < 18;

-- Procedimiento para actualizar estado
DELIMITER //
CREATE PROCEDURE actualizar_estado (
    IN p_estado VARCHAR(50),
    IN p_id_plan INT
)
BEGIN 
    UPDATE plan
    SET estado = p_estado,
        fecha_actualizacion = NOW()
    WHERE id_plan = p_id_plan;
END //
DELIMITER ;

-- Función mensaje según estado
DELIMITER //
CREATE FUNCTION pendientes(nombre VARCHAR(50), apellido VARCHAR(50), tipo_estado VARCHAR(50))
RETURNS VARCHAR(150)
DETERMINISTIC
BEGIN
    DECLARE nombre_completo VARCHAR(150);
    SET nombre_completo = CONCAT(nombre, ' ', apellido);
    
    IF tipo_estado = 'pendiente' THEN
        RETURN CONCAT('Tu pago está pendiente ', nombre_completo);
    ELSEIF tipo_estado = 'pagado' THEN
        RETURN 'Estás al día :)';
    ELSE
        RETURN 'Estado no identificado';
    END IF;
END //
DELIMITER ;

-- Función de descuento para efectivo
DELIMITER $$
CREATE FUNCTION calcular_descuento(idPlan INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE costo_original DECIMAL(10,2);
    DECLARE tipo_pago VARCHAR(50);
    DECLARE costo_final DECIMAL(10,2);

    SELECT s.costo, m.tipo
    INTO costo_original, tipo_pago
    FROM plan p
    JOIN servicio s ON p.id_actividad = s.id_actividad
    JOIN medioDePago m ON p.id_pago = m.id_pago
    WHERE p.id_plan = idPlan;

    IF tipo_pago = 'Efectivo' THEN
        SET costo_final = costo_original * 0.90; 
    ELSE
        SET costo_final = costo_original;
    END IF;

    RETURN costo_final;
END$$
DELIMITER ;

-- Vista de planes con descuento
CREATE OR REPLACE VIEW vista_planes_con_descuento AS
SELECT 
    c.nombre,
    c.apellido,
    s.actividad,
    s.costo AS costo_original,
    m.tipo AS medio_pago,
    calcular_descuento(p.id_plan) AS costo_final
FROM plan p
JOIN cliente c ON p.id_cliente = c.id_cliente
JOIN servicio s ON p.id_actividad = s.id_actividad
JOIN medioDePago m ON p.id_pago = m.id_pago;

-- Procedimiento para agregar cliente
DELIMITER $$
CREATE PROCEDURE agregar_cliente(
    IN pnombre VARCHAR(100),
    IN papellido VARCHAR(100),
    IN pfecha_nacimiento DATE,
    IN pdireccion TEXT,
    IN ptelefono VARCHAR(15),
    IN pid_actividad INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM cliente 
        WHERE nombre = pnombre AND apellido = papellido AND fecha_nacimiento = pfecha_nacimiento
    ) THEN
        INSERT INTO cliente (nombre, apellido, fecha_nacimiento, direccion, telefono, id_actividad)
        VALUES (pnombre, papellido, pfecha_nacimiento, pdireccion, ptelefono, pid_actividad);
    END IF;
END$$
DELIMITER ;

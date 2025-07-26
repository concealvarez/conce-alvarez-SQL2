DROP SCHEMA IF EXISTS controlPago;
CREATE SCHEMA controlPago;
USE controlPago;

CREATE TABLE profesor(
	id_profe INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    direccion TEXT NOT NULL,
    telefono VARCHAR(15)
);

CREATE TABLE servicio(
	id_actividad INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    actividad VARCHAR(100) NOT NULL,
    dias VARCHAR(20) NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    id_profe INT NOT NULL,
    FOREIGN KEY (id_profe) REFERENCES profesor(id_profe)
);

CREATE TABLE cliente(
	id_cliente INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    direccion TEXT,
    telefono VARCHAR(15),
    id_actividad INT NOT NULL,
    FOREIGN KEY (id_actividad) REFERENCES servicio(id_actividad)
);

CREATE TABLE medioDePago(
	id_pago INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(50) NOT NULL
);

CREATE TABLE plan(
	id_plan INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    pagado BOOLEAN NOT NULL,
    vencimiento DATE NOT NULL,
    estado VARCHAR(50) NOT NULL,
    fecha_actualizacion DATETIME,
    id_cliente INT NOT NULL,
    id_actividad INT NOT NULL,
    id_pago INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_actividad) REFERENCES servicio(id_actividad),
    FOREIGN KEY (id_pago) REFERENCES medioDePago(id_pago)
);

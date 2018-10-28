USE GD2C2018
GO

-- creation schema LOS_FRANCES
CREATE SCHEMA LOS_FRANCES
GO

-- ================ CREATION TABLES ==================
-- ===================================================

CREATE TABLE LOS_FRANCES.Cliente
(
  Cli_Dni NUMERIC(18) NOT NULL
    CONSTRAINT Cliente_Cli_Dni_pk
    PRIMARY KEY,
  Apelido NVARCHAR(255),
  Nombre NVARCHAR(255),
  Fecha_Nac DATETIME,
  Mail NVARCHAR(255),
  Dom_Calle NVARCHAR(255),
  Nro_Calle NUMERIC(18),
  Piso NUMERIC(18),
  Depto NVARCHAR(255),
  Cod_Postal NVARCHAR(255)
)
GO

CREATE TABLE LOS_FRANCES.Espec_Empresa
(
  Espec_Empresa_Cuit NVARCHAR(255) NOT NULL
    PRIMARY KEY,
  Razon_Social NVARCHAR(255),
  Fecha_Creacion DATETIME,
  Mail NVARCHAR(255),
  Dom_Calle NVARCHAR(255),
  Nro_Calle NUMERIC(18),
  Piso NUMERIC(18),
  Depto NVARCHAR(255),
  Cod_Postal NVARCHAR(50)
)
GO

CREATE TABLE LOS_FRANCES.Espectaculo
(
  Espectaculo_Cod NUMERIC(18) NOT NULL
    PRIMARY KEY,
  Descripcion NVARCHAR(255),
  Fecha DATETIME,
  Fecha_Venc DATETIME,
  Rubro_Descripcion NVARCHAR(255),
  Estado NVARCHAR(255),
  Espec_Empresa_Cuit NVARCHAR(255)
    CONSTRAINT Espectaculo_Espec_Empresa_Espec_Empresa_Cuit_fk
    REFERENCES LOS_FRANCES.Espec_Empresa
)
GO

CREATE TABLE LOS_FRANCES.Compra
(
  Compra_Id INT NOT NULL
    PRIMARY KEY,
  Fecha DATETIME,
  Cantidad NUMERIC(18),
  Cli_Dni NUMERIC(18)
    CONSTRAINT Compra_Cliente_Cli_Dni_fk
    REFERENCES LOS_FRANCES.Cliente
)
GO

CREATE TABLE LOS_FRANCES.Ubicacion_Tipo
(
  Ubicacion_Tipo_Codigo NUMERIC(18) NOT NULL
    PRIMARY KEY,
  Descripcion NVARCHAR(255)
)
GO

CREATE TABLE LOS_FRANCES.Ubicacion
(
  Ubicacion_Id INT NOT NULL
    PRIMARY KEY,
  Fila VARCHAR(3),
  Asiento NUMERIC(18),
  Sin_numerar BIT,
  Precio NUMERIC(18),
  Compra_Id INT
    CONSTRAINT Ubicacion_Compra_Compra_Id_fk
    REFERENCES LOS_FRANCES.Compra,
  Espectaculo_Cod NUMERIC(18)
    CONSTRAINT Ubicacion_Espectaculo_Espectaculo_Cod_fk
    REFERENCES LOS_FRANCES.Espectaculo,
  Ubicacion_Tipo_Codigo NUMERIC(18)
    CONSTRAINT Ubicacion_Ubicacion_Tipo_Ubicacion_Tipo_Codigo_fk
    REFERENCES LOS_FRANCES.Ubicacion_Tipo
)
GO

CREATE TABLE LOS_FRANCES.Item_Factura
(
  Item_Factura_Id INT NOT NULL
    PRIMARY KEY,
  Monto NUMERIC(18, 2),
  Cantidad NUMERIC(18),
  Descripcion NVARCHAR(60),
  Compra_Id INT
    CONSTRAINT Item_Factura_Compra_Compra_Id_fk
    REFERENCES LOS_FRANCES.Compra
)
GO

CREATE TABLE LOS_FRANCES.Factura
(
  Factura_Nro NUMERIC(18) NOT NULL
    PRIMARY KEY,
  Fecha DATETIME,
  Total NUMERIC(18, 2),
  Pago_Desc NVARCHAR(255),
  Espectaculo_Cod NUMERIC(18)
    CONSTRAINT Factura_Espectaculo_Espectaculo_Cod_fk
    REFERENCES LOS_FRANCES.Espectaculo
)
GO

-- create view with table master and add Ubicacion_Id / Compra_Id / Item_Factura_Id
CREATE VIEW LOS_FRANCES.Master_With_PK
AS
  SELECT
    *,
    ROW_NUMBER()
    OVER (
      ORDER BY m.Espectaculo_Cod ) AS Ubicacion_Id,
    ROW_NUMBER()
    OVER (
      ORDER BY m.Espectaculo_Cod ) AS Compra_Id,
    ROW_NUMBER()
    OVER (
      ORDER BY m.Espectaculo_Cod ) AS Item_Factura_Id
  FROM gd_esquema.Maestra m
GO

-- ================ INSERTIONS VALUES  ==================
-- ===================================================

-- Insert Espectaculo empresa from MASTER to new_database
INSERT INTO LOS_FRANCES.Espec_Empresa
  (Espec_Empresa_Cuit, Razon_Social, Fecha_Creacion, Mail, Dom_Calle, Nro_Calle, Piso, Depto, Cod_Postal)
SELECT DISTINCT
  m.Espec_Empresa_Cuit,
  m.Espec_Empresa_Razon_Social,
  m.Espec_Empresa_Fecha_Creacion,
  m.Espec_Empresa_Mail,
  m.Espec_Empresa_Dom_Calle,
  m.Espec_Empresa_Nro_Calle,
  m.Espec_Empresa_Piso,
  m.Espec_Empresa_Depto,
  m.Espec_Empresa_Cod_Postal
FROM LOS_FRANCES.Master_With_PK AS m
GO

-- Insert Espectaculo from MASTER to new_database
INSERT INTO LOS_FRANCES.Espectaculo
  (Espectaculo_Cod, Descripcion, Fecha, Fecha_Venc, Rubro_Descripcion, Estado, Espec_Empresa_Cuit)
SELECT DISTINCT
  m.Espectaculo_Cod,
  m.Espectaculo_Descripcion,
  m.Espectaculo_Fecha,
  m.Espectaculo_Fecha_Venc,
  m.Espectaculo_Rubro_Descripcion,
  m.Espectaculo_Estado,
  m.Espec_Empresa_Cuit
FROM LOS_FRANCES.Master_With_PK AS m
GO

-- Insert Cliente from MASTER to new_database
INSERT INTO LOS_FRANCES.Cliente
  (Cli_Dni, Apelido, Nombre, Fecha_Nac, Mail, Dom_Calle, Nro_Calle, Piso, Depto, Cod_Postal)
SELECT DISTINCT
  m.Cli_Dni,
  m.Cli_Apeliido,
  m.Cli_Nombre,
  m.Cli_Fecha_Nac,
  m.Cli_Mail,
  m.Cli_Dom_Calle,
  m.Cli_Nro_Calle,
  m.Cli_Piso,
  m.Cli_Depto,
  m.Cli_Cod_Postal
FROM LOS_FRANCES.Master_With_PK m
WHERE m.Cli_Dni IS NOT NULL
GO

-- Insert Factura from MASTER to new_database
INSERT INTO LOS_FRANCES.Factura
  (Factura_Nro, Fecha, Total, Pago_Desc, Espectaculo_Cod)
SELECT DISTINCT
  m.Factura_Nro,
  m.Factura_Fecha,
  m.Factura_Total,
  m.Forma_Pago_Desc,
  m.Espectaculo_Cod
FROM LOS_FRANCES.Master_With_PK m
WHERE m.Factura_Nro IS NOT NULL
GO

-- Insert Compra from MASTER to new_database
INSERT INTO LOS_FRANCES.Compra
  (Compra_Id, Fecha, Cantidad, Cli_Dni)
SELECT
  m.Compra_Id,
  m.Compra_Fecha,
  m.Compra_Cantidad,
  m.Cli_Dni
FROM LOS_FRANCES.Master_With_PK m
WHERE m.Compra_Fecha IS NOT NULL
GO

-- Insert Item Factura from MASTER to new_database
INSERT INTO LOS_FRANCES.Item_Factura
  (Item_Factura_Id, Monto, Cantidad, Descripcion, Compra_Id)
SELECT DISTINCT
  m.Item_Factura_Id,
  m.Item_Factura_Monto,
  m.Item_Factura_Cantidad,
  m.Item_Factura_Descripcion,
  m.Compra_Id
FROM LOS_FRANCES.Master_With_PK m
WHERE m.Item_Factura_Monto IS NOT NULL
GO

-- Insert Ubicacion Tipo from MASTER to new_database
INSERT INTO LOS_FRANCES.Ubicacion_Tipo
  (Ubicacion_Tipo_Codigo, Descripcion)
SELECT
  DISTINCT
  m.Ubicacion_Tipo_Codigo,
  m.Ubicacion_Tipo_Descripcion
FROM LOS_FRANCES.Master_With_PK m
GO

-- Two-step insertion to avoid dublicate foreign key from compra
-- insert lines with compra
INSERT INTO LOS_FRANCES.Ubicacion
  (Ubicacion_Id, Fila, Asiento, Sin_numerar, Precio, Compra_Id, Espectaculo_Cod, Ubicacion_Tipo_Codigo)
SELECT
  m.Ubicacion_Id,
  m.Ubicacion_Fila,
  m.Ubicacion_Asiento,
  m.Ubicacion_Sin_numerar,
  m.Ubicacion_Precio,
  m.Compra_Id,
  m.Espectaculo_Cod,
  m.Ubicacion_Tipo_Codigo
FROM LOS_FRANCES.Master_With_PK m
WHERE m.Compra_Fecha IS NOT NULL;
GO

-- insert lines without compra
INSERT INTO LOS_FRANCES.Ubicacion
  (Ubicacion_Id, Fila, Asiento, Sin_numerar, Precio, Espectaculo_Cod, Ubicacion_Tipo_Codigo)
SELECT
  m.Ubicacion_Id,
  m.Ubicacion_Fila,
  m.Ubicacion_Asiento,
  m.Ubicacion_Sin_numerar,
  m.Ubicacion_Precio,
  m.Espectaculo_Cod,
  m.Ubicacion_Tipo_Codigo
FROM LOS_FRANCES.Master_With_PK m
WHERE m.Compra_Fecha IS NULL;
GO


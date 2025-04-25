-- Creación de la base de datos (SQL Server)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'GestorFichajes')
BEGIN
    CREATE DATABASE GestorFichajes;
END
GO

USE GestorFichajes;
GO

-- Tabla DEPARTAMENTO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DEPARTAMENTO')
BEGIN
    CREATE TABLE DEPARTAMENTO (
        ID_Departamento INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(50) NOT NULL,
        Descripcion NVARCHAR(200),
        ID_Responsable INT NULL
    );
END
GO

-- Tabla PUESTO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PUESTO')
BEGIN
    CREATE TABLE PUESTO (
        ID_Puesto INT IDENTITY(1,1) PRIMARY KEY,
        Nombre_Puesto NVARCHAR(50) NOT NULL,
        Descripcion NVARCHAR(200),
        Salario_Base DECIMAL(10,2) NOT NULL
    );
END
GO

-- Tabla EMPLEADO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EMPLEADO')
BEGIN
    CREATE TABLE EMPLEADO (
        ID_Empleado INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(50) NOT NULL,
        Apellidos NVARCHAR(100) NOT NULL,
        DNI_NIF NVARCHAR(20) NOT NULL UNIQUE,
        Fecha_Nacimiento DATE,
        Direccion NVARCHAR(200),
        Telefono NVARCHAR(20),
        Email NVARCHAR(100),
        Fecha_Contratacion DATE NOT NULL,
        ID_Departamento INT NULL,
        ID_Puesto INT NOT NULL
    );
    
    -- Añadir las claves foráneas después de crear la tabla
    ALTER TABLE EMPLEADO
    ADD CONSTRAINT FK_Empleado_Departamento
    FOREIGN KEY (ID_Departamento) REFERENCES DEPARTAMENTO(ID_Departamento);
    
    ALTER TABLE EMPLEADO
    ADD CONSTRAINT FK_Empleado_Puesto
    FOREIGN KEY (ID_Puesto) REFERENCES PUESTO(ID_Puesto);
END
GO

-- Actualizar la relación de responsable en DEPARTAMENTO
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'DEPARTAMENTO')
BEGIN
    ALTER TABLE DEPARTAMENTO
    ADD CONSTRAINT FK_Responsable_Empleado
    FOREIGN KEY (ID_Responsable) REFERENCES EMPLEADO(ID_Empleado);
END
GO

-- Tabla HORARIO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'HORARIO')
BEGIN
    CREATE TABLE HORARIO (
        ID_Horario INT IDENTITY(1,1) PRIMARY KEY,
        ID_Empleado INT NOT NULL,
        Dia_Semana NVARCHAR(10) NOT NULL CHECK (Dia_Semana IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo')),
        Hora_Entrada TIME NOT NULL,
        Hora_Salida TIME NOT NULL,
        Flexible BIT DEFAULT 0,
        CONSTRAINT UQ_Horario_Empleado_Dia UNIQUE (ID_Empleado, Dia_Semana),
        CONSTRAINT FK_Horario_Empleado FOREIGN KEY (ID_Empleado) REFERENCES EMPLEADO(ID_Empleado)
    );
END
GO

-- Tabla FICHAJE
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FICHAJE')
BEGIN
    CREATE TABLE FICHAJE (
        ID_Fichaje INT IDENTITY(1,1) PRIMARY KEY,
        ID_Empleado INT NOT NULL,
        Fecha_Hora_Entrada DATETIME NOT NULL,
        Fecha_Hora_Salida DATETIME NULL,
        Tipo_Fichaje NVARCHAR(10) NOT NULL CHECK (Tipo_Fichaje IN ('Entrada', 'Salida')),
        Metodo_Fichaje NVARCHAR(10) NOT NULL CHECK (Metodo_Fichaje IN ('Tarjeta', 'Huella', 'Facial', 'Web', 'App')),
        Ubicacion_Fichaje NVARCHAR(100),
        Estado NVARCHAR(20) NOT NULL CHECK (Estado IN ('Normal', 'Retraso', 'Ausencia', 'Horas Extra', 'Conflicto')),
        CONSTRAINT FK_Fichaje_Empleado FOREIGN KEY (ID_Empleado) REFERENCES EMPLEADO(ID_Empleado)
    );
    
    -- Crear índices
    CREATE INDEX IX_Fichaje_Entrada ON FICHAJE(Fecha_Hora_Entrada);
    CREATE INDEX IX_Fichaje_Salida ON FICHAJE(Fecha_Hora_Salida);
END
GO

-- Tabla VACACIONES
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VACACIONES')
BEGIN
    CREATE TABLE VACACIONES (
        ID_Vacaciones INT IDENTITY(1,1) PRIMARY KEY,
        ID_Empleado INT NOT NULL,
        Fecha_Inicio DATE NOT NULL,
        Fecha_Fin DATE NOT NULL,
        Estado NVARCHAR(10) NOT NULL DEFAULT 'Pendiente' CHECK (Estado IN ('Aprobado', 'Pendiente', 'Rechazado')),
        Motivo NVARCHAR(200),
        CONSTRAINT FK_Vacaciones_Empleado FOREIGN KEY (ID_Empleado) REFERENCES EMPLEADO(ID_Empleado),
        CONSTRAINT CK_Vacaciones_Fechas CHECK (Fecha_Inicio <= Fecha_Fin)
    );
END
GO

-- Tabla PERMISO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PERMISO')
BEGIN
    CREATE TABLE PERMISO (
        ID_Permiso INT IDENTITY(1,1) PRIMARY KEY,
        ID_Empleado INT NOT NULL,
        Fecha DATE NOT NULL,
        Horas DECIMAL(4,2) NOT NULL,
        Motivo NVARCHAR(200) NOT NULL,
        Estado NVARCHAR(10) NOT NULL DEFAULT 'Pendiente' CHECK (Estado IN ('Aprobado', 'Pendiente', 'Rechazado')),
        CONSTRAINT FK_Permiso_Empleado FOREIGN KEY (ID_Empleado) REFERENCES EMPLEADO(ID_Empleado)
    );
END
GO

-- Tabla INCIDENCIA
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'INCIDENCIA')
BEGIN
    CREATE TABLE INCIDENCIA (
        ID_Incidencia INT IDENTITY(1,1) PRIMARY KEY,
        ID_Empleado INT NOT NULL,
        Tipo NVARCHAR(20) NOT NULL CHECK (Tipo IN ('Retraso', 'Ausencia', 'Conflicto Horario', 'Fichaje Erróneo', 'Otro')),
        Descripcion NVARCHAR(500) NOT NULL,
        Fecha DATE NOT NULL,
        Resuelta BIT DEFAULT 0,
        CONSTRAINT FK_Incidencia_Empleado FOREIGN KEY (ID_Empleado) REFERENCES EMPLEADO(ID_Empleado)
    );
END
GO

-- Tabla HISTORIAL_PUESTO (opcional)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'HISTORIAL_PUESTO')
BEGIN
    CREATE TABLE HISTORIAL_PUESTO (
        ID_Historial INT IDENTITY(1,1) PRIMARY KEY,
        ID_Empleado INT NOT NULL,
        ID_Puesto_Anterior INT NULL,
        ID_Puesto_Nuevo INT NOT NULL,
        Fecha_Cambio DATE NOT NULL,
        Motivo NVARCHAR(200),
        CONSTRAINT FK_Historial_Empleado FOREIGN KEY (ID_Empleado) REFERENCES EMPLEADO(ID_Empleado),
        CONSTRAINT FK_Historial_Puesto_Anterior FOREIGN KEY (ID_Puesto_Anterior) REFERENCES PUESTO(ID_Puesto),
        CONSTRAINT FK_Historial_Puesto_Nuevo FOREIGN KEY (ID_Puesto_Nuevo) REFERENCES PUESTO(ID_Puesto)
    );
END
GO

-- Tabla AUSENCIA (opcional para bajas médicas)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AUSENCIA')
BEGIN
    CREATE TABLE AUSENCIA (
        ID_Ausencia INT IDENTITY(1,1) PRIMARY KEY,
        ID_Empleado INT NOT NULL,
        Tipo NVARCHAR(20) NOT NULL CHECK (Tipo IN ('Enfermedad', 'Accidente', 'Maternidad', 'Paternidad', 'Otro')),
        Fecha_Inicio DATE NOT NULL,
        Fecha_Fin DATE NULL,
        Certificado BIT DEFAULT 0,
        Observaciones NVARCHAR(500),
        CONSTRAINT FK_Ausencia_Empleado FOREIGN KEY (ID_Empleado) REFERENCES EMPLEADO(ID_Empleado),
        CONSTRAINT CK_Ausencia_Fechas CHECK (Fecha_Inicio <= Fecha_Fin)
    );
END
GO

-- Creación de vistas útiles

-- Vista para resumen de fichajes por empleado
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vista_Resumen_Fichajes')
    DROP VIEW Vista_Resumen_Fichajes;
GO

CREATE VIEW Vista_Resumen_Fichajes AS
SELECT 
    e.ID_Empleado,
    CONCAT(e.Nombre, ' ', e.Apellidos) AS Nombre_Completo,
    d.Nombre AS Departamento,
    p.Nombre_Puesto AS Puesto,
    COUNT(f.ID_Fichaje) AS Total_Fichajes,
    SUM(DATEDIFF(HOUR, f.Fecha_Hora_Entrada, f.Fecha_Hora_Salida)) AS Horas_Trabajadas
FROM EMPLEADO e
LEFT JOIN DEPARTAMENTO d ON e.ID_Departamento = d.ID_Departamento
LEFT JOIN PUESTO p ON e.ID_Puesto = p.ID_Puesto
LEFT JOIN FICHAJE f ON e.ID_Empleado = f.ID_Empleado
GROUP BY e.ID_Empleado, e.Nombre, e.Apellidos, d.Nombre, p.Nombre_Puesto;
GO

-- Vista para incidencias pendientes
IF EXISTS (SELECT * FROM sys.views WHERE name = 'Vista_Incidencias_Pendientes')
    DROP VIEW Vista_Incidencias_Pendientes;
GO

CREATE VIEW Vista_Incidencias_Pendientes AS
SELECT 
    i.ID_Incidencia,
    CONCAT(e.Nombre, ' ', e.Apellidos) AS Nombre_Empleado,
    i.Tipo,
    i.Descripcion,
    i.Fecha,
    d.Nombre AS Departamento
FROM INCIDENCIA i
JOIN EMPLEADO e ON i.ID_Empleado = e.ID_Empleado
LEFT JOIN DEPARTAMENTO d ON e.ID_Departamento = d.ID_Departamento
WHERE i.Resuelta = 0;
GO

-- Procedimientos almacenados útiles

-- Procedimiento para registrar un fichaje
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'RegistrarFichaje')
    DROP PROCEDURE RegistrarFichaje;
GO

CREATE PROCEDURE RegistrarFichaje
    @p_ID_Empleado INT,
    @p_Tipo NVARCHAR(10),
    @p_Metodo NVARCHAR(10),
    @p_Ubicacion NVARCHAR(100)
AS
BEGIN
    DECLARE @v_Estado NVARCHAR(20);
    DECLARE @v_Hora_Referencia TIME;
    DECLARE @v_Hora_Actual TIME;
    DECLARE @v_Dia_Semana NVARCHAR(10);
    
    SET @v_Hora_Actual = CONVERT(TIME, GETDATE());
    SET @v_Dia_Semana = DATENAME(WEEKDAY, GETDATE());
    
    -- Obtener el horario del empleado para el día actual
    SELECT @v_Hora_Referencia = Hora_Entrada
    FROM HORARIO
    WHERE ID_Empleado = @p_ID_Empleado AND Dia_Semana = @v_Dia_Semana;
    
    -- Determinar el estado del fichaje
    IF @p_Tipo = 'Entrada'
    BEGIN
        IF @v_Hora_Referencia IS NULL
            SET @v_Estado = 'Normal';
        ELSE IF @v_Hora_Actual > DATEADD(MINUTE, 15, @v_Hora_Referencia)
            SET @v_Estado = 'Retraso';
        ELSE
            SET @v_Estado = 'Normal';
        
        INSERT INTO FICHAJE (ID_Empleado, Fecha_Hora_Entrada, Tipo_Fichaje, Metodo_Fichaje, Ubicacion_Fichaje, Estado)
        VALUES (@p_ID_Empleado, GETDATE(), @p_Tipo, @p_Metodo, @p_Ubicacion, @v_Estado);
    END
    ELSE
    BEGIN
        -- Para fichajes de salida, actualizamos el registro de entrada correspondiente
        UPDATE FICHAJE 
        SET 
            Fecha_Hora_Salida = GETDATE(),
            Tipo_Fichaje = @p_Tipo,
            Metodo_Fichaje = @p_Metodo,
            Ubicacion_Fichaje = @p_Ubicacion
        WHERE 
            ID_Empleado = @p_ID_Empleado AND 
            CONVERT(DATE, Fecha_Hora_Entrada) = CONVERT(DATE, GETDATE()) AND
            Fecha_Hora_Salida IS NULL;
    END
END;
GO

-- Procedimiento para calcular horas trabajadas en un período
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'CalcularHorasTrabajadas')
    DROP PROCEDURE CalcularHorasTrabajadas;
GO

CREATE PROCEDURE CalcularHorasTrabajadas
    @p_ID_Empleado INT,
    @p_Fecha_Inicio DATE,
    @p_Fecha_Fin DATE,
    @p_Horas_Normales DECIMAL(10,2) OUTPUT,
    @p_Horas_Extras DECIMAL(10,2) OUTPUT
AS
BEGIN
    -- Calcular horas normales
    SELECT @p_Horas_Normales = ISNULL(SUM(DATEDIFF(HOUR, Fecha_Hora_Entrada, Fecha_Hora_Salida)), 0)
    FROM FICHAJE
    WHERE 
        ID_Empleado = @p_ID_Empleado AND
        CONVERT(DATE, Fecha_Hora_Entrada) BETWEEN @p_Fecha_Inicio AND @p_Fecha_Fin AND
        Estado = 'Normal';
    
    -- Calcular horas extras
    SELECT @p_Horas_Extras = ISNULL(SUM(DATEDIFF(HOUR, Fecha_Hora_Entrada, Fecha_Hora_Salida)), 0)
    FROM FICHAJE
    WHERE 
        ID_Empleado = @p_ID_Empleado AND
        CONVERT(DATE, Fecha_Hora_Entrada) BETWEEN @p_Fecha_Inicio AND @p_Fecha_Fin AND
        Estado = 'Horas Extra';
END;
GO
USE [FichAPP]
GO
/****** Object:  Table [dbo].[DEPARTAMENTO]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DEPARTAMENTO](
	[ID_Departamento] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[Descripcion] [nvarchar](200) NULL,
	[ID_Responsable] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_Departamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PUESTO]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PUESTO](
	[ID_Puesto] [int] IDENTITY(1,1) NOT NULL,
	[Nombre_Puesto] [nvarchar](50) NOT NULL,
	[Descripcion] [nvarchar](200) NULL,
	[Salario_Base] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_Puesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EMPLEADO]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EMPLEADO](
	[ID_Empleado] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[Apellidos] [nvarchar](100) NOT NULL,
	[DNI_NIF] [nvarchar](20) NOT NULL,
	[Fecha_Nacimiento] [date] NULL,
	[Direccion] [nvarchar](200) NULL,
	[Telefono] [nvarchar](20) NULL,
	[Email] [nvarchar](100) NULL,
	[Contrasenia] [nvarchar](8) NULL,
	[Fecha_Contratacion] [date] NOT NULL,
	[ID_Departamento] [int] NULL,
	[ID_Puesto] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_Empleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[DNI_NIF] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FICHAJE]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FICHAJE](
	[ID_Fichaje] [int] IDENTITY(1,1) NOT NULL,
	[ID_Empleado] [int] NOT NULL,
	[Fecha_Hora_Entrada] [datetime] NOT NULL,
	[Fecha_Hora_Salida] [datetime] NULL,
	[Tipo_Fichaje] [nvarchar](10) NOT NULL,
	[Metodo_Fichaje] [nvarchar](10) NOT NULL,
	[Ubicacion_Fichaje] [nvarchar](100) NULL,
	[Estado] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_Fichaje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Vista_Resumen_Fichajes]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Creación de vistas útiles

-- Vista para resumen de fichajes por empleado
CREATE VIEW [dbo].[Vista_Resumen_Fichajes] AS
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
/****** Object:  Table [dbo].[INCIDENCIA]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[INCIDENCIA](
	[ID_Incidencia] [int] IDENTITY(1,1) NOT NULL,
	[ID_Empleado] [int] NOT NULL,
	[Tipo] [nvarchar](20) NOT NULL,
	[Descripcion] [nvarchar](500) NOT NULL,
	[Fecha] [date] NOT NULL,
	[Resuelta] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_Incidencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Vista_Incidencias_Pendientes]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Vista para incidencias pendientes
CREATE VIEW [dbo].[Vista_Incidencias_Pendientes] AS
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
/****** Object:  Table [dbo].[AUSENCIA]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AUSENCIA](
	[ID_Ausencia] [int] IDENTITY(1,1) NOT NULL,
	[ID_Empleado] [int] NOT NULL,
	[Tipo] [nvarchar](20) NOT NULL,
	[Fecha_Inicio] [date] NOT NULL,
	[Fecha_Fin] [date] NULL,
	[Certificado] [bit] NULL,
	[Observaciones] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_Ausencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HISTORIAL_PUESTO]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HISTORIAL_PUESTO](
	[ID_Historial] [int] IDENTITY(1,1) NOT NULL,
	[ID_Empleado] [int] NOT NULL,
	[ID_Puesto_Anterior] [int] NULL,
	[ID_Puesto_Nuevo] [int] NOT NULL,
	[Fecha_Cambio] [date] NOT NULL,
	[Motivo] [nvarchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_Historial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HORARIO]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HORARIO](
	[ID_Horario] [int] IDENTITY(1,1) NOT NULL,
	[ID_Empleado] [int] NOT NULL,
	[Dia_Semana] [nvarchar](10) NOT NULL,
	[Hora_Entrada] [time](7) NOT NULL,
	[Hora_Salida] [time](7) NOT NULL,
	[Flexible] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_Horario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Horario_Empleado_Dia] UNIQUE NONCLUSTERED 
(
	[ID_Empleado] ASC,
	[Dia_Semana] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PERMISO]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PERMISO](
	[ID_Permiso] [int] IDENTITY(1,1) NOT NULL,
	[ID_Empleado] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[Horas] [decimal](4, 2) NOT NULL,
	[Motivo] [nvarchar](200) NOT NULL,
	[Estado] [nvarchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_Permiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VACACIONES]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VACACIONES](
	[ID_Vacaciones] [int] IDENTITY(1,1) NOT NULL,
	[ID_Empleado] [int] NOT NULL,
	[Fecha_Inicio] [date] NOT NULL,
	[Fecha_Fin] [date] NOT NULL,
	[Estado] [nvarchar](10) NOT NULL,
	[Motivo] [nvarchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_Vacaciones] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AUSENCIA] ADD  DEFAULT ((0)) FOR [Certificado]
GO
ALTER TABLE [dbo].[HORARIO] ADD  DEFAULT ((0)) FOR [Flexible]
GO
ALTER TABLE [dbo].[INCIDENCIA] ADD  DEFAULT ((0)) FOR [Resuelta]
GO
ALTER TABLE [dbo].[PERMISO] ADD  DEFAULT ('Pendiente') FOR [Estado]
GO
ALTER TABLE [dbo].[VACACIONES] ADD  DEFAULT ('Pendiente') FOR [Estado]
GO
ALTER TABLE [dbo].[AUSENCIA]  WITH CHECK ADD  CONSTRAINT [FK_Ausencia_Empleado] FOREIGN KEY([ID_Empleado])
REFERENCES [dbo].[EMPLEADO] ([ID_Empleado])
GO
ALTER TABLE [dbo].[AUSENCIA] CHECK CONSTRAINT [FK_Ausencia_Empleado]
GO
ALTER TABLE [dbo].[DEPARTAMENTO]  WITH CHECK ADD  CONSTRAINT [FK_Responsable_Empleado] FOREIGN KEY([ID_Responsable])
REFERENCES [dbo].[EMPLEADO] ([ID_Empleado])
GO
ALTER TABLE [dbo].[DEPARTAMENTO] CHECK CONSTRAINT [FK_Responsable_Empleado]
GO
ALTER TABLE [dbo].[EMPLEADO]  WITH CHECK ADD  CONSTRAINT [FK_Empleado_Departamento] FOREIGN KEY([ID_Departamento])
REFERENCES [dbo].[DEPARTAMENTO] ([ID_Departamento])
GO
ALTER TABLE [dbo].[EMPLEADO] CHECK CONSTRAINT [FK_Empleado_Departamento]
GO
ALTER TABLE [dbo].[EMPLEADO]  WITH CHECK ADD  CONSTRAINT [FK_Empleado_Puesto] FOREIGN KEY([ID_Puesto])
REFERENCES [dbo].[PUESTO] ([ID_Puesto])
GO
ALTER TABLE [dbo].[EMPLEADO] CHECK CONSTRAINT [FK_Empleado_Puesto]
GO
ALTER TABLE [dbo].[FICHAJE]  WITH CHECK ADD  CONSTRAINT [FK_Fichaje_Empleado] FOREIGN KEY([ID_Empleado])
REFERENCES [dbo].[EMPLEADO] ([ID_Empleado])
GO
ALTER TABLE [dbo].[FICHAJE] CHECK CONSTRAINT [FK_Fichaje_Empleado]
GO
ALTER TABLE [dbo].[HISTORIAL_PUESTO]  WITH CHECK ADD  CONSTRAINT [FK_Historial_Empleado] FOREIGN KEY([ID_Empleado])
REFERENCES [dbo].[EMPLEADO] ([ID_Empleado])
GO
ALTER TABLE [dbo].[HISTORIAL_PUESTO] CHECK CONSTRAINT [FK_Historial_Empleado]
GO
ALTER TABLE [dbo].[HISTORIAL_PUESTO]  WITH CHECK ADD  CONSTRAINT [FK_Historial_Puesto_Anterior] FOREIGN KEY([ID_Puesto_Anterior])
REFERENCES [dbo].[PUESTO] ([ID_Puesto])
GO
ALTER TABLE [dbo].[HISTORIAL_PUESTO] CHECK CONSTRAINT [FK_Historial_Puesto_Anterior]
GO
ALTER TABLE [dbo].[HISTORIAL_PUESTO]  WITH CHECK ADD  CONSTRAINT [FK_Historial_Puesto_Nuevo] FOREIGN KEY([ID_Puesto_Nuevo])
REFERENCES [dbo].[PUESTO] ([ID_Puesto])
GO
ALTER TABLE [dbo].[HISTORIAL_PUESTO] CHECK CONSTRAINT [FK_Historial_Puesto_Nuevo]
GO
ALTER TABLE [dbo].[HORARIO]  WITH CHECK ADD  CONSTRAINT [FK_Horario_Empleado] FOREIGN KEY([ID_Empleado])
REFERENCES [dbo].[EMPLEADO] ([ID_Empleado])
GO
ALTER TABLE [dbo].[HORARIO] CHECK CONSTRAINT [FK_Horario_Empleado]
GO
ALTER TABLE [dbo].[INCIDENCIA]  WITH CHECK ADD  CONSTRAINT [FK_Incidencia_Empleado] FOREIGN KEY([ID_Empleado])
REFERENCES [dbo].[EMPLEADO] ([ID_Empleado])
GO
ALTER TABLE [dbo].[INCIDENCIA] CHECK CONSTRAINT [FK_Incidencia_Empleado]
GO
ALTER TABLE [dbo].[PERMISO]  WITH CHECK ADD  CONSTRAINT [FK_Permiso_Empleado] FOREIGN KEY([ID_Empleado])
REFERENCES [dbo].[EMPLEADO] ([ID_Empleado])
GO
ALTER TABLE [dbo].[PERMISO] CHECK CONSTRAINT [FK_Permiso_Empleado]
GO
ALTER TABLE [dbo].[VACACIONES]  WITH CHECK ADD  CONSTRAINT [FK_Vacaciones_Empleado] FOREIGN KEY([ID_Empleado])
REFERENCES [dbo].[EMPLEADO] ([ID_Empleado])
GO
ALTER TABLE [dbo].[VACACIONES] CHECK CONSTRAINT [FK_Vacaciones_Empleado]
GO
ALTER TABLE [dbo].[AUSENCIA]  WITH CHECK ADD CHECK  (([Tipo]='Otro' OR [Tipo]='Paternidad' OR [Tipo]='Maternidad' OR [Tipo]='Accidente' OR [Tipo]='Enfermedad'))
GO
ALTER TABLE [dbo].[AUSENCIA]  WITH CHECK ADD  CONSTRAINT [CK_Ausencia_Fechas] CHECK  (([Fecha_Inicio]<=[Fecha_Fin]))
GO
ALTER TABLE [dbo].[AUSENCIA] CHECK CONSTRAINT [CK_Ausencia_Fechas]
GO
ALTER TABLE [dbo].[FICHAJE]  WITH CHECK ADD CHECK  (([Estado]='Conflicto' OR [Estado]='Horas Extra' OR [Estado]='Ausencia' OR [Estado]='Retraso' OR [Estado]='Normal'))
GO
ALTER TABLE [dbo].[FICHAJE]  WITH CHECK ADD CHECK  (([Metodo_Fichaje]='App' OR [Metodo_Fichaje]='Web' OR [Metodo_Fichaje]='Facial' OR [Metodo_Fichaje]='Huella' OR [Metodo_Fichaje]='Tarjeta'))
GO
ALTER TABLE [dbo].[FICHAJE]  WITH CHECK ADD CHECK  (([Tipo_Fichaje]='Salida' OR [Tipo_Fichaje]='Entrada'))
GO
ALTER TABLE [dbo].[HORARIO]  WITH CHECK ADD CHECK  (([Dia_Semana]='Domingo' OR [Dia_Semana]='Sábado' OR [Dia_Semana]='Viernes' OR [Dia_Semana]='Jueves' OR [Dia_Semana]='Miércoles' OR [Dia_Semana]='Martes' OR [Dia_Semana]='Lunes'))
GO
ALTER TABLE [dbo].[INCIDENCIA]  WITH CHECK ADD CHECK  (([Tipo]='Otro' OR [Tipo]='Fichaje Erróneo' OR [Tipo]='Conflicto Horario' OR [Tipo]='Ausencia' OR [Tipo]='Retraso'))
GO
ALTER TABLE [dbo].[PERMISO]  WITH CHECK ADD CHECK  (([Estado]='Rechazado' OR [Estado]='Pendiente' OR [Estado]='Aprobado'))
GO
ALTER TABLE [dbo].[VACACIONES]  WITH CHECK ADD CHECK  (([Estado]='Rechazado' OR [Estado]='Pendiente' OR [Estado]='Aprobado'))
GO
ALTER TABLE [dbo].[VACACIONES]  WITH CHECK ADD  CONSTRAINT [CK_Vacaciones_Fechas] CHECK  (([Fecha_Inicio]<=[Fecha_Fin]))
GO
ALTER TABLE [dbo].[VACACIONES] CHECK CONSTRAINT [CK_Vacaciones_Fechas]
GO
/****** Object:  StoredProcedure [dbo].[CalcularHorasTrabajadas]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedimiento para calcular horas trabajadas en un período
CREATE PROCEDURE [dbo].[CalcularHorasTrabajadas]
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
/****** Object:  StoredProcedure [dbo].[RegistrarFichaje]    Script Date: 17/05/2025 9:06:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedimientos almacenados útiles

-- Procedimiento para registrar un fichaje
CREATE PROCEDURE [dbo].[RegistrarFichaje]
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

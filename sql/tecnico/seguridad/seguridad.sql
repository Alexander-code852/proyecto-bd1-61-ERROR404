USE color_y_pincel;
GO

-- 1. Creación de Logins y Usuarios de prueba
CREATE LOGIN usuario_lector_local WITH PASSWORD = 'LectorPassword123*';
CREATE USER usuario_lector_local FOR LOGIN usuario_lector_local;
GO

-- 2. Creación de Rol Personalizado para consultas de catálogo
CREATE ROLE rol_consultor_catalogo;
GO

-- 3. Asignación de permisos específicos al rol
GRANT SELECT ON dbo.productos TO rol_consultor_catalogo;
GO

-- 4. Asociar usuario al rol
ALTER ROLE rol_consultor_catalogo ADD MEMBER usuario_lector_local;
GO

-- 5. Permiso de ejecución sobre procedimiento almacenado seguro
GRANT EXECUTE ON dbo.sp_RegistrarVentaSimple TO usuario_lector_local;
GO



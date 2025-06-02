# Taller Junio 2 – Disparadores en Bases de Datos Relacionales
Autor: David Andrés Cuadrado  
Base de Datos II – Taller
Junio 2025

¿Qué son los Disparadores?

Los disparadores o triggers son bloques de código que se ejecutan automáticamente en una base de datos cuando ocurre un evento específico sobre una tabla o una vista. Estos eventos pueden ser operaciones como inserción (INSERT), actualización (UPDATE) o eliminación (DELETE). 

Los disparadores permiten reaccionar de forma inmediata a estos cambios en los datos, sin necesidad de que la aplicación que interactúa con la base de datos los invoque directamente. Se utilizan principalmente para mantener la integridad de los datos, validar información, realizar auditorías o aplicar reglas de negocio automáticamente.

¿Para qué sirven los Disparadores?

- Permiten automatizar tareas cuando se modifican los datos.
- Ayudan a mantener la integridad de los datos dentro de la base de datos.
- Son útiles para registrar automáticamente cambios importantes (auditoría).
- Permiten validar datos antes de que sean guardados o modificados.
- Ayudan a sincronizar o replicar datos entre tablas.

Ventajas

- Reducen la necesidad de implementar reglas de validación en el código de la aplicación.
- Garantizan que ciertas acciones siempre ocurran ante cambios en los datos.
- Facilitan la implementación de auditorías, como guardar historial de cambios.
- Permiten controlar eventos sensibles directamente desde el motor de base de datos.

Desventajas

- Pueden dificultar el mantenimiento si hay muchos disparadores ocultos en la base de datos.
- Hacen más difícil la depuración de errores, ya que no se ven desde la aplicación.
- Si no se diseñan correctamente, pueden afectar negativamente el rendimiento.
- Generan una mayor dependencia de la lógica de negocio con la base de datos.

Sintaxis General

La sintaxis de los disparadores depende del sistema de gestión de base de datos (como PostgreSQL, MySQL, SQL Server, etc.), pero en términos generales se escribe así:

CREATE TRIGGER nombre_del_disparador
BEFORE o AFTER (INSERT, UPDATE o DELETE)
ON nombre_de_la_tabla
FOR EACH ROW
BEGIN
    instrucciones a ejecutar
END;

Tipos de disparadores

- BEFORE: Se ejecuta antes de que el evento ocurra. Se usa para validaciones o transformaciones.
- AFTER: Se ejecuta después de que el evento haya ocurrido. Se usa para auditorías o acciones complementarias.
- INSTEAD OF: Reemplaza la acción original (común en vistas).

Consideraciones Finales

Los disparadores deben usarse con responsabilidad. Aunque son muy útiles, si se abusa de ellos pueden volver la base de datos difícil de entender y mantener. Siempre se deben documentar, probar cuidadosamente y evitar ciclos infinitos o encadenamiento de disparadores que afecten el rendimiento general del sistema.


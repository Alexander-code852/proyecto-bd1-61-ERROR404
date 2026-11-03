Los índices son estructuras auxiliares que optimizan la recuperación de datos en el motor de almacenamiento de SQL Server, evitando costosos recorridos secuenciales completos (Table Scan) sobre las tablas.   

Como ventaja podemos decir que mejoran drásticamente los tiempos de respuesta y reducen las lecturas lógicas de E/S en reportes analíticos por rangos de fechas o grandes volúmenes de datos transaccionales.   

Aplicado en nuestro problema: evaluar el impacto de rendimiento al consultar una tabla histórica de ventas mediante índices agrupados (Clustered Index) y no agrupados con cobertura (Nonclustered Index with INCLUDE).  


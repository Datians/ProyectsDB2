#  Operadores Lógicos en MongoDB
Estudiante: David Andrés Cuadrado
Código: 1007536804
---

## Estructura de la Base de Datos

- **Nombre de la base de datos:** `OperadoresMongo`
- **Colección:** `operadores_logicos`

Cada documento dentro de la colección contiene los siguientes campos:

- `nombre`: nombre del operador lógico.
- `descripcion`: definición y propósito del operador.
- `estructura`: forma estructural en la que se utiliza el operador.
- `ejemplo`: ejemplo práctico de uso en una consulta.

---

## Inserción de Datos

Los datos son insertados mediante el script `insertar_operadores.js`, utilizando la biblioteca oficial de MongoDB para Node.js. El script se conecta al servidor de base de datos local y realiza la inserción de los operadores lógicos.

---

## Ejecución del Script

Para ejecutar el proyecto, se deben seguir los siguientes pasos:

1. Instalar dependencias:

```bash
npm install mongodb
```

2. Ejecutar el archivo:

```bash
node insertar_operadores.js
```

---

## Consultas en MongoDB

A continuación, se muestran los comandos para consultar los documentos insertados en la colección `operadores_logicos`.

### Consultar todos los operadores:

```javascript
db.operadores_logicos.find().pretty()
```

### Consultar un operador específico:

#### Operador `$and`:
```javascript
db.operadores_logicos.find({ nombre: "$and" }).pretty()
```

#### Operador `$or`:
```javascript
db.operadores_logicos.find({ nombre: "$or" }).pretty()
```

#### Operador `$not`:
```javascript
db.operadores_logicos.find({ nombre: "$not" }).pretty()
```

#### Operador `$nor`:
```javascript
db.operadores_logicos.find({ nombre: "$nor" }).pretty()
```

---

## Referencias

- MongoDB. *Logical Query Operators*: https://www.mongodb.com/docs/manual/reference/operator/query-logical/

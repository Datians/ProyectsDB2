const { MongoClient } = require("mongodb");

const uri = "mongodb://localhost:27017";
const client = new MongoClient(uri);

async function run() {
    try {
        await client.connect();
        const db = client.db("OperadoresMongo");
        const coleccion = db.collection("operadores_logicos");

        const operadores = [
            {
                nombre: "$and",
                descripcion: "Evalúa si todas las condiciones dentro del array son verdaderas.",
                estructura: "{ $and: [ { <expresión1> }, { <expresión2> } ] }",
                ejemplo: "{ $and: [ { edad: { $gt: 18 } }, { activo: true } ] }"
            },
            {
                nombre: "$or",
                descripcion: "Evalúa si al menos una condición dentro del array es verdadera.",
                estructura: "{ $or: [ { <expresión1> }, { <expresión2> } ] }",
                ejemplo: "{ $or: [ { ciudad: 'Bogotá' }, { ciudad: 'Medellín' } ] }"
            },
            {
                nombre: "$not",
                descripcion: "Invierte el resultado de una condición.",
                estructura: "{ campo: { $not: { <operador-condición> } } }",
                ejemplo: "{ puntuacion: { $not: { $gte: 90 } } }"
            },
            {
                nombre: "$nor",
                descripcion: "Evalúa como verdadero si ninguna de las condiciones es verdadera.",
                estructura: "{ $nor: [ { <expresión1> }, { <expresión2> } ] }",
                ejemplo: "{ $nor: [ { activo: true }, { edad: { $lt: 18 } } ] }"
            }
        ];

        const resultado = await coleccion.insertMany(operadores);
        console.log("Documentos insertados:", resultado.insertedCount);

    } catch (err) {
        console.error("Error al conectar o insertar:", err);
    } finally {
        await client.close();
    }
}

run();

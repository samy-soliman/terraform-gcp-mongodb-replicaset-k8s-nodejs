const { MongoClient } = require('mongodb');
const express = require('express')
const app = express()

const WEBport = process.env.WEBport || 3000
const DBuser = process.env.DBuser
const DBpass = process.env.DBpass
const DBhosts = process.env.DBhosts

async function main() {

    //const uri = `mongodb://drage:secretpassword123@mongodb-0.mongodb-headless.database:27017/inventory`;

    const uri = `mongodb://${DBuser}:${DBpass}@${DBhosts}/test-mongodb`;

    const client = new MongoClient(uri);

    try {

        await client.connect();

        let db = client.db("test-mongodb")
        let coll = db.collection("visits")

        let collectionExists = await coll.findOne({id: "count"}).then(r => r);
        collectionExists ? true : await coll.insertOne({id: "count", total: 0})

        app.get('/', async (req, res) => {
            await client.connect();
            current = await coll.findOne({id: "count"}).then(r => r.total)
            latest = await coll.updateOne({id: "count"}, {$set: {total: current+1}})
            // console.log("Visits: " + (current+1))
            res.send("Visits: " + (current+1))
            await client.close();
          })

        app.listen(WEBport, () => {
        console.log(`App is listening on port ${WEBport}`)
        })

    } catch (e) {
        console.error(e);
    } finally {
        await client.close();
    }
}

main().catch(console.error);

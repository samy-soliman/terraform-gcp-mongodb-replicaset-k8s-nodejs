const { MongoClient } = require('mongodb');
const express = require('express');
const app = express();

const WEBport = process.env.WEBport || 3000;
const DBuser = process.env.DBuser;
const DBpass = process.env.DBpass;
const DBhosts = process.env.DBhosts;

const mongoConnectRetryInterval = 5000; // 5 seconds (adjust as needed)

async function connectToMongoDB() {
  const uri = `mongodb://${DBuser}:${DBpass}@${DBhosts}/test?readPreference=nearest&replicaSet=rs0&authSource=admin`;
  const client = new MongoClient(uri);

  try {
    await client.connect();
    return client;
  } catch (error) {
    console.error('MongoDB connection error:', error);
    // Retry the connection after a delay
    await new Promise((resolve) => setTimeout(resolve, mongoConnectRetryInterval));
    return connectToMongoDB();
  }
}

async function main() {
  let client;

  try {
    client = await connectToMongoDB();

    let db = client.db("test");
    let coll = db.collection("visits");

    let collectionExists = await coll.findOne({ id: "count" }).then((r) => r);
    collectionExists ? true : await coll.insertOne({ id: "count", total: 0 });

    app.get('/', async (req, res) => {
      current = await coll.findOne({ id: "count" }).then((r) => r.total);
      latest = await coll.updateOne({ id: "count" }, { $set: { total: current + 1 } });
      res.send("Visits: " + (current + 1));
    });

    app.listen(WEBport, () => {
      console.log(`App is listening on port ${WEBport}`);
    });
  } catch (e) {
    console.error(e);
  } finally {
    if (client) {
      await client.close();
    }
  }
}

main().catch(console.error);

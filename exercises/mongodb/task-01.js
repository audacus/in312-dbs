// a)
/*

docker run --name mongo-server -p 27017:27017 -d mongo
docker cp personen.json mongo-server:/tmp
docker exec -it mongo-server bash
mongoimport --db verein --collection personen --drop --file /tmp/personen.json
mongosh

show dbs
use verein
show collections
*/

db.personen.find();
db.personen.find().pretty();
db.personen.findOne();

/* select */
// search
db.personen.find({ name: "Bart" });
// nested search
db.personen.find({ "mentor.mentorid": 10 });
// output fields
db.personen.find({}, { name: 1, vorname: 1 });
// get name of all presidents
db.personen.find(
  { funktionsbesetzungen: { $elemMatch: { bezeichner: "Präsidium" } } },
  { name: 1 }
);
// insert into personen
db.personen.insertOne(
    { vorname: 'john', name: 'doe', strasseNr: 'strasse 123', plz: '1234', ort: 'ortschaft' }
)
// search for inserted
db.personen.find({ _id: new ObjectId("63cacc544820e2b5dce52234") })
// group by lowercase `ort`
db.personen.aggregate([ { $group: { _id: { $toLower: "$ort" }, num_pers: { $sum: 1 } } }])

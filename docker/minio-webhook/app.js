var http = require('http');

/*
This is what comes in from minio:
{ EventName: "s3:ObjectCreated:Put",
  Key: "buck1/chestnut-horse-autumn_1000.jpg",
  Records: [ { eventVersion: "2.0",
               eventSource: "minio:s3",
               awsRegion: "",
               eventTime: "2018-04-20T17:50:47Z",
               eventName: "s3:ObjectCreated:Put",
               userIdentity: { principalId: "minio"
                             },
               requestParameters: { sourceIPAddress: "10.128.0.1:54668"
                                  },
               responseElements:{ "x-amz-request-id":"1527363FEB08D78E",
                                  "x-minio-origin-endpoint":"http://10.130.0.135:9000"
                                },
               s3: { s3SchemaVersion: "1.0",
                     configurationId: "Config",
                     bucket:{ name:"buck1",
                              ownerIdentity:{
                                principalId: "minio"
                              },
                              arn: "arn:aws:s3:::buck1"
                            },
                     object: { key: "chestnut-horse-autumn_1000.jpg",
                               size:177559,
                               eTag:"9c449f88502bd2e80e9a4b627640f2d2",
                               contentType: "image/jpeg",
                               userMetadata: { content-type: "image/jpeg"
                                             },
                               versionId: "1",
                               sequencer: "1527363FEB08D78E"
                             }
                   },
               source: { host: "",
                         port: "",
                         userAgent: ""
                       }
             }
           ]
}
This is what we send to the wsk trigger:
{ message: { ... see above ... }
*/

const express = require('express');
const bodyParser = require('body-parser');
const app = express().use(bodyParser.json());
const Minio = require('minio')
const minioClient = new Minio.Client({
  endPoint: 'minio',
  port: 9099,
  useSSL: false,
  accessKey: process.env.ACCESS_KEY,
  secretKey: process.env.ACCESS_SECRET
});
const dataBucket = process.env.DATA_BUCKET;

app.post('/', async (req, res, next) => {
  const filePath = req.body.Key;
  const locatioPath = filePath.split('/').slice(0, -2).join('/')
  const objectsList = await new Promise((resolve, reject) => {
    const objectsListTemp = [];
    const stream = minioClient.listObjects(dataBucket, locatioPath.substring(locatioPath.indexOf('/') + 1), true);
    stream.on('data', obj => objectsListTemp.push(obj.name));
    stream.on('error', reject);
    stream.on('end', () => {
      resolve(objectsListTemp);
    });
  });


  if (objectsList && objectsList.length > 1) {
    objectsList.pop();
    minioClient.removeObjects(dataBucket, objectsList, function (e) {
      if (e) {
        return console.log('Unable to remove Objects ', e)
      }
      console.log('Removed the objects successfully')
    })
  }

  return res.json({ "status": "okay" })
});

app.get('/', (req, res) => res.send('Minio Webhook'))

const HOST = process.env.HOST || '0.0.0.0';
const PORT = process.env.PORT || 3000;
app.listen(PORT, HOST);
console.log(`Minio Webhook Running on http://${HOST}:${PORT}`);
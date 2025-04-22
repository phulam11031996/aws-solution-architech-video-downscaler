/* eslint no-undef: "off" */
/* eslint-disable @typescript-eslint/no-require-imports */
const express = require('express');
const cors = require('cors');
const AWS = require('aws-sdk');

const app = express();
const PORT = process.env.PORT || 80;

// Middleware for parsing JSON and URL-encoded request bodies
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(
  cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  })
);

// Set up AWS SDK
const s3 = new AWS.S3();
const sns = new AWS.SNS({
  region: process.env.AWS_REGION,
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Endpoint to get both GET and PUT presigned URLs for the same object
app.post('/api', (req, res) => {
  const bucketName = 'video-scaler-bucket-phulam1103';
  const contentType = req.body.fileType;

  const generateRandomFilename = () => {
    const timestamp = Date.now();
    const randomString = Math.random().toString(36).substring(2, 10);
    return `${timestamp}-${randomString}`;
  };

  const generatePresignedUrls = (fileName) => {
    return new Promise((resolve, reject) => {
      s3.getSignedUrl(
        'putObject',
        {
          Key: fileName,
          Bucket: bucketName,
          ContentType: contentType,
        },
        (err, putUrl) => {
          if (err) return reject(err);
          s3.getSignedUrl(
            'getObject',
            {
              Key: fileName,
              Bucket: bucketName,
            },
            (err, getUrl) => {
              if (err) return reject(err);
              resolve({ putUrl, getUrl });
            }
          );
        }
      );
    });
  };

  (async () => {
    try {
      const fileNamePostfix = generateRandomFilename();
      const mineType = contentType.split('/')[1];

      const [x0Urls, x1Urls, x2Urls, x3Urls] = await Promise.all([
        generatePresignedUrls(`${fileNamePostfix}/x0.${mineType}`),
        generatePresignedUrls(`${fileNamePostfix}/x1.${mineType}`),
        generatePresignedUrls(`${fileNamePostfix}/x2.${mineType}`),
        generatePresignedUrls(`${fileNamePostfix}/x3.${mineType}`),
      ]);

      const responsePayload = {
        downScaleX0: {
          putPresignedUrl: x0Urls.putUrl,
          getPresignedUrl: x0Urls.getUrl,
        },
        downScaleX1: {
          putPresignedUrl: x1Urls.putUrl,
          getPresignedUrl: x1Urls.getUrl,
        },
        downScaleX2: {
          putPresignedUrl: x2Urls.putUrl,
          getPresignedUrl: x2Urls.getUrl,
        },
        downScaleX3: {
          putPresignedUrl: x3Urls.putUrl,
          getPresignedUrl: x3Urls.getUrl,
        },
      };

      const snsMessage = {
        ...responsePayload,
        timestamp: Date.now(),
      };

      const snsParams = {
        TopicArn: process.env.TOPIC_ARN,
        Message: JSON.stringify(snsMessage),
      };

      await sns.publish(snsParams).promise();

      res.json(responsePayload);
    } catch (error) {
      console.error('Error generating presigned URLs', error);
      res.status(500).json({ error: 'Failed to generate presigned URLs' });
    }
  })();
});

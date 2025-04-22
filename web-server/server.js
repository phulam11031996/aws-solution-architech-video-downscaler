/* eslint no-undef: "off" */
import express from 'express';
import cors from 'cors';
import AWS from 'aws-sdk';

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

  const generateRandomFilename = (prefix, contentType) => {
    const timestamp = Date.now();
    const mineType = contentType.split('/')[1];
    const randomString = Math.random().toString(36).substring(2, 10);
    return `${prefix}${timestamp}-${randomString}.${mineType}`;
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
      const originalFileName = generateRandomFilename('original-', contentType);
      const downscaleX1File = generateRandomFilename('x1-', contentType);
      const downscaleX2File = generateRandomFilename('x2-', contentType);
      const downscaleX3File = generateRandomFilename('x3-', contentType);

      const [originalUrls, x1Urls, x2Urls, x3Urls] = await Promise.all([
        generatePresignedUrls(originalFileName),
        generatePresignedUrls(downscaleX1File),
        generatePresignedUrls(downscaleX2File),
        generatePresignedUrls(downscaleX3File),
      ]);

      const snsMessage = {
        original: originalFileName,
        x1: downscaleX1File,
        x2: downscaleX2File,
        x3: downscaleX3File,
        contentType,
        timestamp: Date.now(),
      };

      const snsParams = {
        TopicArn: process.env.TOPIC_ARN,
        Message: JSON.stringify(snsMessage),
      };

      await sns.publish(snsParams).promise();

      res.json({
        downScaleX0: {
          fileName: originalFileName,
          putPresignedUrl: originalUrls.putUrl,
          getPresignedUrl: originalUrls.getUrl,
        },
        downScaleX1: {
          fileName: downscaleX1File,
          putPresignedUrl: x1Urls.putUrl,
          getPresignedUrl: x1Urls.getUrl,
        },
        downScaleX2: {
          fileName: downscaleX2File,
          putPresignedUrl: x2Urls.putUrl,
          getPresignedUrl: x2Urls.getUrl,
        },
        downScaleX3: {
          fileName: downscaleX3File,
          putPresignedUrl: x3Urls.putUrl,
          getPresignedUrl: x3Urls.getUrl,
        },
      });
    } catch (error) {
      console.error('Error generating presigned URLs', error);
      res.status(500).json({ error: 'Failed to generate presigned URLs' });
    }
  })();
});

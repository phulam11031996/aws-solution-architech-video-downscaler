/* eslint no-undef: "off" */
/* eslint-disable @typescript-eslint/no-require-imports */
const express = require('express');
const cors = require('cors');
const AWS = require('aws-sdk');
import { Request, Response } from 'express';

const app = express();
const PORT = process.env.PORT || 80;

const S3_BUCKET_NAME = process.env.S3_BUCKET_NAME;

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

// --- TYPES ---
type PresignedUrl = {
  putPresignedUrl: string;
  getPresignedUrl: string;
};

type DownscaleResponsePayload = {
  downScaleX0: PresignedUrl;
  downScaleX1: PresignedUrl;
  downScaleX2: PresignedUrl;
  downScaleX3: PresignedUrl;
};

type DownscaleRequestBody = {
  fileType: string;
};

/* eslint-disable @typescript-eslint/no-empty-object-type */
type DownscalreRequestData = {};
/* eslint-disable @typescript-eslint/no-empty-object-type */
type DownscaleRequestQuery = {};

// --- ROUTE HANDLER ---
app.post(
  '/downscale-videos',
  async (
    req: Request<DownscalreRequestData, DownscaleRequestQuery, DownscaleRequestBody>,
    res: Response<DownscaleResponsePayload>
  ) => {
    const contentType = req.body.fileType;

    const generateRandomFilename = (): string => {
      const timestamp = Date.now();
      const randomString = Math.random().toString(36).substring(2, 10);
      return `${timestamp}-${randomString}`;
    };

    const generatePresignedUrls = (fileName: string): Promise<PresignedUrl> => {
      return new Promise((resolve, reject) => {
        s3.getSignedUrl(
          'putObject',
          {
            Key: fileName,
            Bucket: S3_BUCKET_NAME,
            ContentType: contentType,
          },
          (err, putUrl) => {
            if (err || !putUrl) return reject(err);
            s3.getSignedUrl(
              'getObject',
              {
                Key: fileName,
                Bucket: S3_BUCKET_NAME,
              },
              (err, getUrl) => {
                if (err || !getUrl) return reject(err);
                resolve({ putPresignedUrl: putUrl, getPresignedUrl: getUrl });
              }
            );
          }
        );
      });
    };

    try {
      const fileNamePostfix = generateRandomFilename();
      const mimeType = contentType.split('/')[1];

      const [x0Urls, x1Urls, x2Urls, x3Urls] = await Promise.all([
        generatePresignedUrls(`${fileNamePostfix}/x0.${mimeType}`),
        generatePresignedUrls(`${fileNamePostfix}/x1.${mimeType}`),
        generatePresignedUrls(`${fileNamePostfix}/x2.${mimeType}`),
        generatePresignedUrls(`${fileNamePostfix}/x3.${mimeType}`),
      ]);

      const responsePayload: DownscaleResponsePayload = {
        downScaleX0: x0Urls,
        downScaleX1: x1Urls,
        downScaleX2: x2Urls,
        downScaleX3: x3Urls,
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
      res
        .status(500)
        .json({ error: 'Failed to generate presigned URLs' });
    }
  }
);

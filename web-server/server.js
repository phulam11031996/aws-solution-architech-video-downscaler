const express = require("express");
const cors = require("cors"); // Import CORS package
const AWS = require("aws-sdk");

const app = express();
const PORT = process.env.PORT || 80;

// Enable CORS for all requests and methods
app.use(
  cors({
    origin: "*", // Allow requests from any origin
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"], // Allow all methods
    allowedHeaders: ["Content-Type", "Authorization"], // Allow common headers
    credentials: true, // Allow credentials (if needed)
  }),
);

// Set up AWS SDK for S3
const s3 = new AWS.S3();

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

// Endpoint to get both GET and PUT presigned URLs for the same object
app.get("/api", (req, res) => {
  const bucketName = "video-scaler-bucket-phulam1103";

  const generateRandomFilename = (prefix = "") => {
    const timestamp = Date.now();
    const randomString = Math.random().toString(36).substring(2, 10);
    return `${prefix}${timestamp}-${randomString}.mp4`;
  };

  const generatePresignedUrls = (fileName) => {
    const params = {
      Bucket: bucketName,
      Key: fileName,
      Expires: 60,
    };

    return new Promise((resolve, reject) => {
      s3.getSignedUrl("putObject", params, (err, putUrl) => {
        if (err) return reject(err);
        s3.getSignedUrl("getObject", params, (err, getUrl) => {
          if (err) return reject(err);
          resolve({ putUrl, getUrl });
        });
      });
    });
  };

  (async () => {
    try {
      const originalFileName = generateRandomFilename("original-");
      const downscaleX1File = generateRandomFilename("x1-");
      const downscaleX2File = generateRandomFilename("x2-");
      const downscaleX3File = generateRandomFilename("x3-");

      const [originalUrls, x1Urls, x2Urls, x3Urls] = await Promise.all([
        generatePresignedUrls(originalFileName),
        generatePresignedUrls(downscaleX1File),
        generatePresignedUrls(downscaleX2File),
        generatePresignedUrls(downscaleX3File),
      ]);

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
      console.error("Error generating presigned URLs", error);
      res.status(500).json({ error: "Failed to generate presigned URLs" });
    }
  })();
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

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
  const bucketName = "video-scaler-bucket-phulam1103"; // your S3 bucket name

  const generateRandomFilename = () => {
    const timestamp = Date.now(); // Get current timestamp
    const randomString = Math.random().toString(36).substring(2, 10); // Generate a random alphanumeric string
    return `${timestamp}-${randomString}.txt`; // Example file extension
  };
  const fileName = generateRandomFilename(); // Generate a random filename

  if (!fileName) {
    return res.status(400).json({ error: "Missing fileName parameter" });
  }

  const params = {
    Bucket: bucketName,
    Key: fileName,
    Expires: 60, // URL expiry time in seconds
  };

  // Generate GET presigned URL (for downloading)
  s3.getSignedUrl("getObject", params, (err, getUrl) => {
    if (err) {
      console.error("Error generating GET presigned URL", err);
      return res
        .status(500)
        .json({ error: "Failed to generate GET presigned URL" });
    }

    // Generate PUT presigned URL (for uploading)
    s3.getSignedUrl("putObject", params, (err, putUrl) => {
      if (err) {
        console.error("Error generating PUT presigned URL", err);
        return res
          .status(500)
          .json({ error: "Failed to generate PUT presigned URL" });
      }

      // Return both GET and PUT URLs in the response
      res.json({
        getUrl,
        putUrl,
      });
    });
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

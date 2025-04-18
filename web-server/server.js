const express = require("express");
const cors = require("cors"); // Import CORS package

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

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

app.get("/api", (req, res) => {
  console.log("Received GET request");
  res.json({ message: "Hello from EC2 Web Server!" });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

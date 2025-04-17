import React from "react";
import { Button } from "@/components/ui/button";
import { useState } from "react";

function App() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  React.useEffect(() => {
    // This is a React (not React Native) implementation of cropImageFromURL
    const cropImageFromURL = (
      url: string,
      cropWidth = 200,
      cropHeight = 200,
      cropX = 0,
      cropY = 0,
    ) => {
      // Create a new image object
      const img = new Image();

      // Set crossOrigin to allow processing images from other domains
      // Note: The server hosting the image must allow CORS for this to work
      img.crossOrigin = "Anonymous";

      // When the image loads, perform the cropping
      img.onload = () => {
        // Create a canvas element
        const canvas = document.createElement("canvas");
        const ctx = canvas.getContext("2d");

        if (!ctx) {
          console.error("Could not get canvas context");
          return;
        }

        // Set canvas dimensions to the crop size
        canvas.width = cropWidth;
        canvas.height = cropHeight;

        // Draw the portion of the image we want to crop onto the canvas
        ctx.drawImage(
          img,
          cropX,
          cropY, // Start point of the source image
          cropWidth,
          cropHeight, // Width and height of the source to use
          0,
          0, // Placement on the canvas
          cropWidth,
          cropHeight, // Size on the canvas
        );

        // Convert the canvas to a data URL
        const croppedImageDataURL = canvas.toDataURL("image/jpeg");

        // Log the result (base64 data URL of the cropped image)
        console.log(
          "Cropped image:",
          croppedImageDataURL.substring(0, 50) + "...",
        );

        // You could return this value or do something else with it here
        return croppedImageDataURL;
      };

      // Set the image source to the provided URL
      img.src = url;

      // Handle errors
      img.onerror = (error) => {
        console.error("Error loading image for cropping:", error);
      };
    };

    cropImageFromURL(
      "https://thumbs.dreamstime.com/b/environment-earth-day-hands-trees-growing-seedlings-bokeh-green-background-female-hand-holding-tree-nature-field-118143566.jpg",
    );
  }, []);

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100 p-4">
      <h1 className="text-2xl font-bold mb-4">React App Calling EC2 API</h1>
      {loading && <p>Loading...</p>}
      {error && <p className="text-red-500 mt-2">Error: {error}</p>}
      {data && (
        <pre className="bg-white p-4 rounded shadow-md mt-4">
          {JSON.stringify(data, null, 2)}
        </pre>
      )}
      <p>test</p>
    </div>
  );
}

export default App;

import { Button } from "@/components/ui/button";
import { useState } from "react";

function App() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const fetchData = () => {
    setLoading(true);
    setError(null);

    // Replace with your actual EC2 web server URL
    const apiUrl = "http://localhost:3000/api";

    fetch(apiUrl)
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then((data) => {
        setData(data);
        setLoading(false);
      })
      .catch((error) => {
        setError(error.message);
        setLoading(false);
      });
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100 p-4">
      <h1 className="text-2xl font-bold mb-4">React App Calling EC2 API</h1>
      <Button
        onClick={fetchData}
      >
        Fetch Data
      </Button>
      {loading && <p>Loading...</p>}
      {error && <p className="text-red-500 mt-2">Error: {error}</p>}
      {data && (
        <pre className="bg-white p-4 rounded shadow-md mt-4">
          {JSON.stringify(data, null, 2)}
        </pre>
      )}
    </div>
  );
}

export default App;

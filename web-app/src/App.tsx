import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Loader2 } from 'lucide-react';
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { useRef, useState } from 'react';

function App() {
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  const uploadVideo = async () => {
    setLoading(true);
    setError(null);

    const file = fileInputRef.current?.files?.[0];

    if (!file) {
      setError('Please select a video file to upload.');
      setLoading(false);
      return;
    }

    try {
      const response = await fetch('downscale-videos', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          fileType: file.type,
        }),
      });
      if (!response.ok) {
        throw new Error('Failed to get presigned URLs');
      }

      const data = await response.json();
      const { putPresignedUrl, fileName } = data.downScaleX0;

      const uploadResponse = await fetch(putPresignedUrl, {
        headers: {
          'Content-Type': file.type,
        },
        method: 'PUT',
        body: file,
      });

      if (!uploadResponse.ok) {
        throw new Error('Failed to upload video to S3');
      }

      console.log('Video uploaded to S3 successfully', fileName);
    } catch (err: unknown) {
      if (err instanceof Error) {
        console.error('Error uploading video:', err);
        setError(err.message || 'Something went wrong');
      } else {
        console.error('Unknown error uploading video:', err);
        setError('Something went wrong');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-black text-white">
      <Card className="w-[350px] bg-white text-black">
        <CardHeader>
          <CardTitle>Upload Video</CardTitle>
          <CardDescription>
            Upload a video to downscale the video
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form>
            <div className="grid w-full items-center gap-4">
              <div className="flex flex-col space-y-1.5">
                <Label htmlFor="video">Video</Label>
                <Input
                  ref={fileInputRef}
                  id="video"
                  type="file"
                  accept="video/*"
                />
              </div>
            </div>
          </form>
        </CardContent>
        <CardFooter className="flex justify-between">
          <Button variant="outline">Cancel</Button>
          <Button onClick={uploadVideo} disabled={loading}>
            {loading ? (
              <>
                <Loader2 className="animate-spin mr-2" />
                Please wait
              </>
            ) : (
              'Upload Video'
            )}
          </Button>
        </CardFooter>
        <CardFooter className="flex justify-between">
          {error && <div className="text-red-500 text-sm mt-2">{error}</div>}
        </CardFooter>
      </Card>
    </div>
  );
}

export default App;

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Download, Loader2, Check } from 'lucide-react';
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';

import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import sample2 from '@/assets/sample-videos/sample-video-2.mp4';
import sample3 from '@/assets/sample-videos/sample-video-3.mp4';

import { useRef, useState, useEffect } from 'react';
import { getPresignedUrls, uploadToS3 } from '@/services/api';

// Define download status types
type DownloadStatus = 'idle' | 'loading' | 'ready' | 'downloaded';

// Define row data type with status tracking and file size
interface RowDataItem {
  id: number;
  fileName: string;
  originalFileSize: string;
  downScaleX1: {
    putPresignedUrl: string;
    getPresignedUrl: string;
    status: DownloadStatus;
    fileSize?: string;
  };
  downScaleX2: {
    putPresignedUrl: string;
    getPresignedUrl: string;
    status: DownloadStatus;
    fileSize?: string;
  };
  downScaleX3: {
    putPresignedUrl: string;
    getPresignedUrl: string;
    status: DownloadStatus;
    fileSize?: string;
  };
}

function App() {
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const [isFileSelected, setIsFileSelected] = useState(false);
  const [rowData, setRowData] = useState<RowDataItem[]>([]);
  const [isUploading, setIsUploading] = useState(false);
  const [isSampleUploading, setIsSampleUploading] = useState(false);

  const uploadSampleVideo = async (url: string, fileName: string) => {
    setIsSampleUploading(true);
    try {
      const response = await fetch(url);
      const blob = await response.blob();
      const file = new File([blob], fileName, { type: blob.type });

      // Create a DataTransfer to simulate file input
      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(file);

      if (fileInputRef.current) {
        fileInputRef.current.files = dataTransfer.files;

        // Trigger onChange manually if needed
        const event = new Event('change', { bubbles: true });
        fileInputRef.current.dispatchEvent(event);
      }
      const sleep = (ms: number) =>
        new Promise((resolve) => setTimeout(resolve, ms));
      await sleep(5000);

      setIsFileSelected(true); // Optional, in case you want to manually update state
    } catch (err) {
      console.error('Error preparing sample video:', err);
    } finally {
      setIsSampleUploading(false);
    }
  };

  // Function to format bytes to human-readable size
  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';

    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  // Function to poll for video processing status
  const pollForProcessingStatus = async (
    rowId: number,
    scaleType: 'downScaleX1' | 'downScaleX2' | 'downScaleX3',
  ) => {
    const row = rowData.find((r) => r.id === rowId);
    if (!row) return;

    try {
      // Poll the getPresignedUrl to check if the processed video is ready
      const response = await fetch(row[scaleType].getPresignedUrl, {
        method: 'GET', // Using HEAD to get headers without downloading the content
      });

      if (response.ok) {
        // Get content length from headers to determine file size
        const contentLength = response.headers.get('content-length');
        let fileSize = 'Unknown';

        if (contentLength) {
          fileSize = formatFileSize(parseInt(contentLength, 10));
        }

        // Video is ready, update the status and file size
        setRowData((prevData) =>
          prevData.map((item) =>
            item.id === rowId
              ? {
                  ...item,
                  [scaleType]: {
                    ...item[scaleType],
                    status: 'ready',
                    fileSize: fileSize,
                  },
                }
              : item,
          ),
        );
        return true;
      } else {
        // Continue polling
        return false;
      }
    } catch {
      // Continue polling if there's an error (resource might not be available yet)
      return false;
    }
  };

  // Setup polling at regular intervals for each "loading" status
  useEffect(() => {
    const pollingIntervals: NodeJS.Timeout[] = [];

    rowData.forEach((row) => {
      ['downScaleX1', 'downScaleX2', 'downScaleX3'].forEach((scaleType) => {
        const scale = scaleType as
          | 'downScaleX1'
          | 'downScaleX2'
          | 'downScaleX3';

        if (row[scale].status === 'loading') {
          const interval = setInterval(async () => {
            const isReady = await pollForProcessingStatus(row.id, scale);
            if (isReady) {
              clearInterval(interval);
            }
          }, 5000); // Poll every 5 seconds

          pollingIntervals.push(interval);
        }
      });
    });

    // Clean up intervals on unmount or when rowData changes
    return () => {
      pollingIntervals.forEach((interval) => clearInterval(interval));
    };
  }, [rowData]);

  const uploadVideo = async () => {
    setError(null);
    setIsUploading(true);

    const file = fileInputRef.current?.files?.[0];

    if (!file) {
      setError('Please select a video file to upload.');
      setIsUploading(false);
      return;
    }

    try {
      const data = await getPresignedUrls(file.type); // Get the presigned URLs from the service

      // Upload the original file to S3
      await uploadToS3(data.downScaleX0.putPresignedUrl, file);

      const newEntry: RowDataItem = {
        id: rowData.length + 1,
        fileName: file.name,
        originalFileSize: formatFileSize(file.size),
        downScaleX1: {
          ...data.downScaleX1,
          status: 'loading',
        },
        downScaleX2: {
          ...data.downScaleX2,
          status: 'loading',
        },
        downScaleX3: {
          ...data.downScaleX3,
          status: 'loading',
        },
      };

      setRowData((prev) => [...prev, newEntry]);

      console.log('Video uploaded to S3 successfully');
    } catch (err: unknown) {
      if (err instanceof Error) {
        console.error('Error uploading video:', err);
        setError(err.message || 'Something went wrong');
      } else {
        console.error('Unknown error uploading video:', err);
        setError('Something went wrong');
      }
    } finally {
      // Reset the file input after upload
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
      setIsFileSelected(false);
      setIsUploading(false);
    }
  };

  // Function to handle download using fetch
  const handleDownload = async (
    row: RowDataItem,
    scaleType: 'downScaleX1' | 'downScaleX2' | 'downScaleX3',
  ) => {
    try {
      // Set status to downloading
      setRowData((prevData) =>
        prevData.map((item) =>
          item.id === row.id
            ? {
                ...item,
                [scaleType]: {
                  ...item[scaleType],
                  status: 'downloading',
                },
              }
            : item,
        ),
      );

      // Fetch the file
      const response = await fetch(row[scaleType].getPresignedUrl);

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      // Get the blob from the response
      const blob = await response.blob();

      // Create an object URL for the blob
      const url = window.URL.createObjectURL(blob);

      // Create a download link and trigger it
      const link = document.createElement('a');
      link.href = url;
      link.download = `${row.fileName.split('.')[0]}.${row.fileName.split('.').pop()}`;
      document.body.appendChild(link);
      link.click();

      // Clean up
      window.URL.revokeObjectURL(url);
      document.body.removeChild(link);

      // Update status to downloaded
      setRowData((prevData) =>
        prevData.map((item) =>
          item.id === row.id
            ? {
                ...item,
                [scaleType]: {
                  ...item[scaleType],
                  status: 'downloaded',
                },
              }
            : item,
        ),
      );
    } catch (error) {
      console.error('Download error:', error);
      setError('Failed to download the video');

      // Reset status to ready on error
      setRowData((prevData) =>
        prevData.map((item) =>
          item.id === row.id
            ? {
                ...item,
                [scaleType]: {
                  ...item[scaleType],
                  status: 'ready',
                },
              }
            : item,
        ),
      );
    }
  };

  // Render button based on status
  const renderButton = (
    row: RowDataItem,
    scaleType: 'downScaleX1' | 'downScaleX2' | 'downScaleX3',
  ) => {
    const status = row[scaleType].status;
    const fileSize = row[scaleType].fileSize;

    switch (status) {
      case 'loading':
        return (
          <Button disabled>
            <Loader2 className="animate-spin" />
            Processing
          </Button>
        );
      case 'ready':
        return (
          <Button onClick={() => handleDownload(row, scaleType)}>
            <Download />
            {fileSize}
          </Button>
        );
      case 'downloaded':
        return (
          <Button variant="outline" className="text-green-500" disabled>
            <Check />
            {fileSize}
          </Button>
        );
      default:
        return (
          <Button disabled>
            <Download />
          </Button>
        );
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-start justify-start gap-4 p-4">
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
                  onChange={() => {
                    setIsFileSelected(!!fileInputRef.current?.files?.length);
                  }}
                />
              </div>
            </div>
          </form>
        </CardContent>
        <CardFooter className="flex justify-between items-center flex-wrap gap-2">
          <div className="flex gap-2 flex-wrap">
            <Button
              variant="outline"
              onClick={() => uploadSampleVideo(sample2, 'sample-video-2.mp4')}
              disabled={isSampleUploading}
            >
              Sample 1
            </Button>
            <Button
              variant="outline"
              onClick={() => uploadSampleVideo(sample3, 'sample-video-3.mp4')}
              disabled={isSampleUploading}
            >
              Sample 2
            </Button>
          </div>
        </CardFooter>

        <CardFooter className="flex justify-between">
          <Button
            onClick={uploadVideo}
            disabled={!isFileSelected || isUploading || isSampleUploading}
          >
            {isUploading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Uploading...
              </>
            ) : (
              'Upload'
            )}
          </Button>
        </CardFooter>
        {error && (
          <CardFooter className="flex justify-between">
            {error && <div className="text-red-500 text-sm mt-2">{error}</div>}
          </CardFooter>
        )}
      </Card>

      <Table>
        <TableCaption>A list of your downscale videos.</TableCaption>
        <TableHeader>
          <TableRow>
            <TableHead className="w-[100px]">ID</TableHead>
            <TableHead>File Name</TableHead>
            <TableHead>Original File Size</TableHead>
            <TableHead>Downscale x1</TableHead>
            <TableHead>Downscale x2</TableHead>
            <TableHead>Downscale x3</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {rowData.map((row) => (
            <TableRow key={row.id}>
              <TableCell className="font-medium">{row.id}</TableCell>
              <TableCell>{row.fileName}</TableCell>
              <TableCell>{row.originalFileSize}</TableCell>
              <TableCell>{renderButton(row, 'downScaleX1')}</TableCell>
              <TableCell>{renderButton(row, 'downScaleX2')}</TableCell>
              <TableCell>{renderButton(row, 'downScaleX3')}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}

export default App;

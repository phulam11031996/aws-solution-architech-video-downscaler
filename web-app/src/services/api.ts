interface VideoResponse {
  downScaleX0: {
    putPresignedUrl: string;
    getPresignedUrl: string;
  };
  downScaleX1: {
    putPresignedUrl: string;
    getPresignedUrl: string;
  };
  downScaleX2: {
    putPresignedUrl: string;
    getPresignedUrl: string;
  };
  downScaleX3: {
    putPresignedUrl: string;
    getPresignedUrl: string;
  };
}

export const getPresignedUrls = async (
  fileType: string,
): Promise<VideoResponse> => {
  try {
    const response = await fetch('downscale-videos', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ fileType }),
    });

    if (!response.ok) {
      throw new Error('Failed to get presigned URLs');
    }

    return await response.json();
    // return {
    //   downScaleX0: {
    //     putPresignedUrl: '',
    //     getPresignedUrl: '',
    //   },
    //   downScaleX1: {
    //     putPresignedUrl: '',
    //     getPresignedUrl: '',
    //   },
    //   downScaleX2: {
    //     putPresignedUrl: '',
    //     getPresignedUrl: '',
    //   },
    //   downScaleX3: {
    //     putPresignedUrl: '',
    //     getPresignedUrl: '',
    //   },
    // }
  } catch (error) {
    throw new Error(
      `Error fetching presigned URLs: ${error instanceof Error ? error.message : 'Unknown error'}`,
    );
  }
};

export const uploadToS3 = async (url: string, file: File): Promise<void> => {
  try {
    const uploadResponse = await fetch(url, {
      headers: {
        'Content-Type': file.type,
      },
      method: 'PUT',
      body: file,
    });

    if (!uploadResponse.ok) {
      throw new Error('Failed to upload video to S3');
    }

    console.log('Video uploaded to S3 successfully');
  } catch (error) {
    throw new Error(
      `Error uploading video: ${error instanceof Error ? error.message : 'Unknown error'}`,
    );
  }
};

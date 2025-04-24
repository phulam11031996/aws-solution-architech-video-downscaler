import { s3 } from '../config/aws';

const S3_BUCKET_NAME = process.env.S3_BUCKET_NAME!;

export const generatePutAndGetPresignedUrls = (
  s3Key: string,
  contentType: string
): Promise<{
  putPresignedUrl: string;
  getPresignedUrl: string;
}> => {
  const allowedTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'video/mp4',
    'video/quicktime',
  ];

  if (!allowedTypes.includes(contentType)) {
    throw new Error(`Unsupported content type: ${contentType}`);
  }

  return new Promise<{
    putPresignedUrl: string;
    getPresignedUrl: string;
  }>((resolve, reject) => {
    s3.getSignedUrl(
      'putObject',
      {
        Key: s3Key,
        Bucket: S3_BUCKET_NAME,
        ContentType: contentType,
      },
      (err, putUrl) => {
        if (err || !putUrl) return reject(err);
        s3.getSignedUrl(
          'getObject',
          {
            Key: s3Key,
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

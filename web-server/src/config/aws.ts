import { S3, SNS } from 'aws-sdk';

export const s3 = new S3();
export const sns = new SNS({ region: process.env.AWS_REGION });

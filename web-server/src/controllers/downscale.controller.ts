import { Request, Response } from 'express';
import { generateRandomFilename } from '../utils/generateFilename';
import { generatePutAndGetPresignedUrls } from '../services/s3.service';
import { publishSNSMessage } from '../services/sns.service';
import {
  DownscaleRequestBody,
  DownscaleRequestData,
  DownscaleRequestQuery,
  DownscaleResponsePayload,
} from '../types/downscale.types';

export const handleDownscale = async (
  req: Request<
    DownscaleRequestData,
    DownscaleRequestQuery,
    DownscaleRequestBody
  >,
  res: Response<DownscaleResponsePayload>
) => {
  const contentType = req.body.fileType;

  try {
    const postfix = generateRandomFilename();
    const ext = contentType.split('/')[1];

    const [x0, x1, x2, x3]: {
      putPresignedUrl: string;
      getPresignedUrl: string;
    }[] = await Promise.all([
      generatePutAndGetPresignedUrls(`${postfix}/x0.${ext}`, contentType),
      generatePutAndGetPresignedUrls(`${postfix}/x1.${ext}`, contentType),
      generatePutAndGetPresignedUrls(`${postfix}/x2.${ext}`, contentType),
      generatePutAndGetPresignedUrls(`${postfix}/x3.${ext}`, contentType),
    ]);

    const payload = {
      downScaleX0: x0,
      downScaleX1: x1,
      downScaleX2: x2,
      downScaleX3: x3,
    };

    await publishSNSMessage(payload);

    res.json(payload);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to generate presigned URLs' });
  }
};

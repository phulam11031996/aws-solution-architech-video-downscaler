export type PresignedUrl = {
  putPresignedUrl: string;
  getPresignedUrl: string;
};

export type DownscaleResponsePayload = {
  downScaleX0: PresignedUrl;
  downScaleX1: PresignedUrl;
  downScaleX2: PresignedUrl;
  downScaleX3: PresignedUrl;
};

export type DownscaleRequestBody = {
  fileType: string;
};

/* eslint-disable @typescript-eslint/no-empty-object-type */
export type DownscaleRequestData = {};
/* eslint-disable @typescript-eslint/no-empty-object-type */
export type DownscaleRequestQuery = {};

export type ErrorResponse = { error: string };
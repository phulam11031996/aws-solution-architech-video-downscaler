export const generateRandomFilename = (): string => {
  const timestamp = Date.now();
  const randomString = Math.random().toString(36).substring(2, 10);
  return `${timestamp}-${randomString}`;
};

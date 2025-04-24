// services/sns.service.ts
import { sns } from '../config/aws';

export const publishSNSMessage = async (payload: object) => {
  const message = {
    ...payload,
  };

  await sns
    .publish({
      TopicArn: process.env.TOPIC_ARN,
      Message: JSON.stringify(message),
    })
    .promise();
};

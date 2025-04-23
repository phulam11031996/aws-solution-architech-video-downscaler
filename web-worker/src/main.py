import asyncio
import json
import os

from dotenv import load_dotenv
from presigned_url_handler import PresignedURLHandler
from sqs_manager import SQSManager

load_dotenv()


async def main():
    SQS_QUEUE_URL = os.getenv("SQS_QUEUE_URL")
    AWS_REGION = os.getenv("AWS_REGION")
    if "x1" in SQS_QUEUE_URL:
        target_key = "downScaleX1"
    elif "x2" in SQS_QUEUE_URL:
        target_key = "downScaleX2"
    elif "x3" in SQS_QUEUE_URL:
        target_key = "downScaleX3"
    else:
        raise ValueError(f"Unknown target based on queue URL: {SQS_QUEUE_URL}")

    sqs_manager = SQSManager(region=AWS_REGION, queue_url=SQS_QUEUE_URL)
    handler = PresignedURLHandler(queue_url=SQS_QUEUE_URL, target_key=target_key)

    while True:
        # Poll for messages from SQS
        messages = sqs_manager.poll_for_sqs_message()

        for message in messages:
            try:
                print("Received message", flush=True)
                body = json.loads(message["Body"])

                # Poll for data from the SQS queue
                video_data = await handler.poll_for_original_video_data(body)

                # Upload the data to the presigned URL
                await handler.upload_to_put_presigned_url(video_data)

            except Exception as e:
                print(f"Error processing message: {e}")

            # Delete the message from SQS once processed
            sqs_manager.delete_message(message["ReceiptHandle"])

        # Poll every 5 seconds for new messages
        await asyncio.sleep(5)


if __name__ == "__main__":
    asyncio.run(main())

import asyncio
import json

from presigned_url_handler import PresignedURLHandler
from sqs_manager import SQSManager


async def main():
    sqs_manager = SQSManager()
    handler = PresignedURLHandler()

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

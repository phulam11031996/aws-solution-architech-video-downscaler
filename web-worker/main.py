import os
import time

import boto3
from dotenv import load_dotenv

load_dotenv()

# Ensure AWS_REGION is loaded from environment variables
AWS_REGION = os.getenv("AWS_REGION")
SQS_QUEUE_URL = os.getenv("SQS_QUEUE_URL")

# Create the SQS client with the specified region
sqs = boto3.client("sqs", region_name=AWS_REGION)


def main():

    while True:
        response = sqs.receive_message(
            QueueUrl=SQS_QUEUE_URL,
            AttributeNames=["All"],
            MaxNumberOfMessages=1,
            WaitTimeSeconds=20,
        )

        if "Messages" in response:
            # Print out the message body
            for message in response["Messages"]:
                print(f"Message Received: {SQS_QUEUE_URL}", flush=True)

                # Delete the message from the queue after processing
                sqs.delete_message(
                    QueueUrl=SQS_QUEUE_URL,
                    ReceiptHandle=message["ReceiptHandle"])

        time.sleep(5)


if __name__ == "__main__":
    main()

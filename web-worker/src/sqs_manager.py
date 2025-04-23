import os

import boto3
from dotenv import load_dotenv

load_dotenv()


class SQSManager:
    def __init__(self):
        region = os.getenv("AWS_REGION")
        self.queue_url = os.getenv("SQS_QUEUE_URL")
        self.client = boto3.client("sqs", region_name=region)

    def poll_for_sqs_message(self):
        response = self.client.receive_message(
            QueueUrl=self.queue_url,
            AttributeNames=["All"],
            MaxNumberOfMessages=1,
            WaitTimeSeconds=20,
        )
        return response.get("Messages", [])

    def delete_message(self, receipt_handle: str):
        self.client.delete_message(
            QueueUrl=self.queue_url,
            ReceiptHandle=receipt_handle,
        )
        print("Deleted Message", flush=True)

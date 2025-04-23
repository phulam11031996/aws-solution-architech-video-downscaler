import boto3


class SQSManager:
    def __init__(self, region: str, queue_url: str):
        self.client = boto3.client("sqs", region_name=region)
        self.queue_url = queue_url

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

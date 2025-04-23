import asyncio
import json
import os
import time

import aiohttp
from dotenv import load_dotenv

load_dotenv()


class PresignedURLHandler:
    def __init__(self, poll_interval: int = 5, timeout: int = 60):
        self.queue_url = os.getenv("SQS_QUEUE_URL")
        self.poll_interval = poll_interval
        self.timeout = timeout
        self.body = None

    async def poll_for_original_video_data(self, body: dict) -> bytes:
        self.body = json.loads(body.get("Message"))
        get_presigned_url = self.body.get("downScaleX0").get("getPresignedUrl")
        if not get_presigned_url:
            raise ValueError("Missing 'downScaleX0.getPresignedUrl' in message body")
        return await self.poll_for_data(get_presigned_url)

    async def poll_for_data(self, url: str) -> bytes:
        start_time = time.time()

        async with aiohttp.ClientSession() as session:
            while True:
                try:
                    async with session.get(url) as response:
                        if response.status == 200:
                            print("Downloaded data successfully", flush=True)
                            return await response.read()
                        else:
                            print("Polling for data...", flush=True)
                except aiohttp.ClientError as e:
                    print(f"Request failed: {e}")

                if time.time() - start_time > self.timeout:
                    raise TimeoutError(f"Timed out waiting for data at {url}")

                await asyncio.sleep(self.poll_interval)

    async def upload_to_put_presigned_url(self, video_data: bytes):
        target_key = None

        if "x1" in self.queue_url:
            target_key = "downScaleX1"
        elif "x2" in self.queue_url:
            target_key = "downScaleX2"
        elif "x3" in self.queue_url:
            target_key = "downScaleX3"
        else:
            raise ValueError(f"Unknown target based on queue URL: {self.queue_url}")

        put_presigned_url = self.body.get(target_key, {}).get("putPresignedUrl")
        if not put_presigned_url:
            raise ValueError(f"Missing '{target_key}.putPresignedUrl' in message body")

        try:
            async with aiohttp.ClientSession() as session:
                async with session.put(
                    url=put_presigned_url,
                    headers={"Content-Type": "video/mp4"},
                    data=video_data,
                ) as response:
                    if response.status == 200:
                        print("Uploaded data successfully", flush=True)
                    else:
                        raise Exception(f"Upload failed with status: {response.status}")
        except aiohttp.ClientError as e:
            raise Exception(f"Upload request failed: {e}")

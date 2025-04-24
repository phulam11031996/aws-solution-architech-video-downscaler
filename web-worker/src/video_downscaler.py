import os
import subprocess
import uuid
from tempfile import gettempdir


class VideoDownscaler:
    def __init__(self, target_key: str):
        scale = None
        if "downScaleX1" in target_key:
            scale = 0.5
        elif "downScaleX2" in target_key:
            scale = 0.25
        elif "downScaleX3" in target_key:
            scale = 0.125
        self.scale = scale
        self.temp_dir = gettempdir()

    def downscale(self, input_video_bytes: bytes) -> bytes:
        unique_id = uuid.uuid4().hex
        input_path = os.path.join(self.temp_dir, f"input-{unique_id}.mp4")
        output_path = os.path.join(
            self.temp_dir, f"output-{self.scale}-{unique_id}.mp4"
        )

        # Write input video to a temp file
        with open(input_path, "wb") as f:
            f.write(input_video_bytes)

        scale_filter = f"scale=iw*{self.scale}:ih*{self.scale}"
        cmd = [
            "ffmpeg",
            "-i",
            input_path,
            "-vf",
            scale_filter,
            "-c:v",
            "libx264",
            "-crf",
            "28",
            "-preset",
            "ultrafast",
            "-y",  # Overwrite without asking
            output_path,
        ]

        print(f"Downscaling video with FFmpeg to {self.scale * 100:.0f}% size...")
        subprocess.run(cmd, check=True)

        # Read the downscaled video
        with open(output_path, "rb") as f:
            output_bytes = f.read()

        print(f"Downscaled video size: {len(output_bytes)} bytes")

        # Clean up (optional - you can keep files for debugging)
        os.remove(input_path)
        os.remove(output_path)

        return output_bytes

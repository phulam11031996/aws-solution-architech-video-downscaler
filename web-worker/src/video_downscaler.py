import subprocess
import uuid


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

    def downscale(self, input_video_bytes: bytes) -> bytes:
        scale_filter = f"scale=iw*{self.scale}:ih*{self.scale}"
        cmd = [
            "ffmpeg",
            "-i",
            "pipe:0",  # Read from stdin
            "-vf",
            scale_filter,
            "-c:v",
            "libx264",
            "-crf",
            "28",
            "-preset",
            "ultrafast",
            "-f",
            "matroska",  # Use MKV format instead of MP4
            "pipe:1",  # Write to stdout
        ]

        print(f"Downscaling video with FFmpeg to {self.scale * 100:.0f}% size...")

        # Run ffmpeg with pipe communication
        process = subprocess.Popen(
            cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )

        # Send input data and get output
        output_bytes, stderr = process.communicate(input=input_video_bytes)

        # Check if the process was successful
        if process.returncode != 0:
            error_message = stderr.decode("utf-8", errors="replace")
            raise RuntimeError(
                f"FFmpeg error (code {process.returncode}): {error_message}"
            )

        print(f"Downscaled video size: {len(output_bytes)} bytes")
        return output_bytes

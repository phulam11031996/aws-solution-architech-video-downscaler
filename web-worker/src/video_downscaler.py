import subprocess


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
            "-y",
            "-loglevel",
            "error",
            "-i",
            "pipe:0",
            "-vf",
            scale_filter,
            "-c:v",
            "libx264",
            "-preset",
            "ultrafast",
            "-crf",
            "28",
            "-f",
            "mp4",
            "-movflags",
            "frag_keyframe+empty_moov",
            "pipe:1",
        ]

        print(f"Downscaling video with FFmpeg to {self.scale * 100:.0f}% size...")

        process = subprocess.Popen(
            cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )

        output_bytes, stderr = process.communicate(input=input_video_bytes)

        if process.returncode != 0:
            error_message = stderr.decode("utf-8", errors="replace")
            raise RuntimeError(
                f"FFmpeg error (code {process.returncode}): {error_message}"
            )

        print(f"Downscaled video size: {len(output_bytes)} bytes")
        return output_bytes

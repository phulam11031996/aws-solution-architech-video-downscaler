FROM python:3.10-slim

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt

# # Install FFmpeg (since it's not included in the slim image)
# RUN apt-get update && \
#     apt-get install -y ffmpeg && \
#     rm -rf /var/lib/apt/lists/*

CMD ["python", "main.py"]

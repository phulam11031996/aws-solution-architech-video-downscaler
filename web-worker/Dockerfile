FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install ffmpeg and other necessary packages
RUN apt-get update && \
    apt-get install -y ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Change to source directory
WORKDIR /app/src

# Set the entrypoint
CMD ["python", "main.py"]

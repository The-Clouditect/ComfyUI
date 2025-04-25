FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Add necessary system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app

# Install Python dependencies with specific versions to avoid conflicts
RUN pip install --no-cache-dir \
    torch==1.12.1+cu116 torchvision==0.13.1+cu116 --extra-index-url https://download.pytorch.org/whl/cu116 \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir xformers==0.0.16

# Create necessary directories
RUN mkdir -p /app/models/checkpoints \
    /app/models/loras \
    /app/models/controlnet \
    /app/models/upscale_models \
    /app/models/clip \
    /app/models/clip_vision \
    /app/output \
    /app/temp \
    /app/custom_nodes

# Set up volume mount points
VOLUME ["/app/models", "/app/output", "/app/temp", "/app/custom_nodes"]

# Expose port
EXPOSE 8188

# Environment variables
ENV PYTHONUNBUFFERED=1
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics

# Run ComfyUI with proper arguments
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
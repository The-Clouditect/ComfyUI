# Use Alpine Linux as base for smaller image size
FROM python:3.10-alpine

# Set working directory
WORKDIR /app

# Add necessary system dependencies
# Note: build-base and git are needed for some Python packages
RUN apk add --no-cache \
    build-base \
    git \
    ffmpeg \
    wget \
    curl \
    gcc \
    libc-dev \
    linux-headers \
    cmake \
    make \
    g++ \
    git \
    openblas-dev \
    py3-numpy-dev \
    python3-dev \
    libx11-dev \
    libxext-dev \
    mesa-dev \
    ninja \
    && rm -rf /var/cache/apk/*

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app

# Install Python dependencies
# Using separate RUN to avoid reinstalling everything when ComfyUI code changes
RUN pip install --no-cache-dir \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir xformers

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

# Set non-root user
RUN addgroup -S comfy && adduser -S comfy -G comfy
RUN chown -R comfy:comfy /app
USER comfy

# Run ComfyUI with proper arguments
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]

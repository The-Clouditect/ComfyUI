FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV REQS_FILE=requirements.txt

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3-pip \
    git \
    wget \
    curl \
    build-essential \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Make Python 3.10 the default
RUN ln -sf /usr/bin/python3.10 /usr/bin/python3 && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app

# Upgrade pip first for better dependency resolution
RUN pip install --upgrade pip

# Install PyTorch 2.2 with CUDA 11.8 support - fixed format
RUN pip install --no-cache-dir torch==2.2.0 torchvision==0.17.0 torchaudio --index-url https://download.pytorch.org/whl/cu118

# Install specific safetensors version known to handle large models better
# Do this BEFORE requirements.txt to ensure the version is respected
RUN pip install --no-cache-dir safetensors==0.4.1

# Use compatible NumPy (< 2.0)
RUN pip install --no-cache-dir "numpy~=1.24.0"

# Install xformers compatible with PyTorch 2.2
RUN pip install --no-cache-dir xformers==0.0.23

# Install torchaudio and triton (required for audio nodes)
RUN pip install --no-cache-dir triton==2.0.0

# Install other requirements
RUN pip install --no-cache-dir -r requirements.txt

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

# Run ComfyUI with increased memory limits
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188", "--disable-cuda-malloc-limit"]
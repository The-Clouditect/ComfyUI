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

# Install pytorch first (before ComfyUI requirements)
RUN pip install --no-cache-dir torch==2.0.1 torchvision==0.15.2 torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
    rm -rf /root/.cache/pip

# Install xformers - use compatible older version 
RUN pip install --no-cache-dir xformers==0.0.20 && \
    rm -rf /root/.cache/pip

# Install numpy with compatibility for older versions
RUN pip install --no-cache-dir "numpy<2.0.0" && \
    rm -rf /root/.cache/pip

# Install safetensors
RUN pip install --no-cache-dir safetensors==0.4.1 && \
    rm -rf /root/.cache/pip

# Now install ComfyUI requirements (some will be skipped if already installed)
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache/pip

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
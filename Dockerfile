# Use a CUDA 12.1 base image compatible with host driver 570.x
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies and clean up apt cache in the same layer
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# Upgrade pip first
RUN pip install --no-cache-dir --upgrade pip

# Install numpy constraint FIRST to potentially reduce later churn
RUN pip install --no-cache-dir "numpy<2.0.0"

# Install PyTorch == 2.4.0 compatible with CUDA 12.1
RUN pip install --no-cache-dir \
    torch==2.4.0 \
    torchvision==0.19.0 \
    torchaudio==2.4.0 \
    --index-url https://download.pytorch.org/whl/cu121

# Install the CORRECT xformers version compatible with torch 2.4.0 / cu121
# Pinning to 0.0.27.post1 based on its dependency requirements
RUN pip install --no-cache-dir xformers==0.0.27.post1 --index-url https://download.pytorch.org/whl/cu121

# Comment out specific, unpinned torch entries in requirements.txt before installing
RUN sed -i -e '/^torch$/s/^/#/' \
         -e '/^torchvision$/s/^/#/' \
         -e '/^torchaudio$/s/^/#/' \
         requirements.txt

# Now install ComfyUI requirements from the modified file
# This should install the rest without trying to change torch/xformers/numpy
RUN pip install --no-cache-dir -r requirements.txt

# Create necessary directories for models, outputs, etc.
RUN mkdir -p \
    /app/models/checkpoints \
    /app/models/loras \
    /app/models/controlnet \
    /app/models/upscale_models \
    /app/models/clip \
    /app/models/clip_vision \
    /app/output \
    /app/temp \
    /app/custom_nodes

# Set up volume mount points for persistent storage and custom content
VOLUME ["/app/models", "/app/output", "/app/temp", "/app/custom_nodes"]

# Expose the default ComfyUI port
EXPOSE 8188

# Default command to run ComfyUI
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188", "--disable-cuda-malloc"]
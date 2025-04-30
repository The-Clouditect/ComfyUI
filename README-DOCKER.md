# ComfyUI Docker Container

A lightweight, optimized Docker container for ComfyUI with a focus on resource efficiency for GPU-constrained environments.

## Features
- Base image: *nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04* for local host *driver 570.x*
- Only includes the ComfyUI application (no models)
- Resolves build dependency chain issues
- External model mounting for efficient storage use

## Quick Start

The biuld process pushes successful builds to docker hub and ghcr.io. use whichever you want.
```bash
docker pull theclouditect/comfyui:latest
docker pull ghcr.io/the-clouditect/comfyui:latest

```


```bash
# Pull the image
docker pull theclouditect/comfyui:latest

# Run with basic configuration
docker run -p 8188:8188 \
  -v /path/to/models:/app/models \
  -v /path/to/output:/app/output \
  --gpus all \
  the-clouditect/comfyui:latest

```

# Docker Compose Sampe Configuration for ComfyUI

`docker-compose.yml` :

```yaml
version: '3'
services:
  comfyui:
    image: theclouditect/comfyui:latest
    container_name: comfyui
    runtime: nvidia
    ports:
      - "8188:8188"
    volumes:
      - ./models:/app/models                  # Mount models directory
      - ./output:/app/output                  # Mount output directory
      - ./temp:/app/temp                      # Mount temp directory
      - ./custom_nodes:/app/custom_nodes      # Mount custom nodes
    environment:
      - NVIDIA_VISIBLE_DEVICES=all            # Use all available GPUs
      - NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics
    restart: unless-stopped                   # Automatically restart unless stopped manually
    # Uncomment the following lines if you're using a custom network
    #networks:
    #  - ai_network

# Uncomment if using a custom network
#networks:
#  ai_network:
#    driver: bridge
```

## Usage Instructions

1. Save the above configuration to a file named `docker-compose.yml`
2. Create your paths and set permissions on host system (recommend root:root 755 on dirs and 644 on files)
3. (Optional) Place your models, etc.. in host file paths (Manager is better when you can use it).
4. (Recommended) Checkout the [ComfyUI-Manager](https://github.com/Comfy-Org/ComfyUI-Manager) repo into the host folder that maps to /app/custom_nodes/
5. Run `docker-compose up -d` to start the container in detached mode
6. Access the ComfyUI interface at `http://localhost:8188`


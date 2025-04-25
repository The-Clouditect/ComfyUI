# ComfyUI Docker Container

A lightweight, optimized Docker container for ComfyUI with a focus on resource efficiency for GPU-constrained environments.

## Features

- Alpine Linux-based for minimal image size
- Only includes the ComfyUI application (no models)
- Optimized for the RTX 3060 (12GB VRAM) but compatible with other GPUs
- External model mounting for efficient storage use
- Designed for easy switching between LLM and Stable Diffusion workloads

## Quick Start

```bash
# Pull the image
docker pull theclouditect/comfyui:latest

# Run with basic configuration
docker run -p 8188:8188 \
  -v /path/to/models:/app/models \
  -v /path/to/output:/app/output \
  --gpus all \
  yourusername/comfyui:latest

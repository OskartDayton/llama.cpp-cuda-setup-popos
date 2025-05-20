#!/bin/bash

echo "🚀 Starting llama-server with CUDA..."

# CUDA environment (optional but helpful)
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export CUDA_HOME=/usr/local/cuda
export CUDACXX=/usr/local/cuda/bin/nvcc

# Navigate to repo-relative build directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/llama-server/llama.cpp/build/bin"
MODEL="$SCRIPT_DIR/modelle/mythomax-l2-13b.Q5_K_M.gguf"

cd "$BIN_DIR"

# Launch the server
./llama-server \
  -m "$MODEL" \
  --host 127.0.0.1 \
  --port 11434 \
  -ngl 20 \
  --ctx-size 4096

echo "🟢 llama-server is now running at http://localhost:11434"

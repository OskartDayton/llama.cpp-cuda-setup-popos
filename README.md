# llama.cpp-cuda-setup-popos

🧠 A complete real-world setup guide for running [llama.cpp](https://github.com/ggerganov/llama.cpp) with **CUDA support** on Pop!_OS, including deep debugging notes, build failures, fixes, and full SillyTavern integration.

---

## 🔧 System Specs (Real Hardware)

- OS: Pop!_OS 22.04 LTS (GNOME 42.9, X11)
- GPU: NVIDIA RTX 4060 Laptop GPU (8 GB VRAM)
- CPU: AMD Ryzen 7 8845HS (16 threads)
- RAM: 32 GB
- CUDA:
  - Runtime: 12.8 (`nvidia-smi`)
  - Toolkit: initially 11.5, later toolchain adapted to 12.x
- GPU Driver: 570.133.07
- Python 3.10 in venv

---

## 🧱 What I Tried First (and Why It Failed)

### ❌ Problem 1: llama.cpp compiled without CUDA

- Result: All computation was done on CPU.
- Fix: Recompiled with `-DLLAMA_CUDA=on`

### ❌ Problem 2: CMake used wrong compiler (GCC 11)

- Error: `parameter packs not expanded with ‘...’`
- Fix: Installed `gcc-12` and `g++-12`:
  ```bash
  sudo apt install gcc-12 g++-12
  ```

### ❌ Problem 3: CUDA `.cu` files compiled with `g++`

- Fix: Explicitly added:
  ```bash
  export CUDACXX=/usr/local/cuda/bin/nvcc
  ```

---

## ✅ Working Build Commands

```bash
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export CUDA_HOME=/usr/local/cuda

cmake .. \
 -DLLAMA_CUDA=on \
 -DCMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc \
 -DCMAKE_C_COMPILER=/usr/bin/gcc-12 \
 -DCMAKE_CXX_COMPILER=/usr/bin/g++-12

make -j8
```

---

## ⚙️ Runtime Environment (in start_llama_server.sh)

```bash
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export CUDA_HOME=/usr/local/cuda
export CUDACXX=/usr/local/cuda/bin/nvcc
```

➡️ These are inside the shell script only — not globally in `.bashrc`.

---

## 🧠 Memory Management

### ❌ Problem: `cudaMalloc failed: out of memory`

- RTX 4060 = 8 GB VRAM → cannot load all layers

### ✅ Fix: Limit GPU layers

```bash
-ngl 20
```

Tested incrementally with:
```bash
-ngl 20
-ngl 24
...
```

---

## 📦 Model Used

- `mythomax-l2-13b.Q5_K_M.gguf` from TheBloke (Hugging Face)
- Placed in: `~/KI/modelle/`

---

## 🧪 Testing the Server

```bash
curl http://localhost:11434/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mythomax",
    "prompt": "Once upon a time...",
    "max_tokens": 100
  }'
```

→ GPU confirmed via `nvidia-smi`

---

## 💬 SillyTavern Integration

### ❌ Problem: llama.cpp mode → no connection

### ✅ Fix:
- API Type: **OpenAI**
- API Key: any dummy (`sk-test`)
- API URL: `http://localhost:11434/v1` (no `/completions` at end)
- Model name: `mythomax`

---

## 🧞 Bonus: Custom Python CLI

File: `mythomax_terminal.py`  
Uses `llama-cpp-python` to prompt interactively from terminal with CUDA.

```python
llm = Llama(
    model_path=...,
    n_gpu_layers=20,
    n_ctx=2048,
    use_mlock=True
)
```

---

## 📁 Suggested Structure

```
KI/
├── llama-server/
│   └── llama.cpp/
│       └── build/
├── modelle/
│   └── mythomax-l2-13b.Q5_K_M.gguf
├── start_llama_server.sh
├── README.md
```

---

## ✅ Result

- Fully working llama.cpp server with GPU acceleration
- API available locally for SillyTavern or curl
- CUDA toolchain debugged and stable
- No internet required

---

## 📜 License

MIT – free to use, adapt, share.

---

Happy hacking! 🧠

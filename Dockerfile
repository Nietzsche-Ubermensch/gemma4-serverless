FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git python3-pip curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Build llama.cpp with CUDA
RUN git clone --depth 1 https://github.com/ggml-org/llama.cpp && \
    cd llama.cpp && \
    cmake -B build -DGGML_CUDA=ON -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build --config Release -j$(nproc) && \
    cp build/bin/llama-server /app/

# Install huggingface CLI
RUN pip install --break-system-packages -q huggingface_hub

# Entrypoint
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

EXPOSE 11434
ENTRYPOINT ["/app/entrypoint.sh"]

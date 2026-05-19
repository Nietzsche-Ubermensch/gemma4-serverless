FROM nvidia/cuda:12.8.0-devel-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git python3-pip && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --break-system-packages -q huggingface_hub

# Clone shallow, build ONLY llama-server (skip all tests/examples)
RUN git clone --depth 1 https://github.com/ggml-org/llama.cpp /tmp/llama.cpp && \
    cd /tmp/llama.cpp && \
    cmake -B build -DGGML_CUDA=ON -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build --config Release --target llama-server -j$(nproc) && \
    cp build/bin/llama-server /usr/local/bin/ && \
    rm -rf /tmp/llama.cpp

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 11434
ENTRYPOINT ["/entrypoint.sh"]

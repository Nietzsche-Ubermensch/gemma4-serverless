#!/bin/bash
set -e

MODEL_DIR="/app/models"
MODEL_FILE="$MODEL_DIR/Gemma4-26B-A4B-Uncensored-HauhauCS-Balanced-Q8_K_P.gguf"

# Download model if not cached (downloaded on cold start)
if [ ! -f "$MODEL_FILE" ]; then
	echo "Downloading Gemma4 GGUF (27GB)..."
	mkdir -p "$MODEL_DIR"
	hf download HauhauCS/Gemma4-26B-A4B-Uncensored-HauhauCS-Balanced \
		Gemma4-26B-A4B-Uncensored-HauhauCS-Balanced-Q8_K_P.gguf \
		--local-dir "$MODEL_DIR" \
		--token "$HF_TOKEN"
	echo "Download complete."
else
	echo "Model already cached."
fi

echo "Starting llama-server..."
exec llama-server \
	-m "$MODEL_FILE" \
	--host 0.0.0.0 \
	--port 11434 \
	-c 65536 \
	-ngl 99 \
	--jinja \
	--temp 1.0 \
	--top-p 0.95 \
	--top-k 64

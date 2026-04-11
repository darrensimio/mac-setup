#!/bin/bash

# 1. Check for displayplacer
if ! command -v displayplacer &> /dev/null; then
    echo "displayplacer not found. Installing via Homebrew..."
    brew install displayplacer
else
    echo "displayplacer is already installed. Skipping..."
fi

# 2. Identify Mac Model
# This pulls the model identifier (e.g., MacBookPro18,3 or Mac14,5)
MODEL_ID=$(sysctl -n hw.model)
echo "Detected Hardware: $MODEL_ID"

# 3. Apply resolution based on hardware
if [[ "$MODEL_ID" == *"MacBookAir"* ]] || [[ "$MODEL_ID" == *"Mac14,2"* ]] || [[ "$MODEL_ID" == *"Mac15,2"* ]]; then
    # 13" MacBook Air scaling
    echo "Setting 1710x1112 for MacBook Air..."
    displayplacer "res:1710x1112 scaling:on origin:(0,0) degree:0"
elif [[ "$MODEL_ID" == *"MacBookPro"* ]] || [[ "$MODEL_ID" == *"Mac14,5"* ]] || [[ "$MODEL_ID" == *"Mac14,9"* ]]; then
    # 14" MacBook Pro scaling
    echo "Setting 1800x1169 for MacBook Pro..."
    displayplacer "res:1800x1169 scaling:on origin:(0,0) degree:0"
else
    # Fallback/Default for other models
    echo "Unknown or different model. Attempting generic More Space (1920x1200)..."
    displayplacer "res:1920x1200 scaling:on origin:(0,0) degree:0"
fi

echo "✅ Display scaling updated. Dock was not modified."
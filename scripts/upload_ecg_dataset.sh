#!/usr/bin/env bash
# download the TinyML ECG dataset from Hugging Face and upload it to Edge Impulse.
#
# Requirements: git, git-lfs, unzip, edge-impulse-cli (npm install -g edge-impulse-cli)
# The uploader asks you to log in and choose the project on first run.
#
# The dataset ships separate training and testing data; if the extracted folder
# names differ, pass them explicitly:  TRAIN_DIR=... TEST_DIR=... ./upload_ecg_dataset.sh
set -euo pipefail

WORKDIR="${1:-ecg_data}"
mkdir -p "$WORKDIR" && cd "$WORKDIR"

if [ ! -d TinyML_ECG_Data ]; then
  git lfs install
  git clone https://huggingface.co/datasets/Yogeshwar/TinyML_ECG_Data
fi

mkdir -p extracted
find TinyML_ECG_Data -name '*.zip' -exec unzip -oq {} -d extracted \;

TRAIN_DIR="${TRAIN_DIR:-$(find extracted TinyML_ECG_Data -maxdepth 2 -type d -iname '*train*' | head -1)}"
TEST_DIR="${TEST_DIR:-$(find extracted TinyML_ECG_Data -maxdepth 2 -type d -iname '*test*' | head -1)}"

echo "Training data: $TRAIN_DIR"
echo "Testing data : $TEST_DIR"

# Edge Impulse infers each sample's label from its file name (label.sampleid.ext)
edge-impulse-uploader --category training "$TRAIN_DIR"/*
edge-impulse-uploader --category testing  "$TEST_DIR"/*

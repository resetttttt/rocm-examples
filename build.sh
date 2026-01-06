#!/usr/bin/env bash
set -euo pipefail

# Accept a relative path to the ROCm root directory (relative to current working directory)
REL_ROCM_PATH="${1-}"

if [[ -z "$REL_ROCM_PATH" ]]; then
  echo "Usage: ./build.sh <relative_path_to_ROCm_root>" >&2
  echo "Example: ./build.sh ../../rocm-npi-dev/therock/build/dist/rocm" >&2
  exit 1
fi

# Convert the relative path to an absolute path
ROCM_PATH="$(cd "$REL_ROCM_PATH" && pwd)"

export ROCM_PATH="$ROCM_PATH"
export HIP_PLATFORM=amd
export HIP_PATH="$ROCM_PATH"
export HIP_CLANG_PATH="$ROCM_PATH/llvm/bin"
export HIP_DEVICE_LIB_PATH="$ROCM_PATH/lib/llvm/amdgcn/bitcode"
export PATH="$ROCM_PATH/bin:$HIP_CLANG_PATH:$PATH"

cmake -S . -B build \
  -DROCM_ROOT="$ROCM_PATH" \
  -DCMAKE_BUILD_RPATH="$ROCM_PATH/lib" \
  -DCMAKE_HIP_ARCHITECTURES="gfx1250;gfx1260;gfx1310" \
  -DGPU_TARGETS="gfx1250;gfx1260;gfx1310" \
  && cmake --build build -j"$(nproc)"


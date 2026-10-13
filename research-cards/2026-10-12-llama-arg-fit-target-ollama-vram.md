# Research: LLAMA_ARG_FIT_TARGET=3072 in Ollama/llama.cpp

Date: 2026-10-12 · Agent: OpenCode (huggingface/zai-org/GLM-5.3-Flash) · Confidence: high (all primary-source verified)

## Verdict

`LLAMA_ARG_FIT_TARGET` exists upstream in llama.cpp (env var for `-fitt, --fit-target`,
units MiB, default 1024 MiB). It is the per-device free-VRAM margin that `--fit`
(default on) maintains when auto-placing model tensors: each device may use at most
`free − margin` memory. 3072 = 3 GiB margin.

Key sources:
- llama.cpp server README: https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md (fit rows)
- fit algorithm: https://github.com/ggml-org/llama.cpp/blob/master/common/fit.cpp (targets[id] = free − margin, ~line 647)
- feature origin: PR #16653 (2025-12-15) auto-fit; PR #18679 (2026-01-08) per-device fit-target

## Ollama integration (main @ b11521 llama.cpp pin, v0.40.x era)

- Ollama wraps llama-server (`llm/llama_server.go`); subprocess env = `os.Environ()`
  → user-set LLAMA_ARG_FIT_TARGET inherits through. Documented in `envconfig/config.go`
  (LLAMA_ARG_FIT + LLAMA_ARG_FIT_TARGET) and `ollama help environment` (cmd/cmd.go).
- Ollama sets it itself ONLY for vision models: mmproj memory + 1 GiB headroom pad
  (PR #16996, shipped v0.31.2). Text-only models: unset → llama.cpp default 1024 MiB.
- Default `num_gpu=-1` → ollama passes NO `-ngl` → llama.cpp --fit does layer placement.
  Ollama always passes `-c` → fit never shrinks context in ollama usage.
- KNOWN GAP: OLLAMA_GPU_OVERHEAD (default 0) does NOT reach the fit target —
  issue #18679 (open), PR #18680 (open, unmerged as of 2026-10-12).

## 24 GB card, 23 GB model, fit-target 3072

GPU usable budget = 24576 − 3072 ≈ 21504 MiB for weights+ctx+buffers → loader trims
layer placement to keep ≥3 GiB free (does NOT refuse/fallback). With user-set num_gpu,
fit aborts placement changes (warn only) → OOM surfaces as ollama startup error
(text models: no auto-retry; mmproj: one CPU-offload retry).

## Multi-model

Scheduler-level: ollama pre-flight evicts loaded models when predicted load > 80% of
available memory (sched.go); FreeMemory updated from loaded runners' actual usage.
llama-server-level: each new model's fit sees live free VRAM (already minus model 1)
and keeps margin free → yes, budget = (total − used − 3072 MiB) effectively. The two
layers do not share the reserve number (GPU_OVERHEAD gap above).

## All sources

- https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
- https://github.com/ggml-org/llama.cpp/blob/master/common/fit.cpp
- https://github.com/ggml-org/llama.cpp/blob/master/common/common.h (fit_params defaults)
- https://github.com/ggml-org/llama.cpp/pull/16653 · https://github.com/ggml-org/llama.cpp/pull/18679 · https://github.com/ggml-org/llama.cpp/issues/18390
- https://github.com/ollama/ollama/blob/main/llm/llama_server.go · https://github.com/ollama/ollama/blob/main/envconfig/config.go · https://github.com/ollama/ollama/blob/main/server/sched.go
- https://github.com/ollama/ollama/pull/16996 · https://github.com/ollama/ollama/issues/18679 · https://github.com/ollama/ollama/pull/18680
- https://github.com/ollama/ollama/releases/tag/v0.31.2

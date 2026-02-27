# MLX-Claw: iOS LLM Bridge für OpenClaw

## Vision
OpenClaw Gateway verbindet sich mit einem iPhone das MLX/Gemma läuft – somit hat der Agent on-device Function Calling Capabilities.

## Coding Assistant (Developer)
- **OpenCode** oder **Codex CLI** als Programmier-Assistent nutzen (nicht für das iPhone, sondern als Entwickler-Werkzeug)

## Local Models on iPhone
Options für lokale Models auf dem iPhone:
- **a-Shell** mit Python + MLX
- **Codex CLI** mit `--oss` Flag
- **OpenCode** mit MLX Provider

## Architecture

```
┌─────────────────┐     WebSocket      ┌─────────────────┐
│  OpenClaw      │ ◄──────────────► │  Chowder-iOS    │
│  Gateway       │                  │  (MLX Backend) │
└─────────────────┘                  └────────┬────────┘
                                             │
                                      ┌──────▼──────┐
                                      │  MLX/Gemma   │
                                      │  (on-device) │
                                      └──────────────┘
```

## Features

### Phase 1: MLX Backend Integration
- [ ] MLX Python Server auf iPhone (a-Shell oder eigenes Target)
- [ ]Gemma/Phi Model laden (quantized)
- [ ] REST API für Inference

### Phase 2: OpenClaw Protocol
- [ ] WebSocket Endpoint für Gateway
- [ ] Tool/Function Calling via MLX
- [ ] Streaming Responses

### Phase 3: Chowder Integration
- [ ] MLX Backend in Chowder einbauen
- [ ] Function Calling UI
- [ ] Live Activity Updates

### Phase 4: Production
- [ ] App Store ready machen
- [ ] OAuth für Token Storage
- [ ] Offline Support

## Tech Stack
- **iOS**: Swift, MLX, Python (via PythonKit oder external process)
- **Model**: Gemma 2B or Phi-3 (quantized für Mobile)
- **Protocol**: OpenClaw Gateway Protocol

## Milestones

### M1: Proof of Concept
- MLX Server auf iPhone
- Einfacher HTTP POST endpoint
- Test mit curl

### M2: WebSocket Bridge  
- Chowder WebSocket für Gateway
- Basic message roundtrip

### M3: Function Calling
- Gemma Tool Calls parsen
- Calendar/Tasks ausführen

### M4: Release
- TestFlight
- Dokumentation

## Getting Started

```bash
# MLX auf iPhone (a-shell oder Pythonista)
pip install mlx transformers

# Model laden
from transformers import AutoModelForCausalLM
model = AutoModelForCausalLM.from_pretrained("google/gemma-2b-it-quantized")
```

## Open Questions
- Welches Model? (Gemma 2B, Phi-3, Llama?)
- Hosting: a-Shell, Pythonista, oder natives Swift?
- Offline-first oder Cloud-Bridge?

---

**Owner:** Julius Frick  
**Created:** 27.02.2026  
**Status:** Planning

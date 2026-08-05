# Tool Adapters

Adapters explain how different AI tools should consume this harness.

The shared files in `ai/context/`, `ai/instructions/`, and `ai/skills/` are the
shared harness. Tool-specific files should only add startup conventions or
formatting preferences for that tool. The `ai/skills/` folder is currently
reserved and intentionally empty.

## Adapters

- `codex.md`
- `claude.md`
- `opencode.md`
- `generic.md`

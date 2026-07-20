---
description: Carica la memoria del progetto da graph_project.md. Se manca, richiama /organization-graph
allowed-tools: Bash
---

Run `powershell -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/commands/mem-graph.ps1"` in the project root and show its output as the loaded project memory. If it reports the graph does not exist, tell the user to run /organization-graph first.

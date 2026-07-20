---
name: memory-graph
description: Carica la memoria del progetto da graph_project.md nella root. Se il file manca, richiama prima organization-graph. Usa quando serve ricordare la struttura/memoria di un progetto già mappato.
allowed-tools: Bash
---

Run `powershell -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/commands/mem-graph.ps1"` in the project root e mostra l'output come memoria di progetto caricata. Se lo script segnala che il grafo non esiste, avvisa l'utente di eseguire prima /organization-graph.

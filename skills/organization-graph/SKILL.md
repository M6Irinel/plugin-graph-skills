---
name: organization-graph
description: Genera la struttura del progetto indicizzando file, funzioni e componenti in file .md nella root. Usa quando serve mappare o ri-mappare l'organizzazione di un progetto, o quando manca graph_project.md.
allowed-tools: Bash
---

Run `powershell -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/commands/organization-graph.ps1" <folder1> <folder2> ...` in the project root, passando come argomenti le cartelle da analizzare (se non specificate dall'utente, usa la root del progetto). Riporta il risultato.

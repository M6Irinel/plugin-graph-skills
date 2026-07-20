@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0\..\commands\mem-graph.ps1" %*

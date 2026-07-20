@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0\..\commands\organization-graph.ps1" %*

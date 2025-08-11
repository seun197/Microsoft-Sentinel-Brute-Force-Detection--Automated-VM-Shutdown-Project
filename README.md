# Microsoft Sentinel — Brute-Force Detection + Automated VM Shutdown

## Overview
Detect repeated failed sign-ins (Windows Event 4625 bursts) in Microsoft Sentinel, auto-create an incident, and trigger a Logic App to **power off only pre-approved VMs** to contain the attack.

## Quick Deploy (one command after you add your exports)
```bash
# Login + select sub
az login
az account set --subscription <SUB_ID>

# Run the wrapper (edits: deploy/params.example.json -> your values, then rename to params.json)
pwsh ./deploy/deploy.ps1

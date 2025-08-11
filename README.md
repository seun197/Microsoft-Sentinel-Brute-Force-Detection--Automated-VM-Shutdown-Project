# Microsoft Sentinel — Brute-Force Detection + Automated VM Shutdown

## Overview
Detect repeated failed sign-ins (Windows Event 4625 bursts) in Microsoft Sentinel, auto-create an incident, and trigger a Logic App to **power off only pre-approved VMs** to contain the attack.

## Quick Deploy (one command after you add your exports)
```bash
# Login + select sub
az login
az account set --subscription <SUB_ID>

# Run the wrapper (edits: deploy/params.example.json -> your values, then rename to params.json)
pwsh ./deploy/deploy.ps1 ### 
```

## What this deploys
- **Sentinel Analytic Rule (KQL)** for brute-force detection  
- **Sentinel Automation Rule** → triggers the Logic App  
- **Logic App playbook** → validates tag → `powerOff` VM → notify SOC

## Prerequisites
Place your exported ARM JSONs in these paths:
- `playbooks/pbk_vm_shutdown.logicapp.json`
- `analytic-rules/bruteforce-detection.json`
- `automation-rules/incident-to-playbook.json`

Tools required:
- Azure CLI (`az`)
- PowerShell 7+

## Verify
- Generate failed logons → `tests/simulate-4625.ps1`
- **Sentinel → Incidents**: new incident appears in **< 5 min**
- **Logic App → Run history**: status **Succeeded**, VM powered off
- Add proof screenshots in: `/images/`

## Governance
ISO/IEC 27001:2022 mapping: [`docs/ISO27001-Mapping-Sentinel-Bruteforce.md`](docs/ISO27001-Mapping-Sentinel-Bruteforce.md)

## Architecture
- Mermaid diagram: [`docs/architecture.mmd`](docs/architecture.mmd)
- Runbook: [`docs/runbook.md`](docs/runbook.md)

## MITRE ATT&CK
- **Tactic:** Credential Access  
- **Technique:** **T1110 — Brute Force**  
- **Detection:** Sentinel Analytic Rule (KQL)  
- **Response:** Logic App (powerOff + notify)






# ISO/IEC 27001:2022 Annex A Mapping — Sentinel Brute-Force + Auto VM Shutdown

## Scope
Detect high-rate failed sign-ins (Event ID 4625), create an incident in Sentinel, and trigger a Logic App to power off **only pre-approved VMs** tagged `AutoShutdown=true`.

## Primary Controls
- **A.8.15 — Logging:** Windows SecurityEvent → Log Analytics → Sentinel; rule + retention + RBAC.
- **A.8.16 — Monitoring activities:** Scheduled analytic rule, automation rule, workbook (optional) for trends/MTTR.
- **A.5.15 — Access control:** Risk-based control; action limited to tagged VMs; least-privilege MI (`powerOff` only).

## Supporting Controls
- **A.8.2 — Privileged access rights:** Scoped Role Assignment for Logic App MI.
- **A.8.17 — Clock synchronisation:** Accurate timestamps across sources for investigation.
- **A.5.23 — Cloud services:** Control design documented within Azure scope of ISMS.

## Evidence (repo paths)
- `analytic-rules/bruteforce-detection.json`
- `automation-rules/incident-to-playbook.json`
- `playbooks/pbk_vm_shutdown.logicapp.json`
- `images/incident.png`, `images/logicapp-run-history.png`

## Risks & Safeguards
- **False positives / blast radius:** Tag gate (`AutoShutdown=true`), RG/VM scope, dry-run option (parameterise playbook).
- **Service accounts:** Exclusions + thresholding; suppression windows.
- **Prod safety:** Approval step for prod subscriptions; change control.

## Operating Procedure
1) Detect (<5m) → 2) Playbook (<60s) → 3) Action (tag + scope check → `powerOff`) → 4) Notify SOC → 5) Post-incident tuning.

# Runbook — Brute-Force Detection to Auto Shutdown

## Route
- Detection: < 5 minutes
- Response: < 60 seconds to playbook action

## Steps
1. Analytic rule triggers incident on 4625 burst (host/account/source aggregation).
2. Automation rule invokes Logic App with incident context.
3. Logic App:
   - Gets VM metadata from incident/entity mapping (or parameter)
   - Validates tag `AutoShutdown=true`
   - Calls `Microsoft.Compute/virtualMachines/powerOff/action`
   - Sends notification (email/Teams)
4. Analyst reviews incident, confirms containment, adds lessons learned.
5. Tune thresholds/exclusions; update workbook.

## RBAC
- Playbook MI: **Virtual Machine Contributor** scoped to RG/VM only.
- Sentinel roles: Responder/Contributor as appropriate.

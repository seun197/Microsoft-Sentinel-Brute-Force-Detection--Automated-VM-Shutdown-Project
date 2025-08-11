param([string]$ParamsPath = "$(Split-Path $PSCommandPath -Parent)\params.json")

if (!(Test-Path $ParamsPath)) { throw "Missing $ParamsPath. Copy params.example.json to params.json and fill it." }
$P = Get-Content $ParamsPath | ConvertFrom-Json

az account set --subscription $P.subscriptionId | Out-Null

# Ensure RG exists
az group create -n $P.resourceGroup -l $P.location | Out-Null

# Safety tag on the target VM
az resource tag --ids $P.vmResourceId --tags $P.safetyTagName=$P.safetyTagValue | Out-Null

# Deploy Logic App (exported ARM template)
$logicAppTemplate = Join-Path $PSScriptRoot "..\playbooks\pbk_vm_shutdown.logicapp.json"
if (!(Test-Path $logicAppTemplate)) { throw "Missing Logic App template at $logicAppTemplate" }

az deployment group create `
  -g $P.resourceGroup `
  --template-file $logicAppTemplate `
  --parameters workflowName=$($P.logicAppName) location=$($P.location) | Out-Null

# Get MI principalId
$miPrincipalId = az resource show `
  --ids "/subscriptions/$($P.subscriptionId)/resourceGroups/$($P.resourceGroup)/providers/Microsoft.Logic/workflows/$($P.logicAppName)" `
  --query "identity.principalId" -o tsv

# Grant least-privilege to Logic App MI (VM Contributor at scoped RG/VM)
az role assignment create `
  --assignee-object-id $miPrincipalId `
  --assignee-principal-type ServicePrincipal `
  --role "Virtual Machine Contributor" `
  --scope $P.miRoleScope | Out-Null

# Deploy Analytic Rule
$ruleTemplate = Join-Path $PSScriptRoot "..\analytic-rules\bruteforce-detection.json"
if (!(Test-Path $ruleTemplate)) { throw "Missing Analytic Rule template at $ruleTemplate" }

az deployment group create `
  -g $P.resourceGroup `
  --template-file $ruleTemplate `
  --parameters workspaceName=$($P.workspaceName) workspaceResourceId=$($P.workspaceResourceId) | Out-Null

# Deploy Automation Rule
$autoTemplate = Join-Path $PSScriptRoot "..\automation-rules\incident-to-playbook.json"
if (!(Test-Path $autoTemplate)) { throw "Missing Automation Rule template at $autoTemplate" }

$logicAppId = "/subscriptions/$($P.subscriptionId)/resourceGroups/$($P.resourceGroup)/providers/Microsoft.Logic/workflows/$($P.logicAppName)"

az deployment group create `
  -g $P.resourceGroup `
  --template-file $autoTemplate `
  --parameters workspaceName=$($P.workspaceName) logicAppResourceId=$logicAppId | Out-Null

Write-Host "`n✅ Deployed. Safety tag enforced: $($P.safetyTagName)=$($P.safetyTagValue)"


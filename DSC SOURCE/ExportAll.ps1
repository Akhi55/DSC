# --- CONFIGURATION DATA ---
$AppId = "PASTE_YOUR_APP_ID_HERE"
$TenantId = "PASTE_YOUR_TENANT_ID_HERE"
$SecretValue = "PASTE_YOUR_SECRET_VALUE_HERE"
$ExportPath = "C:\M365DSC_Exports"

# Convert secret to secure string for the credential object
$SecSecret = ConvertTo-SecureString $SecretValue -AsPlainText -Force
$AppCred = New-Object System.Management.Automation.PSCredential($AppId, $SecSecret)

# --- WORKLOAD LIST ---
# We define the prefixes for each workload
$Workloads = @{
    "Identity"   = "AAD*"
    "Intune"     = "Intune*"
    "Exchange"   = "EXO*"
    "Teams"      = "Teams*"
    "SharePoint" = "SPO*"
    "Security"   = "SC*"
}

# --- EXECUTION LOOP ---
foreach ($WorkloadName in $Workloads.Keys) {
    $Prefix = $Workloads[$WorkloadName]
    $CurrentOutPath = Join-Path $ExportPath $WorkloadName
    
    Write-Host "--- Starting export for $WorkloadName ---" -ForegroundColor Cyan
    
    Export-M365DSCConfiguration -Components @($Prefix) `
                                -Credential $AppCred `
                                -TenantId $TenantId `
                                -OutPath $CurrentOutPath
}
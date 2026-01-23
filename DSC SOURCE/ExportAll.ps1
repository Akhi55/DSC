# --- POINT TO THE FRESH MODULE ---
$FreshModuleRoot = (Get-ChildItem -Path "C:\M365DSC_Fresh\Microsoft365DSC\*\Microsoft365DSC.psd1").FullName
Import-Module $FreshModuleRoot -Force

# --- AUTH DATA ---
$AppId      = "5f22b242-865d-4f0f-aa01-d5fcffc4edcb"
$TenantId   = "mismad365.onmicrosoft.com"
$Thumbprint = "78F0E2027679D459AE0A6C717909CC136D8F0A54"
$BaseExportPath = "C:\Users\akhilesh.sharma\OneDrive - SoftwareOne\Desktop\DSC_Config\DSC SOURCE\M365_Backups"

# --- DEFINE ALL WORKLOADS ---
$Workloads = @{
    "01_Identity"   = "AAD"
    "02_Intune"     = "Intune"
    "03_Exchange"   = "EXO"
    "04_Teams"      = "Teams"
    "05_SharePoint" = "SPO"
    "06_Security"   = "SC"
}

$ResourcePath = (Get-ChildItem -Path "C:\M365DSC_Fresh\Microsoft365DSC\*\DSCResources").FullName

foreach ($WorkloadFolder in ($Workloads.Keys | Sort-Object)) {
    $Prefix = $Workloads[$WorkloadFolder]
    $CurrentOutPath = Join-Path $BaseExportPath $WorkloadFolder
    
    if (!(Test-Path $CurrentOutPath)) { New-Item -ItemType Directory -Path $CurrentOutPath -Force | Out-Null }

    Write-Host "`n>>> Starting Workload: $WorkloadFolder (Prefix: $Prefix)" -ForegroundColor Yellow

    # Resolve components
    $ResolvedComponents = Get-ChildItem -Path $ResourcePath -Filter "MSFT_$Prefix*" -Directory | ForEach-Object { 
        $_.Name.Replace("MSFT_", "") 
    }

    if ($ResolvedComponents) {
        Write-Host "Found $($ResolvedComponents.Count) resources for $Prefix. Exporting..." -ForegroundColor Cyan
        
        try {
            # Use @() to ensure an array is passed, preventing single-resource errors
            Export-M365DSCConfiguration `
                -Components @($ResolvedComponents) `
                -ApplicationId $AppId `
                -CertificateThumbprint $Thumbprint `
                -TenantId $TenantId `
                -Path $CurrentOutPath `
                        }
        catch {
            # Fixed the colon issue by separating the variable or using braces
            $ErrMsg = $_.Exception.Message
            Write-Host "Error exporting ${Prefix} : $ErrMsg" -ForegroundColor Red
        }
    }
}

Write-Host "`n✅ ALL WORKLOADS COMPLETED!" -ForegroundColor Green
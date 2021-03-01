# software installation

$psvars = Get-Content -Path a:\$env:psvarfile | ConvertFrom-Json
#$ErrorActionPreference = "Stop"

Start-Transcript -Path ($psvars.os_deployment_log_file) -Append

#example sofware install
if ([bool]::Parse(($psvars.os_avirus_agent))){
    write-host "Installing antivirus agent..."
    if (Test-Path "f:\agent.msi") {
        &msiexec /i f:\agent.msi
    }
    if (Test-Path "e:\agent.msi") {
        &msiexec /i e:\agent.msi
    }
    sleep 90
}

Stop-Transcript -Path ($psvars.os_deployment_log_file) -Append

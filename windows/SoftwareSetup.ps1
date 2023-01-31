#Requires -RunAsAdministrator
[CmdletBinding()]
Param(
  [Parameter(ValueFromPipelineByPropertyName, Mandatory = $true, HelpMessage = 'please pass $false or $true')]
  [ValidateNotNullOrEmpty()]
  [ValidateSet($false, $true)]
  [bool]$dryRun,
  [Parameter(ValueFromPipelineByPropertyName, Mandatory = $false, HelpMessage = 'please pass winget for `winget only run`')]
  [ValidateSet('winget', 'choco', IgnoreCase = $true)]
  [string]$utility
)
# Run following to bypass "not digitally signed" issue (fixes per session only)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Import-Module $PSScriptRoot\modules\module1.psm1 -Scope Local -Force
# If running from Powershell
# Import-Module -Name Appx -UseWIndowsPowershell
$chocoPackagesFile = 'choco.txt'
$wingetPackagesFile = 'winget.txt'

function Test-Config-Files {
  $files = @($chocoPackagesFile, $wingetPackagesFile)
  if (($files | ForEach-Object { Test-Path $_ }) -contains $false) {
    return $false
  }
  return $true
}

$testFailed = Test-Config-Files
if (($testFailed -ne $true)) {
  Write-Error -Message "[ERROR] Make sure BOTH choco.txt and winget.txt are available in current directory" -ErrorAction Stop
}

Switch ($utility) {
  'winget' { write-host "Running $utility only"; Install-Winget-Packages -dryRun $dryRun -packagesFilePath $wingetPackagesFile; }
  'choco' { write-host "Running $utility only"; Install-Chocolatey-Packages -dryRun $dryRun -packagesFilePath $chocoPackagesFile }
  default { Install-Winget-Packages -dryRun $dryRun -packagesFilePath $wingetPackagesFile; Install-Chocolatey-Packages -dryRun $dryRun -packagesFilePath $chocoPackagesFile }
}

if (!($dryRun)) {
  Write-PostInstall-Message
}

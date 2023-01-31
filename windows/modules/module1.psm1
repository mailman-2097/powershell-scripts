function Test-Chocolatey {
    $chocoIsInstalled = Test-Path -Path "$env:ProgramData\Chocolatey" # -And Get-Command choco.exe -ErrorAction SilentlyContinue
    return $chocoIsInstalled
}

function Install-Chocolatey-Packages {
    param(
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $true, HelpMessage = 'please pass $false or $true')]
        [bool]$dryRun,
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $true, HelpMessage = 'please pass package file')]
        [string]$packagesFilePath
    )
    $chocoIsInstalled = Test-Chocolatey
    if (!$chocoIsInstalled) {
        write-host "`n--> Chocolately was not installed, let's install it! ---`n"
      
        if (!($dryRun)) {
            Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        }
    }
    $choco_packages = Read-File -File $packagesFilePath
    if (!($dryRun)) {
        foreach ($item in $choco_packages) {
            write-host "`n* --> Next package to install: '${item}'`n"
            choco install $item -y
        }
    }
    else {
        write-host "* --> Choco Packages to install: `n$(Format-Result -list $choco_packages)"
    }
}

function Format-Result {
    param(
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $true, HelpMessage = 'please pass a list')]
        [string[]]$list
    )
    $output = $list | Format-Table -AutoSize -Wrap -Property Package | Out-String  
    return $output
}

function Test-Winget {
    $hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
    return $hasPackageManager
}

function Install-Winget-Packages {
    param(
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $true, HelpMessage = 'please pass $false or $true')]
        [bool]$dryRun,
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $true, HelpMessage = 'please pass package file')]
        [string]$packagesFilePath
    )

    $hasPackageManager = Test-Winget
    if (!$hasPackageManager -or [version]$hasPackageManager.Version -lt [version]"1.10.0.0") {
        write-host "`n---+++ Install Winget from Windows Store+++---`n"
        exit
    }
    
    $winget_packages = Read-File -File $packagesFilePath
    
    if (!($dryRun)) {
        foreach ($item in $winget_packages) {
            write-host "`n---+++ Install package $item, using winget (`winget.run`) +++---`n"
            winget install --accept-source-agreements --source winget --id $item
        }
    }
    else {
        write-host "* --> Winget Packages to install: `n$(Format-Result -list $winget_packages)"
    }

}
function Read-File {
    Param(
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $true, HelpMessage = 'please pass $false or $true')]
        [ValidateNotNullOrEmpty()]
        [string]$File
    )    
    return (Get-Content $file) -notmatch '^\s*$' -notmatch '^#' | Where-Object { $_.trim() -ne "" }
}

function Write-PostInstall-Message {

    $post_text = @'
---+++ Follow below steps for further customisation +++---

# https://ohmyposh.dev/docs/installation
(Get-Command oh-my-posh).Source
oh-my-posh font install Meslo
oh-my-posh get shell
New-Item -Path $PROFILE -Type File -Force
Get-PoshThemes
notepad $PROFILE
. $PROFILE

# https://aka.ms/enablevirtualization
# https://aka.ms/wslinstall
# use standard powershell
Install-Module -Name Terminal-Icons -Repository PSGallery
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
wsl --install

# https://ohmyposh.dev/docs/installation/linux
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install jandedobbeleer/oh-my-posh/oh-my-posh
oh-my-posh font install Meslo
# Apply fonts to Windows Terminal
# https://ohmyposh.dev/docs/installation/fonts#windows-terminal
# https://learn.microsoft.com/en-us/windows/terminal/install#settings-json-file

echo 'eval $(oh-my-posh init bash)"' >> ~/.profile
echo 'eval "$(oh-my-posh init bash --config $(brew --prefix oh-my-posh)/themes/microverse-power.omp.json)"' >> ~/.profile

'@
    Write-Output -InputObject $post_text
}
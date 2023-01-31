# Introduction
This repository contains various powershell scripts

# Solutions

## Windows 10 Software setup using chocolatey and winget
1. The [SoftwareSetup.ps1](./windows/SoftwareSetup.ps1) script will help to install baseline tools.
The scripts uses [winget](https://winget.run) and [chocolatey](https://chocolatey.org) to install software.
You can provide the same as input using the [winget.txt](./windows/winget.txt) and [choco.txt](./windows/choco.txt) configuration files.

> Both Winget and WSL must be installed from the Microsoft Store. I prefer it this way on personal workstations.

```powershell
# Run the powershell script from command line or using ISE

.\SoftwareSetup.ps1 -dryRun $true

```

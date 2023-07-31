#Requires -Modules Evergreen
<#
    .SYNOPSIS
        Install evergreen core applications.
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $False)]
    [System.String] $LogPath = "$env:SystemRoot\Logs\Packer",

    [Parameter(Mandatory = $False)]
    [System.String] $Path = "$env:SystemDrive\Apps\Adobe\Acrobat Reader DC"
)

#region Script logic
# Set $VerbosePreference so full details are sent to the log; Make Invoke-WebRequest faster
$VerbosePreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Create target folder
New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null

Write-Host " Adobe Acrobat Reader DC"
$App = Get-EvergreenApp -Name "AdobeAcrobatReaderDC" | Where-Object { $_.Language -eq "MUI" -and $_.Architecture -eq "x64" } `
| Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | Select-Object -First 1

If ($App) {
    
    # Download
    Write-Host " Downloading Adobe Acrobat Reader DC"
    $OutFile = Save-EvergreenApp -InputObject $App -Path $Path -WarningAction "SilentlyContinue"

    # Install
    Write-Host " Installing Adobe Acrobat Reader DC"
    try {
        $params = @{
            FilePath     = $OutFile.FullName
            ArgumentList = "-sfx_nu /sALL /msi EULA_ACCEPT=YES ENABLE_CHROMEEXT=0 DISABLE_BROWSER_INTEGRATION=1 ENABLE_OPTIMIZATION=YES ADD_THUMBNAILPREVIEW=0 DISABLEDESKTOPSHORTCUT=1 UPDATE_MODE=0 DISABLE_ARM_SERVICE_INSTALL=1"
            WindowStyle  = "Hidden"
            Wait         = $True
            Verbose      = $True
            }
        Start-Process @params
    }
    catch {
        Write-Warning -Message " ERR: Failed to install Adobe Acrobat Reader DC."
    }

    # Post install configuration
    Disable-ScheduledTask -TaskName "Adobe Acrobat Update Task"
}
Else {
    Write-Warning -Message " ERR: Failed to retrieve Adobe Acrobat Reader DC"
}

# If (Test-Path -Path $Path) { Remove-Item -Path $Path -Recurse -Confirm:$False -ErrorAction "SilentlyContinue" }
Write-Host " Complete: Adobe Acrobat Reader DC."
#endregion
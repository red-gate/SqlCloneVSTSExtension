$ErrorActionPreference = "Stop"

trap {
    Write-Error $PSItem.ToString()
    exit 1
}
.\jsonSanityCheck.ps1 -manifest "extension-manifest.json" -task "ImageTask\task.json"

.\jsonSanityCheck.ps1 -manifest "extension-manifest.json" -task "CloneTask\task.json"

.\jsonSanityCheck.ps1 -manifest "extension-manifest.json" -task "DeleteTask\task.json"

.\jsonSanityCheck.ps1 -manifest "extension-manifest.json" -task "DeleteImageTask\task.json"


& npm install

Install-PackageProvider NuGet -Force
Import-PackageProvider NuGet -Force
Save-Module -Name VstsTaskSdk -Path .\TaskModules -RequiredVersion 0.8.1 -Force


& xcopy TaskModules\VstsTaskSdk\0.8.1 ImageTask\ps_modules\VstsTaskSdk /E /y /i
& xcopy TaskModules\VstsTaskSdk\0.8.1 CloneTask\ps_modules\VstsTaskSdk /E /y /i
& xcopy TaskModules\VstsTaskSdk\0.8.1 DeleteTask\ps_modules\VstsTaskSdk /E /y /i
& xcopy TaskModules\VstsTaskSdk\0.8.1 DeleteImageTask\ps_modules\VstsTaskSdk /E /y /i

& xcopy TaskModules\ClonePowerShell ImageTask\modules /E /y /i
& xcopy TaskModules\ClonePowerShell CloneTask\modules /E /y /i
& xcopy TaskModules\ClonePowerShell DeleteTask\modules /E /y /i
& xcopy TaskModules\ClonePowerShell DeleteImageTask\modules /E /y /i

& .\node_modules\.bin\vset.cmd package -m extension-manifest.json -o .\Packages 

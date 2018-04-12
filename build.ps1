Param(
    [Parameter(
        Mandatory=$true,
        HelpMessage = "Please go to https://marketplace.visualstudio.com/manage/publishers/redgatesoftware to see what the current version is, and ++"
    )][System.Version]$version,                                                                        
    [Parameter(
        Mandatory=$true,
        HelpMessage = "Please enter release or debug. If this is a public version, it must be release"
    )][string]$build                                                        # accepts release (public) or debug (private). Default is release
)

#Variables for script
$tasks = "CloneTask", "DeleteTask", "ImageTask"                    #needs to match directory name
$vstsName = "redgateSqlClone"
$rootDir = "$PSScriptRoot" | Resolve-Path
$extensionManifestFile = "$rootDir\extension-manifest.json"
$dateNowForRevision = $("1$(get-date -format "MMddHHmm")")                                                                   # Each number in the version (x.x.x.x) has a max of 2147483647. The revision must be greater than 1 as per the VSTS rules. We can't use year as of this breaking after (20)21. Due to lack of updates, there should be little chance of a collision.
$requiredVersion = "0.8.1"

$ErrorActionPreference = "Stop"

trap
{
    exit 1
}

function Test-Administrator {  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    if ((New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        return $true;
    }

    return $false;
}


if (-Not (Test-Administrator)) {
    Write-Output(" ")
    Write-Output("*** *** *** You need to run as administrator *** *** ***")
    Write-Output("Terminated ")
    Write-Output(" ")
    exit
}

if ([string]::IsNullOrEmpty($build)) {
    $build = "release"
}

if ($build.ToLower() -ne "release" -and $build.ToLower() -ne "debug") {
    Write-Output(" ")
    Write-Output("Expected either release or debug ")
    Write-Output("Terminated ")
    Write-Output(" ")
    exit
}

.\UpdatePublic.ps1 -extensionManifestFile $extensionManifestFile -buildType $build

.\UpdateId.ps1 -extensionManifestFile $extensionManifestFile -vstsName $vstsName -buildType $build

.\UpdateAllTaskVersions.ps1 -extensionManifestFile $extensionManifestFile -major $version.Major -minor $version.Minor -build $version.Build -dateNowForRevision $dateNowForRevision -rootDir $rootDir -tasks $tasks -buildType $build






Foreach ($task in $tasks) {
    Write-Output("Checking $task")
    .\jsonSanityCheck.ps1 -manifest "extension-manifest.json" -task "$($task)\task.json"
}


#clear out the old, if it doesn't exist, just continue
Remove-Item TaskModules\VstsTaskSdk -Force -Recurse -ErrorAction SilentlyContinue

Write-Output("Installing npm stuff! ")

& npm install

Install-PackageProvider NuGet -Force
Import-PackageProvider NuGet -Force
Save-Module -Name VstsTaskSdk -Path .\TaskModules -RequiredVersion $requiredVersion -Force




Foreach($task in $tasks) {
    Write-Output "Copying &task files"
    & xcopy TaskModules\VstsTaskSdk\$requiredVersion $task\ps_modules\VstsTaskSdk /E /y /i
    & xcopy TaskModules\ClonePowerShell $task\modules /E /y /i
}


Write-Output("Creating the package... ")

& .\node_modules\.bin\vset.cmd package -m extension-manifest.json -o .\Packages 




param([string]$manifest, [string]$task)

$ErrorActionPreference = "Stop"

$manifestJson = Get-Content $manifest -Raw | ConvertFrom-Json
$manifestVersion = $manifestJson.version

$taskJson = Get-Content $task -Raw | ConvertFrom-Json
$taskVersion = [string]($taskJson.version.Major) + "." + [string]($taskJson.version.Minor) + "." + [string]($taskJson.version.Patch)

If ($manifestVersion -notmatch $taskVersion) {
    Write-Host "##teamcity[buildProblem description='The json versions do not match. The manifest version is $manifestVersion and the task version is $taskVersion.']"
    Write-Error -Message ("The json version strings do not match. The manifest version is " + $manifestVersion + " and the task version is " + $taskVersion + ".")
    Exit 1
}
Else
{
    Write-Host "The versions match in the JSON manifests."
}
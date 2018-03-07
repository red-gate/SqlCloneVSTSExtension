[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string] $extensionManifestFile,
  [Parameter(Mandatory=$true)][string] $buildType
)
   
    $json = Get-Content $extensionManifestFile  -raw | ConvertFrom-Json
    
    #if debug, change the name
    if ($buildType -eq "debug") {      
        $json.Public = $false
        Write-Output ("Making public = false as it's debug")
    }else{
        $json.Public = $true
        Write-Output ("Making public = true as it's release")
    }   
    
    #save it
    $json | ConvertTo-Json  -Depth 10 | set-content $extensionManifestFile

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string] $extensionManifestFile,
  [Parameter(Mandatory=$true)][string] $vstsName,
  [Parameter(Mandatory=$true)][string] $buildType
)
    #Grab the json from the file
    $json = Get-Content $extensionManifestFile  -raw | ConvertFrom-Json

    #give it default name
    
    
    #if debug, change the name
    if ($buildType -eq "debug") {
        $id = "$($vstsName)-private"
        $json.id = $id
        Write-Output ("As it's debug, updating name to $id")
    }else{
        $json.id = $vstsName
        write-Output ("Updating the ID (name) to $vstsName")    
    }
    
    #save it
    $json | ConvertTo-Json -Depth 10 | set-content $extensionManifestFile

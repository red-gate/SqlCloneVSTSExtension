[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string] $extensionManifestFile,
  [Parameter(Mandatory=$true)][string] $major,
  [Parameter(Mandatory=$true)][string] $minor,
  [Parameter(Mandatory=$true)][string] $build,
  [Parameter(Mandatory=$true)][string] $dateNowForRevision,
  [Parameter(Mandatory=$true)][string] $rootDir,
  [Parameter(Mandatory=$true)][array] $tasks,
  [Parameter(Mandatory=$true)][array] $buildType
)
  
  Write-Output "Updating version in manifest"
  $json = Get-Content $extensionManifestFile  -raw | ConvertFrom-Json
  $json.version = "$($major).$($minor).$($build)"
  if ($buildType -eq "debug") {        
      $fullRev = "$($json.version).$($dateNowForRevision)"
      Write-Output "Adding revision as it's debug to $fullRev"
      $json.version = $fullRev
  }
  $json | ConvertTo-Json | set-content $extensionManifestFile

  #now update all sub task json files
  
  Foreach($task in $tasks) {
      $taskPath = "$RootDir\$task\task.json"
      $shortPath = "$task\task.json"
      Write-Output "Updating version in $shortPath"

      $json = Get-Content $taskPath  -raw | ConvertFrom-Json
      
      $json.version.Major = $version.Major
      $json.version.Minor = $version.Minor
      $json.version.Patch = $version.Build

      if ($buildType -eq "debug") {        
          Write-Output "Updating revision in $shortPath as it's debug to $version.$dateNowForRevision"        
          $json.version | Add-Member -Name "Revision" -Value $dateNowForRevision -MemberType NoteProperty -force          # If you have any resource dependencies, such as javascript files or css files etc, then regardless of how many times you upload a resource file, if the version doesn’t change, then a cached version is always used of that resource file. This is to ensure a new version on each publish
      }
      else {
          $json.version | Add-Member -Name "Revision" -Value ''  -MemberType NoteProperty -force                          # Can't work out how to remove the json, but forcing an empty string gives desired effect
      }

      $json | ConvertTo-Json | set-content $taskPath  
  }    

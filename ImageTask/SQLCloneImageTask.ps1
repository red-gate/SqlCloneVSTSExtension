param()

$ErrorActionPreference = 'Stop'


Write-Debug "Entering script SQLCloneImageTask.ps1"
Import-Module "$PSScriptRoot\Modules\RedGate.SQLClone.PowerShell.dll"

$cloneServer = Get-VstsInput -Name cloneServer -Require
$sourceType = Get-VstsInput -Name sourceType -Require
$imageName = Get-VstsInput -Name imageName -Require
$imageLocation = Get-VstsInput -Name imageLocation -Require

$sourceInstance = Get-VstsInput -Name sourceInstance
$sourceDatabase = Get-VstsInput -Name sourceDatabase
$sourceFileDirectory = Get-VstsInput -Name sourceFileDirectory
$sourceFileNames = Get-VstsInput -Name sourceFileNames
$sourceFilePassword = Get-VstsInput -Name sourceFilePassword


$connectedServiceDetails = Get-VstsEndpoint -Name "$cloneServer" -Require

# Create PSCredential if username is specified
if ($connectedServiceDetails.Auth.Parameters.Username)
{
    $password = ConvertTo-SecureString -String $connectedServiceDetails.Auth.Parameters.Password -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $connectedServiceDetails.Auth.Parameters.Username,$password
}

Connect-SqlClone -ServerUrl $connectedServiceDetails.Url -Credential $credential
Write-Output "Connected to SQL Clone server"

    
    if ($sourceType -eq 'database')
    {
        Write-Output "Source type = database"
        $sqlServerParts = $sourceInstance.Split('\', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($sqlServerParts.Count -ge 3)
        {
            write-error 'SQL Server instance ' + $sourceInstance + ' has not been recognised, if specifying a named instance please use "machine\instance"'
            exit 1
        }
        $cloneSqlServerHost = $sqlServerParts[0]
        $instanceName = ''
        if ($sqlServerParts.Count -ge 2)
        {
            $instanceName = $sqlServerParts[1]
        }
        
        try
        {
            $instance = Get-SqlCloneSqlServerInstance -MachineName $cloneSqlServerHost -InstanceName $instanceName
            Write-Output "Found SQL Server instance"
        }
        catch
        {
            $instances = Get-SqlCloneSqlServerInstance
            $instanceNames = "`n"
            Foreach ($cInstance in $instances)
            {
                $instanceNames += $cInstance.Name + "`n"
            }
            $message = 'SQL Server instance "' + $sourceInstance + '"  has not been added to SQL Clone, available instances:' + $instanceNames
            write-error $message
            exit 1
        }
        try
        {
            $cloneImageLocation = Get-SqlCloneImageLocation $imageLocation
            Write-Output "Found image location"
        }
        catch
        {
            $imageLocations = Get-SqlCloneImageLocation
            $imageLocationNames = "`n"
            Foreach ($cImageLocation in $imageLocations)
            {
                $imageLocationNames += $cImageLocation.Path + "`n"
            }
            $message = 'SQL Clone image location "' + $imageLocation + '"  has not been added to SQL Clone, available locations:' + $imageLocationNames
            write-error $message
            exit 1
        }
        Write-Output "Creating image"
        $NewImage = New-SqlCloneImage -Name $imageName -SqlServerInstance $instance -DatabaseName $sourceDatabase -Destination $cloneImageLocation | Wait-SqlCloneOperation    
        Write-Output "Finished creating image"
    }
    else
    {
        Write-Output "Source type = backup"
        try
        {
            $backupDirectory = Get-SqlCloneBackupLocation -Path $sourceFileDirectory
            Write-Output "Found backup location"
        }
        catch
        {
            $backupLocations = Get-SqlCloneBackupLocation
            $backupLocationNames = "`n"
            Foreach ($cbackupLocation in $backupLocations)
            {
                $backupLocationNames += $cbackupLocation.Path + "`n"
            }
            $message = 'SQL Clone backup location "' + $backupDirectory + '"  has not been added to SQL Clone, available locations:' + $backupLocationNames
            write-error $message
            exit 1
        }
        
        try
        {
            $cloneImageLocation = Get-SqlCloneImageLocation $imageLocation
            Write-Output "Found image location"
        }
        catch
        {
            $imageLocations = Get-SqlCloneImageLocation
            $imageLocationNames = "`n"
            Foreach ($cImageLocation in $imageLocations)
            {
                $imageLocationNames += $cImageLocation.Path + "`n"
            }
            $message = 'SQL Clone image location "' + $imageLocation + '"  has not been added to SQL Clone, available locations:' + $imageLocationNames
            write-error $message
            exit 1
        }
        $backupFiles = $sourceFileNames.Split(';', [System.StringSplitOptions]::RemoveEmptyEntries)
        Write-Output "Creating image from backup"
        $imageCommand = "-Name $imageName  -BackupFileName $backupFiles"
        if($sourceFilePassword)
        {
            $NewImage = New-SqlCloneImage -BackupLocation $backupDirectory -Destination $cloneImageLocation -Name $imageName -BackupFileName $backupFiles -BackupPassword $sourceFilePassword | Wait-SqlCloneOperation
        }
        else
        {
            $NewImage = New-SqlCloneImage -BackupLocation $backupDirectory  -Destination $cloneImageLocation -Name $imageName  -BackupFileName $backupFiles | Wait-SqlCloneOperation
        }
        Write-Output "Finished creating image from backup"
        
    }

  

Write-Debug "Leaving script SQLCloneImageTask.ps1"

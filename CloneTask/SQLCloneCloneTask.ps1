param()

$ErrorActionPreference = 'Stop'


Write-Debug "Entering script SQLCloneCloneTask.ps1"
Import-Module "$PSScriptRoot\Modules\RedGate.SQLClone.PowerShell.dll"
$cloneServer = Get-VstsInput -Name cloneServer -Require
$imageNameForClone = Get-VstsInput -Name imageNameForClone -Require
$cloneSqlServer = Get-VstsInput -Name cloneSqlServer -Require
$cloneName = Get-VstsInput -Name cloneName -Require
$deleteClone = Get-VstsInput -Name deleteClone

$connectedServiceDetails = Get-VstsEndpoint -Name "$cloneServer" -Require

# Create PSCredential if username is specified
if ($connectedServiceDetails.Auth.Parameters.Username)
{
    $password = ConvertTo-SecureString -String $connectedServiceDetails.Auth.Parameters.Password -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $connectedServiceDetails.Auth.Parameters.Username,$password
}

Connect-SqlClone -ServerUrl $connectedServiceDetails.Url -Credential $credential
Write-Output "Connected to SQL Clone server"

        $sqlServerParts = $cloneSqlServer.Split('\', [System.StringSplitOptions]::RemoveEmptyEntries)
        if ($sqlServerParts.Count -ge 3)
        {
            write-error 'SQL Server instance ' + $cloneSqlServer + ' has not been recognised, if specifying a named instance please use "machine\instance"'
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
            $message = 'SQL Server instance "' + $cloneSqlServer + '"  has not been added to SQL Clone, available instances:' + $instanceNames
            write-error $message
            exit 1
        }
        
        try
        {
            $image = Get-SqlCloneImage -Name $imageNameForClone
            Write-Output "Found image"
        }
        catch
        {
            $images = Get-SqlCloneImage
            $imageNames = "`n"
            Foreach ($cImage in $images)
            {
                $imageNames += $cImage.Name + "`n"
            }
            $message = 'SQL Clone image "' + $imageNameForClone + '"  has not been added to SQL Clone, available images:' + $imageNames
            write-error $message
            exit 1
        }
        
        if($deleteClone)
        {
            try
            {
                $clone = Get-SqlClone -Name $cloneName -Location $instance
                Write-Output "Deleting existing clone"
                Remove-SqlClone -Clone $clone | Wait-SqlCloneOperation
            }
            catch
            {
                # Clone didn't exist so nothing to do
            }
        }
        Write-Output "Creating clone"
        $image | New-SqlClone -Name $cloneName -Location $instance | Wait-SqlCloneOperation
        Write-Output "Finished creating clone"        

Write-Debug "Leaving script SQLCloneCloneTask.ps1"

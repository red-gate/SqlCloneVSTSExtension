param()

$ErrorActionPreference = 'Stop'


Write-Debug "Entering script SQLCloneDeleteImageTask.ps1"
Import-Module "$PSScriptRoot\Modules\RedGate.SQLClone.PowerShell.dll"
$cloneServer = Get-VstsInput -Name cloneServer -Require
$imageName = Get-VstsInput -Name imageName -Require

$connectedServiceDetails = Get-VstsEndpoint -Name "$cloneServer" -Require

# Create PSCredential if username is specified
if ($connectedServiceDetails.Auth.Parameters.Username)
{
    $password = ConvertTo-SecureString -String $connectedServiceDetails.Auth.Parameters.Password -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $connectedServiceDetails.Auth.Parameters.Username,$password
}

Connect-SqlClone -ServerUrl $connectedServiceDetails.Url -Credential $credential
Write-Output "Connected to SQL Clone server"
        
        try
        {
            $image = Get-SqlCloneImage -Name $imageName
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
            $message = 'SQL Clone image ' + $imageName + ' does not exist, available images: ' + $imageNames
            write-error $message
            exit 1
        }
        
        Write-Output "Deleting image"
        Remove-SqlCloneImage -Image $image | Wait-SqlCloneOperation
        Write-Output "Finished deleting image"     

Write-Debug "Leaving script SQLCloneDeleteImageTask.ps1"

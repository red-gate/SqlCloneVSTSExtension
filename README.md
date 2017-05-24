# SQLClone-VSTSTask

This is the Visual Studio Team Services(VSTS)/Team Foundation Server(TFS) extension for SQL Clone.

## Endpoints

There is an Endpoint which is used to provide connection details for the SQL Clone Server.

## Tasks

There are three tasks:

Create image
Create clone
Delete clone

## Structure
- extension-manifest.json defines most of the metadata about the plugin.
- images\ is various images shown in the marketplace. These are referenced by extensions-manifest.json.
- overview.md is a markdown file. This is the text shown in the marketplace.
- Each task has its own folder.

## Task structre
- task.json defines the task.
- SQLClone*Task.ps1 is the PowerShell run by the task.
- Modules includes the DLLs for the SQL Clone PowerShell cmdlets - This means that a user doesn't have to install the PowerShell cmdlets on their build agent to get this working.
- ps_modules includes the VstsTaskSdk which the PowerShell for each task uses - [VSTSTASKSDK](https://github.com/Microsoft/vsts-task-lib/blob/master/powershell/Docs/README.md). You can get it using:
    Save-Module -Name VstsTaskSdk
The plugin was built using version 0.8.1

## Development

See Test.md for how to build a version you can test with, rather than a release version.

## Build

1. Install Node, v6.10.3 or later.

2. Ensure that extension-manifest.json and TheTask\task.json have the right version number:
 a. The same version number as each other
 b. A later version number than the one currently on the Marketplace
3. Ensure that extension-manifest.json has your verified account (e.g. redgatesoftware) as publisher, not a test account, if you want this version to be public
4. Place the SQL Clone PowerShell cmdlet dlls in the TaskModules\ClonePowerShell folder. You can get these by installing the SQL Clone PowerShell cmdlets from the Clone Server and copying the directory contents from: %programfiles(x86)%\Red Gate\SQL Clone PowerShell Client\RedGate.SqlClone.Powershell
5. Run build.ps1 to build the VSIX package as an Administrator using PowerShell v5 or later.
6. Upload to the Marketplace and use it. (For internal RG release instructions, see Release.md)

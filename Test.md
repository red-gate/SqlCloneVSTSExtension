# Uploading for testing
## First time set up
1. You need to [create a publisher](http://aka.ms/vsmarketplace-manage) using your Microsoft acccount (ignore the "Not Verified" warning - verification is not required to upload private extensions for testing).
2. You will need access to either TFS 2015 Update 2 or later, or a [Visual Studio Team Services account](https://go.microsoft.com/fwlink/?LinkId=307137&clcid=0x409).

## Building
1. You will need a SQL Clone Server build agents can connect to. 
2. Check the publisher, version and public settings are correct in the [extension-manifest.json](\extension-manifest.json) file:
 - the version must be greater than that on [the marketplace](https://marketplace.visualstudio.com/items?itemName=redgatesoftware.redgateSqlClone)
 - publisher = `\<your personnal publisher>` (if you can't remember the name go to http://aka.ms/vsmarketplace-manage and login with your Microsoft account)
 - public = `false`
3. Update the version in the task.json file for each task to match the extension-manifest version.
4. Place the SQL Clone PowerShell cmdlet dlls in the TaskModules\ClonePowerShell folder. You can get these by installing the SQL Clone PowerShell cmdlets from the Clone Server and copying the directory contents from: %programfiles(x86)%\Red Gate\SQL Clone PowerShell Client\RedGate.SqlClone.Powershell
5. Run build.ps1 to build the VSIX package as an Administrator using PowerShell v5 or later. This will create a `\<your publisher>.redgateSqlClone-<version>.vsix` file inside the `Packages` folder.

## Test on premise TFS
1. Navigate to the Team Foundation Server Extensions page on your server (for example, http://someserver:8080/tfs/_gallery/manage).
2. Click upload new extension and select the file you have just downloaded.
3. After the extension has successfully uploaded, click Install and select the Team Project Collection to install into.
4. In the TFS project, so go Settings>Services and add a SQL Clone Server Endpoint, pointing to your SQL Clone server.

## Test using VSTS
1. Go to http://aka.ms/vsmarketplace-manage.
2. Either Update using the right click menu or select Upload new if not already uploaded.
3. Select the file created earlier and click Upload.
5. Click Share and select your VSTS account.
6. Login to the VSTS account with your Microsoft account. You can test using hosted or local agents, but the agent will need to be able to connect to your SQL Clone Server.

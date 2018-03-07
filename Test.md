# Uploading for testing
## First time set up
1. You need to [create a publisher](http://aka.ms/vsmarketplace-manage) using your Microsoft acccount (ignore the "Not Verified" warning - verification is not required to upload private extensions for testing).
2. You will need access to either TFS 2015 Update 2 or later, or a [Visual Studio Team Services account](https://go.microsoft.com/fwlink/?LinkId=307137&clcid=0x409).

## Building
1. You will need a SQL Clone Server build agents can connect to. 
2. Start by running build.ps1. You will need to enter the version. 
    * the version must be greater than that on [the marketplace](https://marketplace.visualstudio.com/items?itemName=redgatesoftware.redgateSqlClone)
    * Lines crossed out as automated in build.ps1
3. Place the SQL Clone PowerShell cmdlet dlls in the TaskModules\ClonePowerShell folder. You can get these by installing the SQL Clone PowerShell cmdlets from the Clone Server and copying the directory contents from: %programfiles(x86)%\Red Gate\SQL Clone PowerShell Client\RedGate.SqlClone.Powershell
5. Run build.ps1 to build the VSIX package as an Administrator using PowerShell v5 or later. This will create a `\<your publisher>.redgateSqlClone-<version>.vsix` file inside the `Packages` folder.
    - The parameters include the -version and the -build
    - The -version is mandatory
    - The -build is optional, with release being the default
    - Example: Powershell into the directory with the build.ps1 file as administrator. The examples below
      - .\build.ps1 -v 1.0.2 -b debug
      - .\build.ps1 -v 1.0.3

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


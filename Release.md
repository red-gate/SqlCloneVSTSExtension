> :warning: These instructions are for Redgate use only, and will not work outside of Redgate!

# Releasing the VSTS SQL Clone Plugin
## First time set up

1. You need to [create a publisher](http://aka.ms/vsmarketplace-manage) using your Microsoft account (ignore the "Not Verified" warning - you don't need to be verified to publish to Redgate).
2. Ask CORE to add you as a contributor to the `Redgate Software` publisher.

## Releasing

1. Get the version of the VSTS SQL Clone plugin `.vsix` file that you want to release from the Build VSTS Extension build config in TeamCity. File will be called `redgatesoftware.redgateSqlClone-<version>.vsix`.
2. Go to the [Visual Studio marketplace](https://marketplace.visualstudio.com/manage/publishers/redgatesoftware) and log in with your publisher credentials.
3. Right click on the SQL Clone plugin.
4. Select Update
5. Select the vsix file from earlier and click upload.

## Prepare for next development cycle

Update the Build Number in [extension-manifest.json](./extension-manifest.json) and in the task.json of each task.

# Granting permissions for release (You need admin rights to follow these instructions)
1. Make sure you know the email used to create the publisher
2. Goto https://marketplace.visualstudio.com/manage/publishers/redgatesoftware
3. Click the arrow next to the Redgate Software name and select Edit Publisher
4. Goto the roles Tab and click add
5. Type in the persons email and grant them contributor or owner role.
6. Click Save

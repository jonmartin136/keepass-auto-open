# keepass-auto-open

## Installation
1. install KeePass v2.* from https://keepass.info/download.html 
2. copy the [KeePass.ps1](https://github.com/jonmartin136/keepass-auto-open/blob/main/KeePass.ps1) script into the KeePass installation location (default is "C:\Program Files\KeePass Password Safe 2")

## Setup
1. Create a KeePass database (with password)
2. Run the following PowerShell snippet to encrypt the database password, which is machine and user specific, and then create a custom shortcut to auto-open the database

> Assumptions:
> 1. PowerShell Core is installed
> 2. KeePass installed in "C:\Program Files\KeePass Password Safe 2" 
> 3. database created in "%USERPROFILE%\Documents\My Database.kdbx" using password "MY-DATABASE-PASSWORD"
> 4. shortcut to appear on the "Desktop"

```
& 'C:\Program Files\KeePass Password Safe 2\KeePass.ps1' -Password 'MY-DATABASE-PASSWORD'

$shortcut = (New-Object -ComObject 'WScript.Shell').CreateShortcut("$env:USERPROFILE\Desktop\KeePass.lnk")
$shortcut.TargetPath = 'C:\Program Files\PowerShell\7\pwsh.exe'
$shortcut.Arguments = '-File "C:\Program Files\KeePass Password Safe 2\KeePass.ps1" -KdbxFile "%USERPROFILE%\Documents\My Database.kdbx"'
$shortcut.WindowStyle = 7
$shortcut.IconLocation = 'C:\Program Files\KeePass Password Safe 2\KeePass.exe'
$shortcut.Save()
```

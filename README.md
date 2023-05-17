# keepass-auto-open

The assumptions for running the PowerShell code below are you:
1. installed KeePass v2.* from https://keepass.info/download.html using the default location of "C:\Program Files\KeePass Password Safe 2" 
2. created a database in "%USERPROFILE%\Documents\My Database.kdbx" using password "MY-DATABASE-PASSWORD"

```
& 'C:\Program Files\KeePass Password Safe 2\KeePass.ps1' -Password 'MY-DATABASE-PASSWORD'

$shortcut = (New-Object -ComObject 'WScript.Shell').CreateShortcut("$env:USERPROFILE\Desktop\KeePass.lnk")
$shortcut.TargetPath = 'C:\Program Files\PowerShell\7\pwsh.exe'
$shortcut.Arguments = '-File "C:\Program Files\KeePass Password Safe 2\KeePass.ps1" -KdbxFile "%USERPROFILE%\Documents\My Database.kdbx"'
$shortcut.WindowStyle = 7
$shortcut.IconLocation = 'C:\Program Files\KeePass Password Safe 2\KeePass.exe'
$shortcut.Save()

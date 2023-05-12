# keepass-auto-open

& 'C:\Program Files\KeePass Password Safe 2\KeePass.ps1' -Password 'MY-DATABASE-PASSWORD'

$shortcut = (New-Object -ComObject 'WScript.Shell').CreateShortcut("$env:USERPROFILE\Desktop\KeePass.lnk")
$shortcut.TargetPath = 'C:\Program Files\PowerShell\7\pwsh.exe'
$shortcut.Arguments = '-File "C:\Program Files\KeePass Password Safe 2\KeePass.ps1" -KdbxFile "%USERPROFILE%\Documents\My Database.kdbx"'
$shortcut.WindowStyle = 7
$shortcut.IconLocation = 'C:\Program Files\KeePass Password Safe 2\KeePass.exe'
$shortcut.Save()

[CmdletBinding(DefaultParameterSetName='KdbxFile')]
param (
    [Parameter(ParameterSetName='KdbxFile', Mandatory=$true)]
    [string] $KdbxFile,
    [Parameter(ParameterSetName='Password', Mandatory=$true)]
    [string] $Password,
    [Parameter(Mandatory=$false)]
    [string] $Path,
    [Parameter(Mandatory=$false)]
    [switch] $AES
)
begin {

    if (-not $PSCommandPath) { $SCRIPT:PSCommandPath = $SCRIPT:MyInvocation.MyCommand.Path }
    if (-not $PSScriptRoot)  { $SCRIPT:PSScriptRoot = Split-Path -Path $PSCommandPath -Parent }

    if ([System.String]::IsNullOrEmpty($Path)) {
        $Path = Join-Path -Path $env:APPDATA -ChildPath 'KeePass'
    }
    $PwdFile = Join-Path -Path $Path -ChildPath  ('{0}-{1}@{2}{3}.{4}' -F ${env:USERDOMAIN}.ToLower(), ${env:USERNAME}.ToLower(), ($env:COMPUTERNAME).ToUpper(), $(if ($AES) {'-aes'} else {''}), 'pwd')
    $KeyFile = Join-Path -Path $Path -ChildPath  ('{0}-{1}@{2}{3}.{4}' -F ${env:USERDOMAIN}.ToLower(), ${env:USERNAME}.ToLower(), ($env:COMPUTERNAME).ToUpper(), '', 'key')

    if ($PSCmdlet.ParameterSetName -eq 'Password') {
        if (-not (Test-Path -Path $Path -PathType Container)) {
            New-Item -Path $Path -ItemType Directory | Out-Null
        }
        elseif ((Test-Path -Path $PwdFile -PathType Leaf)) {
            Write-Warning -Message ('File "{0}" exists and will be overwritten (password).' -F $PwdFile)
            Remove-Item -Path $PwdFile
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'KdbxFile') {
        $KeePassExec = Join-Path -Path $PSScriptRoot -ChildPath 'KeePass.exe'
        if (-not (Test-Path -Path $KeePassExec -PathType Leaf)) {
            Write-Error -Message ('File "{0}" not found (program).' -F $KeePassExec) -ErrorAction Stop
        }
        if (-not (Test-Path -Path $PwdFile -PathType Leaf)) {
            Write-Error -Message ('File "{0}" not found (password).' -F $PwdFile) -ErrorAction Stop
        }
        if (-not (Test-Path -Path $KdbxFile -PathType Leaf)) {
            Write-Error -Message ('File "{0}" not found (database).' -F $KdbxFile) -ErrorAction Stop
        }
        $PasswordText = Get-Content -Path $PwdFile
        if ($AES) {
            if (-not (Test-Path -Path $KeyFile -PathType Leaf)) {
                Write-Error -Message ('File "{0}" not found (key).' -F $KeyFile) -ErrorAction Stop
            }
            $AESKey = Get-Content $KeyFile
            $SecurePassword = $PasswordText | ConvertTo-SecureString -Key $AESKey 
        }
        else {
            $SecurePassword = $PasswordText | ConvertTo-SecureString 
        }
        $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)))
    }
}
process {
    if ($PSCmdlet.ParameterSetName -eq 'Password') {
        $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
        if ($AES) {
            if (-not (Test-Path -Path $KeyFile -PathType Leaf)) {
                $AESKey = New-Object Byte[] 32
                [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
                $AESKey | Out-File -FilePath $KeyFile
            }
            else {
                $AESKey = Get-Content $KeyFile
            }
            $SecurePassword | ConvertFrom-SecureString -Key $AESKey | Out-File -FilePath $PwdFile
        }
        else {
            $SecurePassword | ConvertFrom-SecureString | Out-File -FilePath $PwdFile
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'KdbxFile') {
        & "$KeePassExec" "$KdbxFile" -pw:"$Password"
    }
}

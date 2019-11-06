<powershell>
write-output "Running User Data Script"
write-host "(host) Running User Data Script"
$OfflineDisks = Get-Disk | Where-Object {$_.OperationalStatus -eq "Offline"}
foreach ($OfflineDisk in $OfflineDisks) {
    Set-Disk $OfflineDisk.Number -isOffline $false
}
# TODO: Implement over SSL: https://github.com/packer-community/packer-windows-plugins/issues/30
# We use a hard-coded password here since the images are short-lived and the packer user
# is (supposed to be) disabled once provisioned manually or by SparkleFormation.
cmd.exe /c net user /add packer.winrm testpass /yes
cmd.exe /c net localgroup administrators packer.winrm /add

Set-ExecutionPolicy -ExecutionPolicy bypass -Force

#Install Chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# RDP
cmd.exe /c netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389
cmd.exe /c reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

# WinRM
write-output "Setting up WinRM"
write-host "(host) setting up WinRM"

cmd.exe /c winrm quickconfig -q
cmd.exe /c winrm quickconfig '-transport:http'
cmd.exe /c winrm set "winrm/config" '@{MaxTimeoutms="1800000"}'
cmd.exe /c winrm set "winrm/config/winrs" '@{MaxMemoryPerShellMB="4096"}'
cmd.exe /c winrm set "winrm/config/service" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/client" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/client/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{CredSSP="true"}'
cmd.exe /c winrm set "winrm/config/listener?Address=*+Transport=HTTP" '@{Port="5985"}'
cmd.exe /c netsh advfirewall firewall set rule group="remote administration" new enable=yes
cmd.exe /c netsh firewall add portopening TCP 5985 "Port 5985"
cmd.exe /c net stop winrm
cmd.exe /c sc config winrm start= auto
cmd.exe /c net start winrm
cmd.exe /c wmic useraccount where "name='packer.winrm'" set PasswordExpires=FALSE

</powershell>

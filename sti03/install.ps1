if($env:computername -ne "sti03"){
    # Moves the item so that it can be called after the reboot
    Copy-Item 'D:\INSTALL.bat' 'C:\Users\sti03\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\INSTALL.bat'

    # Rename PC
    Rename-Computer -NewName "sti03"
    shutdown -r -t 0
}else{
    Remove-Item -Path 'C:\Users\sti03\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\INSTALL.bat'
}

# Debloat Windows using github.com/Sycnex/Windows10Debloater
D:\Windows10Debloater\Windows10SysPrepDebloater.ps1 -Sysprep -Debloat -Privacy

# Install Firefox (Installer from www.mozilla.org/en-US/firefox/all/ NOT THE STUB INSTALLER), MSCVP120.dll, WinFSP, VLC (.msi installer from download.videolan.org/pub/videolan/vlc/), Auto-logon
D:\Firefox.exe -ms -ma
echo 'Installing Firefox...'
Start-Sleep -Seconds 10

D:\vcredist_x86.exe /install /quiet /norestart
echo 'Installing vcredist_x86...'
Start-Sleep -Seconds 10

msiexec.exe /i D:\winfsp.msi /q
echo 'Installing WinFsp...'
Start-Sleep -Seconds 10

msiexec.exe /i D:\vlc.msi /q
echo 'Installing VLC...'
Start-Sleep -Seconds 10

D:\Autologon.exe /accepteula
echo 'Installing Rclone, Remote Backup...' # Not actually but I need them to not get worried that it stopped for 30 seconds.
Start-Sleep -Seconds 30

# Copy over Rclone and Remote Backup to the user root directory # Change the shortcut of Remote backup to the actual location
Copy-Item 'D:\rclone.exe' 'C:\Users\sti03\rclone.exe'; Copy-Item 'D:\rclone.conf' 'C:\Users\sti03\rclone.conf'; Copy-Item 'D:\Remote-Backup' -Destination 'C:\Users\sti03\' -Recurse; Copy-Item 'D:\Remote-Backup\Remote Backup.lnk' 'C:\Users\sti03\Desktop\Remote Backup.lnk'

# Put Remote Backup on startup with Task Scheduler triggers at logon. Disable stopping the task after 3 days and on battery.
schtasks /create /xml "D:\Remote Backup.xml" /tn "\My Tasks\Remote Backup" /ru "sti03\sti03"

# Create bat to reboot / Reboot monthly on the 15th at 12pm
Copy-Item 'D:\reboot.bat' 'C:\Users\sti03\reboot.bat'; schtasks /create /xml "D:\Monthly Reboot.xml" /tn "\My Tasks\Monthly Reboot" /ru "sti03\sti03"

# Shortcut for reboot on Desktop
Copy-Item 'D:\REBOOT.lnk' 'C:\Users\sti03\Desktop\REBOOT.lnk'

# Disable Sleep
powercfg.exe -x -monitor-timeout-ac 0; powercfg.exe -x -monitor-timeout-dc 0; powercfg.exe -x -disk-timeout-ac 0; powercfg.exe -x -disk-timeout-dc 0; powercfg.exe -x -standby-timeout-ac 0; powercfg.exe -x -standby-timeout-dc 0; powercfg.exe -x -hibernate-timeout-ac 0; powercfg.exe -x -hibernate-timeout-dc 0

# Turns on screen saver with password protection after 120s of inactivity
Reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d 1 /f
Reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d 120 /f
Reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaverIsSecure /t REG_SZ /d 1 /f

# Enable RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Switch Timezone
Set-TimeZone -Name 'Eastern Standard Time'

echo **********************************************************************
echo ' MAKE SURE TO CONNECT TO WIFI AND DOWNLOAD THE KEY BEFORE PROCEEDING'
echo **********************************************************************

# Launches firefox and opens gmail
start firefox mail.google.com

pause


# Gets the GC SA username
$filename = Get-ChildItem C:\Users\sti03\Downloads\ -Name -Include *.json
$user = $filename.Substring(0, $filename.Length - 5)

# Moves the key to the correct directory
$oldjsonpath = "C:\Users\sti03\Downloads\" + $user + ".json"
Move-Item -Path $oldjsonpath -Destination C:\Users\sti03\key.json

# Adds Rclone bucket mouting as a service. Rclone must a have a remote config setup named 'gcs'
# Remeber to use M: for Remote Backup backup location
$pathname = 'C:\Users\sti03\rclone.exe mount gcs:st-' + $user + ' M: --network-mode --vfs-cache-mode minimal --config C:\Users\sti03\rclone.conf'
New-Service -Name Rclone -BinaryPathName $pathname

# Deletes browser data
taskkill /F /im firefox.exe
Remove-Item -path C:\Users\sti03\AppData\Roaming\Mozilla\Firefox\ -Recurse

# Disables script running
Set-ExecutionPolicy Default -Force

# Reboot
echo Installation complete. Rebooting in 10 seconds.
shutdown -r -t 10 -f
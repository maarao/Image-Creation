echo *******************************************************************
echo 'MAKE SURE TO CONNECT TO WIFI AND DOWNLOAD THE KEY BEFORE PROCEEDING'
echo *******************************************************************

# Launches edge and opens gmail
start firefox mail.google.com

pause


# Gets the GC SA username
$filename = Get-ChildItem C:\Users\sti02\Downloads\ -Name -Include *.json
$user = $filename.Substring(0, $filename.Length - 5)

# Moves the key to the correct directory
$oldjsonpath = "C:\Users\sti02\Downloads\" + $user + ".json"
Move-Item -Path $oldjsonpath -Destination C:\Users\sti02\key.json

# Adds Rclone bucket mouting as a service. Rclone must a have a remote config setup named 'gcs'
# Remeber to use M: for Remote Backup backup location
$pathname = 'C:\Users\sti02\rclone\rclone.exe mount gcs:st-' + $user + ' M: --network-mode --vfs-cache-mode minimal --config C:\Users\sti02\AppData\Roaming\rclone\rclone.conf --log-file C:\Users\sti02\rclone\log_mount.txt'
New-Service -Name Rclone -BinaryPathName $pathname

# Deletes browser data
taskkill /F /im firefox.exe
Remove-Item -path C:\Users\sti02\AppData\Roaming\Mozilla\Firefox\ -recurse

# Remove from startup
Remove-Item -path 'C:\Users\sti02\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\launch_after.bat'

# Reboot
echo Installation complete. Rebooting in 10 seconds.
shutdown -r -t 10 -f
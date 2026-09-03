Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("c:\Users\USER\Projek_PI\Aplikasi_Reminder\aplikasi_reminder\assets\icons\app_icon.png")
Write-Output "Width: $($img.Width), Height: $($img.Height)"
$img.Dispose()

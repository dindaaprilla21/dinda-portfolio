Add-Type -AssemblyName System.Drawing
$newWidth = 800
$newHeight = 200
$bmp = New-Object System.Drawing.Bitmap($newWidth, [int]$newHeight)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)
$font = New-Object System.Drawing.Font("Arial", [float]60, [System.Drawing.FontStyle]::Bold)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#94A3B8"))
$format = New-Object System.Drawing.StringFormat
$format.Alignment = [System.Drawing.StringAlignment]::Center
$format.LineAlignment = [System.Drawing.StringAlignment]::Center
$rect = New-Object System.Drawing.RectangleF([float]0, [float]0, [float]$newWidth, [float]$newHeight)
$g.DrawString("REMINDER AI", $font, $brush, $rect, $format)
$bmp.Save("c:\Users\USER\Projek_PI\Aplikasi_Reminder\aplikasi_reminder\assets\icons\branding.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()

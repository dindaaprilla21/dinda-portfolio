Add-Type -AssemblyName System.Drawing
$srcImg = [System.Drawing.Image]::FromFile("c:\Users\USER\Projek_PI\Aplikasi_Reminder\aplikasi_reminder\assets\icons\app_icon.png")
$newWidth = $srcImg.Width
$newHeight = $srcImg.Height + (($srcImg.Height / 100) * 40)
$bmp = New-Object System.Drawing.Bitmap($newWidth, [int]$newHeight)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)
$g.DrawImage($srcImg, 0, 0, $srcImg.Width, $srcImg.Height)
$fontSize = ($srcImg.Width / 100) * 11
$font = New-Object System.Drawing.Font("Arial", [float]$fontSize, [System.Drawing.FontStyle]::Bold)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#5E6D8C"))
$format = New-Object System.Drawing.StringFormat
$format.Alignment = [System.Drawing.StringAlignment]::Center
$rectHeight = [float]($newHeight - $srcImg.Height)
$rect = New-Object System.Drawing.RectangleF([float]0, [float]$srcImg.Height, [float]$newWidth, [float]$rectHeight)
$g.DrawString("REMINDER AI", $font, $brush, $rect, $format)
$bmp.Save("c:\Users\USER\Projek_PI\Aplikasi_Reminder\aplikasi_reminder\assets\icons\splash_icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
$srcImg.Dispose()

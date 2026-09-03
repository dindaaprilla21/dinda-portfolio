Add-Type -AssemblyName System.Drawing

$iconPath = "c:\Users\USER\Projek_PI\Aplikasi_Reminder\aplikasi_reminder\assets\icons\app_icon.png"

# First, read original image if backup exists or load current
$srcImg = [System.Drawing.Image]::FromFile($iconPath)
$size = 1254
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::White)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Draw srcImg centered at 45% scale (564x564) to ensure 0% cropping on Android 12 squircle
$targetSize = [int]($size * 0.45)
$offset = [int](($size - $targetSize) / 2)
$g.DrawImage($srcImg, $offset, $offset, $targetSize, $targetSize)

$srcImg.Dispose()

# Save to temporary first, then overwrite
$tmpPath = "c:\Users\USER\Projek_PI\Aplikasi_Reminder\aplikasi_reminder\assets\icons\tmp_app_icon.png"
$bmp.Save($tmpPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()

Move-Item -Path $tmpPath -Destination $iconPath -Force

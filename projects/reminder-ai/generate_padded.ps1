Add-Type -AssemblyName System.Drawing

$srcImg = [System.Drawing.Image]::FromFile("c:\Users\USER\Projek_PI\Aplikasi_Reminder\aplikasi_reminder\assets\icons\app_icon.png")
$size = 1254
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Draw srcImg centered at 65% scale (815x815)
$targetSize = [int]($size * 0.65)
$offset = [int](($size - $targetSize) / 2)
$g.DrawImage($srcImg, $offset, $offset, $targetSize, $targetSize)

$bmp.Save("c:\Users\USER\Projek_PI\Aplikasi_Reminder\aplikasi_reminder\assets\icons\splash_padded.png", [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
$srcImg.Dispose()

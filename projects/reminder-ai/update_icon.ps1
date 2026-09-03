Add-Type -AssemblyName System.Drawing

$iconPath = "c:\Users\USER\Projek_PI\Aplikasi_Reminder\aplikasi_reminder\assets\icons\app_icon.png"
$srcImg = [System.Drawing.Image]::FromFile($iconPath)
$size = 1254
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Draw srcImg centered at 68% scale to give standard 16% padding for Android 12+ compatibility
$targetSize = [int]($size * 0.68)
$offset = [int](($size - $targetSize) / 2)
$g.DrawImage($srcImg, $offset, $offset, $targetSize, $targetSize)

$srcImg.Dispose()

# Overwrite app_icon.png directly
$bmp.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()

# Delete splash_padded.png
$paddedPath = "c:\Users\USER\Projek_PI\Aplikasi_Reminder\aplikasi_reminder\assets\icons\splash_padded.png"
if (Test-Path $paddedPath) {
    Remove-Item -Path $paddedPath -Force
}

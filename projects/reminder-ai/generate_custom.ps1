Add-Type -AssemblyName System.Drawing

$srcImg = [System.Drawing.Image]::FromFile("c:\Users\USER\Projek_PI\Aplikasi_Reminder\aplikasi_reminder\assets\icons\app_icon.png")

# Scale srcImg to 400x400
$scaledSrc = New-Object System.Drawing.Bitmap(400, 400)
$gSrc = [System.Drawing.Graphics]::FromImage($scaledSrc)
$gSrc.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gSrc.DrawImage($srcImg, 0, 0, 400, 400)
$gSrc.Dispose()

# Create 1024x1024 transparent
$bmp = New-Object System.Drawing.Bitmap(1024, 1024)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# Create rounded rect path
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$rect = New-Object System.Drawing.Rectangle([int]312, [int]200, [int]400, [int]400)
$radius = 120
$path.AddArc($rect.X, $rect.Y, $radius, $radius, 180, 90)
$path.AddArc($rect.X + $rect.Width - $radius, $rect.Y, $radius, $radius, 270, 90)
$path.AddArc($rect.X + $rect.Width - $radius, $rect.Y + $rect.Height - $radius, $radius, $radius, 0, 90)
$path.AddArc($rect.X, $rect.Y + $rect.Height - $radius, $radius, $radius, 90, 90)
$path.CloseFigure()

# Create TextureBrush from scaled image and translate it to match rect
$tb = New-Object System.Drawing.TextureBrush($scaledSrc)
$tb.TranslateTransform($rect.X, $rect.Y)
$g.FillPath($tb, $path)

# Draw text below
$font = New-Object System.Drawing.Font("Arial", [float]56, [System.Drawing.FontStyle]::Bold)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#5E6D8C"))
$format = New-Object System.Drawing.StringFormat
$format.Alignment = [System.Drawing.StringAlignment]::Center
$textRect = New-Object System.Drawing.RectangleF([float]0, [float]650, [float]1024, [float]200)
$g.DrawString("REMINDER AI", $font, $brush, $textRect, $format)

$bmp.Save("c:\Users\USER\Projek_PI\Aplikasi_Reminder\aplikasi_reminder\assets\icons\splash_custom.png", [System.Drawing.Imaging.ImageFormat]::Png)

$tb.Dispose()
$g.Dispose()
$bmp.Dispose()
$scaledSrc.Dispose()
$srcImg.Dispose()

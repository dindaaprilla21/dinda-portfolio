# =====================================================================
# SETUP GITHUB PROFILE README - da133450-ux
# Script ini akan membuat repo 'da133450-ux' dan upload Profile README
# =====================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$GitHubToken
)

if (-not $GitHubToken) {
    # Ambil dari git credential jika ada
    $cred = cmd /c "echo protocol=https&echo host=github.com" | git credential fill
    foreach ($line in ($cred -split "`r?`n")) {
        if ($line -like "password=*") {
            $GitHubToken = $line.Substring(9)
            break
        }
    }
}

$Username = "da133450-ux"
$RepoName = "da133450-ux"
$Headers = @{
    "Authorization"        = "Bearer $GitHubToken"
    "Accept"               = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent"           = "Antigravity-Portfolio-Setup"
}

Write-Host "`n Setup GitHub Profile README untuk $Username" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor DarkGray

# Langkah 1: Cek apakah repo sudah ada
Write-Host "`n[1/3] Memeriksa repositori $Username/$RepoName..." -ForegroundColor Yellow
$checkUrl = "https://api.github.com/repos/$Username/$RepoName"
$repoExists = $false
try {
    $response = Invoke-RestMethod -Uri $checkUrl -Headers $Headers -Method GET -ErrorAction Stop
    $repoExists = $true
    Write-Host "      Repositori sudah ada!" -ForegroundColor Green
} catch {
    Write-Host "      Repositori belum ada, akan dibuat..." -ForegroundColor Yellow
}

# Langkah 2: Buat repo jika belum ada
if (-not $repoExists) {
    Write-Host "`n[2/3] Membuat repositori $Username/$RepoName..." -ForegroundColor Yellow
    $createBody = @{
        name        = $RepoName
        description = "GitHub Profile README - Dinda Aprilla Dalimunthe"
        private     = $false
        auto_init   = $true
    } | ConvertTo-Json

    try {
        $createResponse = Invoke-RestMethod -Uri "https://api.github.com/user/repos" `
            -Headers $Headers -Method POST -Body $createBody -ContentType "application/json"
        Write-Host "      Repositori berhasil dibuat!" -ForegroundColor Green
        Start-Sleep -Seconds 3
    } catch {
        Write-Host "      Gagal membuat repositori: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "      Detail: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        exit 1
    }
} else {
    Write-Host "`n[2/3] Repositori sudah ada, lanjut upload README." -ForegroundColor Green
}

# Langkah 3: Upload README.md
Write-Host "`n[3/3] Mengupload Profile README..." -ForegroundColor Yellow

$readmePath = Join-Path $PSScriptRoot "github-profile-readme\README.md"
if (-not (Test-Path $readmePath)) {
    Write-Host "      File $readmePath tidak ditemukan!" -ForegroundColor Red
    exit 1
}

$ReadmeContent = Get-Content -Path $readmePath -Raw -Encoding UTF8
$encodedContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ReadmeContent))

# Cek file README.md yang ada di repo untuk mendapatkan SHA jika sudah ada
$fileUrl = "https://api.github.com/repos/$Username/$RepoName/contents/README.md"
$existingSha = $null
try {
    $existingFile = Invoke-RestMethod -Uri $fileUrl -Headers $Headers -Method GET -ErrorAction Stop
    $existingSha = $existingFile.sha
    Write-Host "      README lama ditemukan (SHA: $existingSha), akan diperbarui..." -ForegroundColor Yellow
} catch {
    Write-Host "      Membuat README baru di repositori..." -ForegroundColor Yellow
}

# Upload/Update README
$uploadBody = @{
    message   = "Add rich GitHub Profile README connected to portfolio"
    content   = $encodedContent
    committer = @{
        name  = "Dinda Aprilla"
        email = "da133450@gmail.com"
    }
}
if ($existingSha) { $uploadBody["sha"] = $existingSha }

try {
    $uploadJson = $uploadBody | ConvertTo-Json -Depth 5
    $uploadResponse = Invoke-RestMethod -Uri $fileUrl -Headers $Headers `
        -Method PUT -Body $uploadJson -ContentType "application/json"
    Write-Host "      README.md profil GitHub berhasil dipasang!" -ForegroundColor Green
} catch {
    Write-Host "      Gagal upload README: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "      Detail: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    exit 1
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 60) -ForegroundColor DarkGray
Write-Host "SELESAI! Profil GitHub kamu sudah terhubung dan aktif!" -ForegroundColor Green
Write-Host ""
Write-Host "Cek langsung di: https://github.com/da133450-ux" -ForegroundColor Cyan
Write-Host "Halaman Overview GitHub kamu sekarang menampilkan semua proyek dan link portofolio!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor DarkGray

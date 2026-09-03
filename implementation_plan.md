# Implementation Plan - Modern Web Portfolio Dinda Aprilla Dalimunthe

Pengembangan website portfolio pribadi yang interaktif, modern, dan futuristik untuk **Dinda Aprilla Dalimunthe**, Fresh Graduate Teknik Informatika. Website ini mengusung visual *dark futuristic theme* dengan aksen neon magenta/pink glowing borders khas dari referensi gambar pengguna, serta fitur showcase proyek akademik lengkap, statistik keahlian, filter proyek, modal detail interaktif, dan form kontak.

## User Review Required

> [!IMPORTANT]
> **Tema & Branding Visual**: Desain mengikuti tema warna *dark navy background* (`#0a0f1d`) dengan sentuhan border glowing neon magenta (`#ff007f` / `#ec4899`) persis seperti gambar proyek akademik yang Anda unggah.
> **Fitur Proyek**: Semua 6 proyek akademik dari gambar Anda dimasukkan dengan deskripsi lengkap, tag teknologi, serta modal visualizer interaktif.

> [!NOTE]
> Proyek yang disertakan meliputi:
> 1. **Mobile Reminder App** (Flutter, Dart, SQLite, Rule-Based System)
> 2. **Smart Doorlock System** (ESP32, IoT, Sensors, Web Control)
> 3. **Aplikasi Pemesanan Tiket** (Flutter, Dart, Local Storage, UI/UX)
> 4. **Aplikasi Karaoke Berbasis Web** (HTML/CSS/JS, Web Audio API, Lyrics Sync)
> 5. **Game 2D (FlyHero)** (JavaScript, HTML5 Canvas, Game Physics)
> 6. **Web E-Commerce Sederhana** (HTML, CSS, JS, Responsive Layout)

## Proposed Changes

### Web Application Architecture

Folder workspace: `c:\Users\USER\Documents\Fortofolio Dinda`

#### [NEW] `index.html`
- Structure HTML5 semantic dengan title & meta SEO optimal.
- Responsive Navbar (*Beranda, Tentang, Keahlian, Proyek, Kontak*).
- **Hero Section**: Bio singkat, badge "Fresh Graduate Teknik Informatika", tombol CTA download CV & kontak.
- **Tentang Saya**: Ringkasan profesional lengkap Dinda Aprilla Dalimunthe.
- **Keahlian & Core Competencies**: Visual progress bar & pills untuk Flutter, Dart, SQLite, Rule-Based Systems, Web Dev, & IoT.
- **Pengalaman Proyek ("PENGALAMAN PROYEK")**: Filter tab interaktif (*Semua, Mobile App, Web & Game, IoT*) dan 6 Kartu Proyek bergaya neon card.
- **Interactive Project Modal**: Pop-up detail mendalam untuk tiap proyek ketika diklik.
- **Kontak & Footer**: Form kontak dengan notifikasi Toast interaktif + link media sosial.

#### [NEW] `styles.css`
- Core CSS Design System: CSS Variables untuk neon magenta glow effects, glassmorphism, responsive grid, dynamic hover transformations.
- Custom Scrollbar, Typography (Inter / Google Fonts), Keyframe Animations untuk pulse neon glow.

#### [NEW] `app.js`
- Logika JavaScript Vanilla:
  - Filter proyek berdasarkan kategori.
  - Modal interaktif untuk menampilkan detail 6 proyek akademik.
  - Live preview interactive mini-game demo / interactive audio visualizer mock.
  - Smooth scrolling navigation & active section highlighter.
  - Toast notification saat submit form kontak.

#### [NEW] `assets/`
- Folder menyimpan screenshot preview resolusi tinggi untuk 6 proyek akademik yang telah digenerasi.

## Verification Plan

### Automated Verification
- Menjalankan local development server (`npx serve .` atau `python -m http.server`) untuk memverifikasi load time dan kebebasan dari JavaScript error.

### Manual Verification
- **Visual Audit**: Memastikan layout, gradasi warna navy-neon pink, dan typo persis sesuai ekspektasi.
- **Interaktivitas Modal**: Mengklik tiap proyek untuk memastikan modal detail dan screenshot muncul secara presisi.
- **Filter Proyek**: Memverifikasi filter *Semua*, *Mobile App*, *Web & Game*, dan *IoT*.
- **Responsivitas Mobile**: Memeriksa tampilan di layar HP / mobile via browser responsive view mode.

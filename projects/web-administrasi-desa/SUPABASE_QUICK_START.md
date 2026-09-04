# Supabase Database Integration - Quick Start

## 🎉 Apa yang Sudah Dibuat?

Sistem backend database menggunakan **Supabase** telah berhasil diintegrasikan ke website Desa Legok! Berikut yang sudah selesai:

### ✅ Yang Sudah Selesai:

1. **Supabase Client & Configuration**
   - ✅ Installed `@supabase/supabase-js`
   - ✅ Created `src/config/supabaseClient.js`
   - ✅ Environment variables setup (`.env.example`)

2. **Database Services**
   - ✅ `suratService.js` - Untuk pengajuan surat
   - ✅ `pengaduanService.js` - Untuk laporan pengaduan
   - ✅ `beritaService.js` - Untuk berita/artikel
   - ✅ `chatService.js` - Untuk chat messages

3. **Authentication System**
   - ✅ `AuthContext.jsx` - Context untuk manage auth state
   - ✅ `AdminLogin.jsx` - Updated untuk Supabase Auth
   - ✅ `AdminSidebar.jsx` - Logout functionality
   - ✅ `App.jsx` - Protected routes dengan auth check

4. **Admin Components**
   - ✅ `TabelPengajuanSurat.jsx` - Fetch data dari Supabase
   - ✅ Loading states & error handling
   - ✅ Real-time status updates

5. **Chat Integration**
   - ✅ `FloatingChatBubble.jsx` - Save messages ke Supabase

6. **Documentation**
   - ✅ `SUPABASE_SETUP_GUIDE.md` - Panduan setup lengkap

---

## 🚀 Langkah Selanjutnya (Yang Perlu Anda Lakukan)

### 1. Setup Supabase Project

Ikuti panduan lengkap di file: **`SUPABASE_SETUP_GUIDE.md`**

**Ringkasan singkat:**
1. Buat akun di [supabase.com](https://supabase.com)
2. Buat project baru
3. Copy API keys (URL & anon key)
4. Buat file `.env` di folder `desa-legok-website1`
5. Isi dengan:
   ```env
   VITE_SUPABASE_URL=https://your-project.supabase.co
   VITE_SUPABASE_ANON_KEY=your-anon-key-here
   ```

### 2. Buat Database Tables

Di Supabase Dashboard → SQL Editor, jalankan SQL script yang ada di `SUPABASE_SETUP_GUIDE.md` untuk membuat:
- Table `admins`
- Table `pengajuan_surat`
- Table `laporan_pengaduan`
- Table `berita`
- Table `chat_messages`

### 3. Setup Row Level Security (RLS)

Jalankan SQL script RLS policies yang ada di guide untuk keamanan database.

### 4. Buat Admin User

1. Di Supabase Dashboard → Authentication → Users
2. Klik "Add user" → "Create new user"
3. Isi email & password
4. Centang "Auto Confirm User"
5. Jalankan SQL untuk insert ke table `admins`:
   ```sql
   INSERT INTO admins (email, nama_lengkap, role)
   VALUES ('your-email@example.com', 'Admin Desa Legok', 'admin');
   ```

### 5. Restart Dev Server

```bash
# Stop server (Ctrl+C)
# Start lagi
npm run dev
```

### 6. Test Login

1. Buka `http://localhost:5173/admin/login`
2. Login dengan email & password yang sudah dibuat
3. Coba fitur-fitur admin panel

---

## 📁 Struktur File Baru

```
desa-legok-website1/
├── .env                          # ⚠️ BUAT FILE INI (jangan commit!)
├── .env.example                  # ✅ Template untuk .env
├── src/
│   ├── config/
│   │   └── supabaseClient.js     # ✅ Supabase configuration
│   ├── services/
│   │   ├── suratService.js       # ✅ Pengajuan surat CRUD
│   │   ├── pengaduanService.js   # ✅ Laporan pengaduan CRUD
│   │   ├── beritaService.js      # ✅ Berita CRUD
│   │   └── chatService.js        # ✅ Chat messages
│   ├── contexts/
│   │   └── AuthContext.jsx       # ✅ Authentication context
│   └── ...

SUPABASE_SETUP_GUIDE.md           # ✅ Panduan setup lengkap
```

---

## 🔧 Fitur yang Sudah Terintegrasi

### Admin Panel
- ✅ **Login dengan Supabase Auth** (email/password)
- ✅ **Logout functionality**
- ✅ **Protected routes** (redirect ke login jika belum auth)
- ✅ **Display user email** di sidebar

### Tabel Pengajuan Surat
- ✅ **Fetch data dari Supabase** dengan pagination
- ✅ **Search** berdasarkan nama/jenis surat
- ✅ **Filter** berdasarkan status
- ✅ **Update status** (pending → diproses → selesai/ditolak)
- ✅ **Loading states** saat fetch data
- ✅ **Error handling** dengan pesan user-friendly

### Chat Bubble
- ✅ **Save chat messages** ke Supabase setelah N8N response
- ✅ **Store user info** (nama, telepon, pesan, response)

---

## ⏭️ Yang Belum Selesai (Opsional untuk Nanti)

### Komponen yang Belum Diupdate:
- ⏳ `TabelLaporanPengaduan.jsx` - Masih pakai sample data
- ⏳ Berita components - Masih pakai hardcoded data

### Fitur Tambahan yang Bisa Ditambahkan:
- 📊 Dashboard statistics (total pengajuan, status breakdown)
- 🔔 Real-time notifications (Supabase Realtime)
- 📎 File upload untuk lampiran pengaduan
- 📧 Email notifications
- 📱 Public form untuk pengajuan surat dari website

---

## 🐛 Troubleshooting

### Error: "Missing Supabase environment variables"
**Solusi:** Pastikan file `.env` sudah dibuat dan berisi `VITE_SUPABASE_URL` dan `VITE_SUPABASE_ANON_KEY`

### Error: "relation does not exist"
**Solusi:** Jalankan SQL script untuk membuat tables di Supabase SQL Editor

### Tidak bisa login
**Solusi:** 
1. Pastikan user sudah dibuat di Supabase Authentication
2. Pastikan "Auto Confirm User" dicentang
3. Pastikan data admin sudah di-insert ke table `admins`

### Data tidak muncul di tabel
**Solusi:**
1. Check RLS policies sudah di-setup
2. Check di Supabase Table Editor apakah data ada
3. Check browser console untuk error messages

---

## 📞 Support

Jika ada masalah atau pertanyaan:
1. Check `SUPABASE_SETUP_GUIDE.md` untuk panduan detail
2. Check browser console untuk error messages
3. Check Supabase Dashboard → Logs untuk server errors

---

## 🎯 Next Steps Recommendation

**Prioritas Tinggi:**
1. ✅ Setup Supabase project (ikuti SUPABASE_SETUP_GUIDE.md)
2. ✅ Buat admin user dan test login
3. ✅ Insert sample data untuk testing

**Prioritas Sedang:**
4. Update `TabelLaporanPengaduan.jsx` untuk pakai Supabase
5. Update komponen Berita untuk pakai Supabase
6. Add dashboard statistics

**Prioritas Rendah:**
7. Implement real-time features
8. Add file upload functionality
9. Setup email notifications

---

## 📝 Notes

- **Database:** PostgreSQL (via Supabase)
- **Authentication:** Supabase Auth (JWT-based)
- **API:** Auto-generated REST API dari Supabase
- **Security:** Row Level Security (RLS) policies
- **Free Tier:** 500MB database, 2GB bandwidth, unlimited API requests

**Selamat menggunakan Supabase! 🎉**

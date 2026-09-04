# Supabase Setup Guide

## Langkah 1: Buat Akun Supabase

1. Buka [https://supabase.com](https://supabase.com)
2. Klik **"Start your project"** atau **"Sign Up"**
3. Daftar menggunakan GitHub atau email

## Langkah 2: Buat Project Baru

1. Setelah login, klik **"New Project"**
2. Isi informasi project:
   - **Name**: `desa-legok-db` (atau nama lain)
   - **Database Password**: Buat password yang kuat (SIMPAN password ini!)
   - **Region**: Pilih **Southeast Asia (Singapore)** untuk performa terbaik
   - **Pricing Plan**: Pilih **Free** (sudah cukup untuk project ini)
3. Klik **"Create new project"**
4. Tunggu ~2 menit sampai project selesai dibuat

## Langkah 3: Dapatkan API Keys

1. Setelah project siap, buka **Settings** (icon gear di sidebar kiri)
2. Pilih **API** di menu Settings
3. Copy 2 nilai ini:
   - **Project URL** (contoh: `https://abcdefgh.supabase.co`)
   - **anon public key** (key yang panjang, bukan service_role key!)

## Langkah 4: Setup Environment Variables

1. Buka folder project: `desa-legok-website1`
2. Buat file baru bernama `.env` (perhatikan titik di depan!)
3. Copy isi dari `.env.example` ke `.env`
4. Ganti nilai dengan API keys Anda:

```env
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

> ⚠️ **PENTING**: Jangan commit file `.env` ke Git! File ini sudah ada di `.gitignore`

## Langkah 5: Buat Database Tables

1. Di Supabase Dashboard, klik **SQL Editor** di sidebar kiri
2. Klik **"New query"**
3. Copy dan paste SQL script di bawah ini
4. Klik **"Run"** untuk execute

### SQL Script - Copy Semua Ini:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Table: admins
CREATE TABLE admins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  nama_lengkap TEXT NOT NULL,
  role TEXT DEFAULT 'admin',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Table: pengajuan_surat
CREATE TABLE pengajuan_surat (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nama TEXT NOT NULL,
  nik TEXT NOT NULL,
  telepon TEXT NOT NULL,
  email TEXT,
  jenis_surat TEXT NOT NULL,
  keperluan TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'diproses', 'selesai', 'ditolak')),
  catatan_admin TEXT,
  tanggal_pengajuan TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  tanggal_selesai TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Table: laporan_pengaduan
CREATE TABLE laporan_pengaduan (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nama TEXT NOT NULL,
  nik TEXT,
  telepon TEXT NOT NULL,
  email TEXT,
  kategori TEXT NOT NULL CHECK (kategori IN ('infrastruktur', 'pelayanan', 'lingkungan', 'keamanan', 'lainnya')),
  judul TEXT NOT NULL,
  deskripsi TEXT NOT NULL,
  lokasi TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'ditinjau', 'diproses', 'selesai', 'ditolak')),
  prioritas TEXT DEFAULT 'sedang' CHECK (prioritas IN ('rendah', 'sedang', 'tinggi')),
  tanggapan_admin TEXT,
  tanggal_laporan TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  tanggal_selesai TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Table: berita
CREATE TABLE berita (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  judul TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  konten TEXT NOT NULL,
  excerpt TEXT,
  kategori TEXT,
  gambar_url TEXT,
  penulis TEXT NOT NULL,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  views INTEGER DEFAULT 0,
  tanggal_publikasi TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Table: chat_messages
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nama TEXT,
  email TEXT,
  telepon TEXT,
  pesan TEXT NOT NULL,
  n8n_response TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_pengajuan_status ON pengajuan_surat(status);
CREATE INDEX idx_pengajuan_tanggal ON pengajuan_surat(tanggal_pengajuan DESC);
CREATE INDEX idx_pengaduan_status ON laporan_pengaduan(status);
CREATE INDEX idx_pengaduan_tanggal ON laporan_pengaduan(tanggal_laporan DESC);
CREATE INDEX idx_berita_slug ON berita(slug);
CREATE INDEX idx_berita_status ON berita(status);
CREATE INDEX idx_berita_publikasi ON berita(tanggal_publikasi DESC);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers to auto-update updated_at
CREATE TRIGGER update_admins_updated_at BEFORE UPDATE ON admins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pengajuan_surat_updated_at BEFORE UPDATE ON pengajuan_surat
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_laporan_pengaduan_updated_at BEFORE UPDATE ON laporan_pengaduan
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_berita_updated_at BEFORE UPDATE ON berita
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Langkah 6: Setup Row Level Security (RLS)

Jalankan SQL script ini untuk mengatur keamanan:

```sql
-- Enable RLS on all tables
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE pengajuan_surat ENABLE ROW LEVEL SECURITY;
ALTER TABLE laporan_pengaduan ENABLE ROW LEVEL SECURITY;
ALTER TABLE berita ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Policies for pengajuan_surat
-- Public can insert (create submissions)
CREATE POLICY "Public can create pengajuan surat"
  ON pengajuan_surat FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Public can view all submissions (for now)
CREATE POLICY "Public can view pengajuan surat"
  ON pengajuan_surat FOR SELECT
  TO anon, authenticated
  USING (true);

-- Only authenticated users (admins) can update
CREATE POLICY "Admins can update pengajuan surat"
  ON pengajuan_surat FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Only authenticated users (admins) can delete
CREATE POLICY "Admins can delete pengajuan surat"
  ON pengajuan_surat FOR DELETE
  TO authenticated
  USING (true);

-- Policies for laporan_pengaduan
CREATE POLICY "Public can create laporan pengaduan"
  ON laporan_pengaduan FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Public can view laporan pengaduan"
  ON laporan_pengaduan FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can update laporan pengaduan"
  ON laporan_pengaduan FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Admins can delete laporan pengaduan"
  ON laporan_pengaduan FOR DELETE
  TO authenticated
  USING (true);

-- Policies for berita
-- Public can view published news only
CREATE POLICY "Public can view published berita"
  ON berita FOR SELECT
  TO anon, authenticated
  USING (status = 'published' OR auth.role() = 'authenticated');

-- Only authenticated users can insert/update/delete
CREATE POLICY "Admins can manage berita"
  ON berita FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Policies for chat_messages
CREATE POLICY "Public can create chat messages"
  ON chat_messages FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Admins can view chat messages"
  ON chat_messages FOR SELECT
  TO authenticated
  USING (true);

-- Policies for admins table
CREATE POLICY "Admins can view admins"
  ON admins FOR SELECT
  TO authenticated
  USING (true);
```

## Langkah 7: Setup Authentication

1. Di Supabase Dashboard, klik **Authentication** di sidebar
2. Klik **Policies** (sudah di-setup di langkah 6)
3. Klik **Users** untuk manage users
4. Klik **"Add user"** → **"Create new user"**
5. Isi:
   - **Email**: email admin Anda (contoh: `admin@desalegok.id`)
   - **Password**: password yang kuat
   - **Auto Confirm User**: ✅ Centang ini
6. Klik **"Create user"**

## Langkah 8: Insert Admin Data

Setelah membuat user di Authentication, tambahkan data admin ke table:

```sql
-- Ganti email dengan email yang Anda gunakan saat membuat user
INSERT INTO admins (email, nama_lengkap, role)
VALUES ('admin@desalegok.id', 'Administrator Desa Legok', 'admin');
```

## Langkah 9: Insert Sample Data (Optional)

Untuk testing, Anda bisa insert data sample:

```sql
-- Sample pengajuan surat
INSERT INTO pengajuan_surat (nama, nik, telepon, email, jenis_surat, keperluan, status)
VALUES 
  ('Ahmad Fauzi', '3201234567890001', '081234567890', 'ahmad@email.com', 'Surat Keterangan Usaha', 'Untuk mengajukan pinjaman bank', 'pending'),
  ('Siti Nurhaliza', '3201234567890002', '081234567891', 'siti@email.com', 'KTP', 'KTP hilang', 'diproses'),
  ('Budi Santoso', '3201234567890003', '081234567892', 'budi@email.com', 'Kartu Keluarga', 'Penambahan anggota keluarga', 'selesai');

-- Sample laporan pengaduan
INSERT INTO laporan_pengaduan (nama, nik, telepon, email, kategori, judul, deskripsi, lokasi, status, prioritas)
VALUES 
  ('Dewi Lestari', '3201234567890004', '081234567893', 'dewi@email.com', 'infrastruktur', 'Jalan Rusak', 'Jalan di RT 02 banyak lubang', 'RT 02 RW 01', 'pending', 'tinggi'),
  ('Rina Wijaya', '3201234567890005', '081234567894', 'rina@email.com', 'lingkungan', 'Sampah Menumpuk', 'Sampah tidak diangkut 3 hari', 'RT 03 RW 02', 'ditinjau', 'sedang');

-- Sample berita
INSERT INTO berita (judul, slug, konten, excerpt, kategori, penulis, status, tanggal_publikasi)
VALUES 
  ('Pembangunan Balai Desa Dimulai', 'pembangunan-balai-desa-dimulai', 'Pembangunan balai desa yang baru telah dimulai pada hari Senin kemarin...', 'Pembangunan balai desa yang baru telah dimulai', 'Pembangunan', 'Admin Desa', 'published', NOW()),
  ('Gotong Royong Bersih Desa', 'gotong-royong-bersih-desa', 'Kegiatan gotong royong bersih desa akan dilaksanakan pada hari Minggu...', 'Kegiatan gotong royong bersih desa', 'Kegiatan', 'Admin Desa', 'published', NOW());
```

## Langkah 10: Verifikasi

1. Di Supabase Dashboard, klik **Table Editor**
2. Pilih setiap table dan pastikan:
   - Table sudah dibuat
   - Sample data sudah ada (jika Anda insert)
3. Klik **Authentication** → **Users** dan pastikan admin user sudah ada

## ✅ Setup Selesai!

Sekarang Anda bisa:
- Restart development server: `npm run dev`
- Login menggunakan email dan password admin yang sudah dibuat
- Semua data akan tersimpan di Supabase

## Troubleshooting

### Error: "Invalid API key"
- Pastikan `.env` file sudah dibuat
- Pastikan API keys sudah benar (copy dari Supabase Dashboard)
- Restart dev server setelah membuat `.env`

### Error: "relation does not exist"
- Pastikan SQL script sudah di-run di SQL Editor
- Check di Table Editor apakah table sudah ada

### Error: "new row violates row-level security policy"
- Pastikan RLS policies sudah di-setup
- Check apakah user sudah authenticated

### Tidak bisa login
- Pastikan user sudah dibuat di Authentication
- Pastikan "Auto Confirm User" sudah dicentang
- Pastikan email dan password benar

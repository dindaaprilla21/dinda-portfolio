# 📝 Panduan Format Pesan Chatbot

## ✨ Format yang Didukung

Chatbot Desa Legok sekarang mendukung berbagai format text untuk membuat pesan lebih rapi dan mudah dibaca.

---

## 1. **Line Breaks (Baris Baru)**

### Di n8n, gunakan `\n` untuk membuat baris baru:

```javascript
{
  "message": "Baris pertama\nBaris kedua\nBaris ketiga"
}
```

### Hasil di chatbot:
```
Baris pertama
Baris kedua
Baris ketiga
```

---

## 2. **Numbered Lists (Daftar Bernomor)**

### Format: `1. Item pertama`

```javascript
{
  "message": "Berikut adalah persyaratan:\n1. Fotokopi KTP\n2. Fotokopi KK\n3. Surat Pengantar RT/RW"
}
```

### Hasil di chatbot:
```
Berikut adalah persyaratan:
1. Fotokopi KTP
2. Fotokopi KK
3. Surat Pengantar RT/RW
```

---

## 3. **Bullet Points (Poin-Poin)**

### Format: `- Item` atau `• Item`

```javascript
{
  "message": "Layanan yang tersedia:\n- Pengajuan Surat\n- Laporan Pengaduan\n- Informasi Umum"
}
```

### Hasil di chatbot:
```
Layanan yang tersedia:
• Pengajuan Surat
• Laporan Pengaduan
• Informasi Umum
```

---

## 4. **Bold Text (Teks Tebal)**

### Format: `**teks tebal**`

```javascript
{
  "message": "**Penting:** Harap membawa dokumen asli saat pengambilan."
}
```

### Hasil di chatbot:
```
**Penting:** Harap membawa dokumen asli saat pengambilan.
```

---

## 📋 Contoh Lengkap

### n8n Response:

```json
{
  "message": "Tentu, Bapak/Ibu. Desa Legok siap membantu Anda dalam pengurusan Akta Kelahiran.\n\n**Berikut adalah persyaratan yang perlu disiapkan:**\n\n1. Surat Keterangan Lahir dari Bidan, Rumah Sakit, atau Penolong Kelahiran.\n2. Fotokopi Kartu Keluarga (KK) orang tua.\n3. Fotokopi KTP Ayah dan Ibu.\n4. Fotokopi Akta Nikah atau Buku Nikah orang tua (jika ada).\n5. Fotokopi KTP dua orang saksi.\n\n**Untuk alur pengajuan melalui website kami:**\n\n1. Pilih layanan \"Akta Kelahiran\" di halaman utama website desa.\n2. Isi formulir online dengan data yang benar dan lengkap.\n3. Siapkan berkas pendukung yang telah disebutkan di atas.\n4. Setelah pengajuan online, petugas desa akan melakukan verifikasi data dan berkas Anda.\n5. Proses penerbitan Akta Kelahiran membutuhkan waktu sekitar 3 sampai 5 hari kerja.\n\nSemoga informasi ini membantu.",
  "status": "success"
}
```

### Hasil di Chatbot:

```
Tentu, Bapak/Ibu. Desa Legok siap membantu Anda dalam pengurusan Akta Kelahiran.

**Berikut adalah persyaratan yang perlu disiapkan:**

1. Surat Keterangan Lahir dari Bidan, Rumah Sakit, atau Penolong Kelahiran.
2. Fotokopi Kartu Keluarga (KK) orang tua.
3. Fotokopi KTP Ayah dan Ibu.
4. Fotokopi Akta Nikah atau Buku Nikah orang tua (jika ada).
5. Fotokopi KTP dua orang saksi.

**Untuk alur pengajuan melalui website kami:**

1. Pilih layanan "Akta Kelahiran" di halaman utama website desa.
2. Isi formulir online dengan data yang benar dan lengkap.
3. Siapkan berkas pendukung yang telah disebutkan di atas.
4. Setelah pengajuan online, petugas desa akan melakukan verifikasi data dan berkas Anda.
5. Proses penerbitan Akta Kelahiran membutuhkan waktu sekitar 3 sampai 5 hari kerja.

Semoga informasi ini membantu.
```

---

## 🎨 Tips Formatting

### 1. **Gunakan Spacing yang Baik**

```javascript
// ✅ GOOD - Ada spacing antar section
"message": "Judul\n\nParagraf pertama.\n\nParagraf kedua."

// ❌ BAD - Terlalu rapat
"message": "Judul\nParagraf pertama.\nParagraf kedua."
```

### 2. **Kombinasi Format**

```javascript
{
  "message": "**Persyaratan:**\n\n1. **Dokumen Utama:**\n- KTP\n- KK\n\n2. **Dokumen Pendukung:**\n- Surat Pengantar\n- Pas Foto"
}
```

### 3. **Hindari Format yang Terlalu Kompleks**

```javascript
// ✅ GOOD - Simple dan jelas
"message": "**Penting:**\n\n1. Bawa dokumen asli\n2. Datang tepat waktu"

// ❌ BAD - Terlalu banyak nested formatting
"message": "**Penting:** **1.** **Bawa** **dokumen** **asli**"
```

---

## 🔧 Implementasi di n8n

### Function Node Example:

```javascript
// Format message dengan proper line breaks dan formatting
const userName = $input.item.json.nama;
const topic = $input.item.json.message;

let response = "";

if (topic.includes("Akta Kelahiran")) {
  response = `Tentu, ${userName}. Desa Legok siap membantu Anda.\n\n` +
             `**Berikut adalah persyaratan yang perlu disiapkan:**\n\n` +
             `1. Surat Keterangan Lahir dari Bidan atau Rumah Sakit.\n` +
             `2. Fotokopi Kartu Keluarga (KK) orang tua.\n` +
             `3. Fotokopi KTP Ayah dan Ibu.\n` +
             `4. Fotokopi Akta Nikah orang tua.\n` +
             `5. Fotokopi KTP dua orang saksi.\n\n` +
             `**Proses:**\n\n` +
             `1. Pilih layanan di website\n` +
             `2. Isi formulir online\n` +
             `3. Upload berkas pendukung\n` +
             `4. Tunggu verifikasi (3-5 hari kerja)\n\n` +
             `Semoga membantu!`;
}

return {
  json: {
    message: response,
    status: "success"
  }
};
```

---

## ⚠️ Catatan Penting

1. **Escape Characters:** Di n8n, gunakan `\n` untuk line break, bukan `\\n`
2. **Double Asterisk:** Untuk bold, gunakan `**text**` (dua asterisk di awal dan akhir)
3. **Numbered Lists:** Harus dimulai dengan angka diikuti titik dan spasi: `1. `
4. **Bullet Points:** Gunakan `-` atau `•` diikuti spasi

---

## 🧪 Testing

### Test di Browser Console:

```javascript
// Test format message
const testMessage = "**Judul**\n\n1. Item satu\n2. Item dua\n\n- Bullet satu\n- Bullet dua";
console.log(testMessage);
```

### Expected Output di Chatbot:
- **Judul** akan bold
- 1. dan 2. akan jadi numbered list
- Bullet points akan muncul dengan •

---

## 📚 Resources

- [Markdown Basic Syntax](https://www.markdownguide.org/basic-syntax/)
- [n8n Function Node Docs](https://docs.n8n.io/code-examples/expressions/)

---

**Last Updated:** 5 Desember 2025  
**Version:** 2.1.0 (with message formatting)

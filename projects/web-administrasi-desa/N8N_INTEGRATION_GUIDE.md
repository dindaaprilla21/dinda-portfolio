# Panduan Integrasi n8n Workflow dengan Chatbot

## 📋 Overview

Chatbot Desa Legok sekarang sudah terintegrasi dengan n8n workflow melalui webhook. User dapat mengirim pesan dan menerima response otomatis dari n8n.

---

## 🔧 Konfigurasi n8n Webhook

### 1. **Setup Webhook di n8n**

#### Langkah-langkah:

1. **Buka n8n** dan buat workflow baru
2. **Tambahkan node "Webhook"**
   - Pilih method: `POST`
   - Path: `/chatbot-desa-legok` (atau sesuai keinginan)
   - Response Mode: `Respond to Webhook`

3. **Konfigurasi Response**
   - Tambahkan node untuk memproses data
   - Return response dengan format JSON:
   ```json
   {
     "message": "Pesan balasan dari bot",
     "status": "success"
   }
   ```

4. **Copy Webhook URL**
   - Klik "Test URL" atau "Production URL"
   - Copy URL lengkap (contoh: `https://your-n8n-instance.com/webhook/chatbot-desa-legok`)

---

### 2. **Update Webhook URL di Code**

Buka file: `src/components/sidebar/FloatingChatBubble.jsx`

Cari baris ini (sekitar line 24):
```javascript
const N8N_WEBHOOK_URL = 'YOUR_N8N_WEBHOOK_URL_HERE';
```

Ganti dengan URL webhook n8n Anda:
```javascript
const N8N_WEBHOOK_URL = 'https://your-n8n-instance.com/webhook/chatbot-desa-legok';
```

---

## 📤 Format Data yang Dikirim ke n8n

Setiap kali user mengirim pesan, data berikut akan dikirim ke n8n webhook:

```json
{
  "nama": "Nama User",
  "nomorWA": "081234567890",
  "message": "Pesan dari user",
  "timestamp": "2025-12-05T11:18:53.000Z"
}
```

### Field Explanation:
- **nama**: Nama lengkap user (dari form registrasi)
- **nomorWA**: Nomor WhatsApp user (dari form registrasi)
- **message**: Isi pesan yang dikirim user
- **timestamp**: Waktu pengiriman pesan (ISO 8601 format)

---

## 📥 Format Response dari n8n

n8n harus mengembalikan response dalam format JSON:

### Response Sukses:
```json
{
  "message": "Terima kasih atas pertanyaan Anda. Admin akan segera merespons.",
  "status": "success"
}
```

### Response dengan Data Tambahan (opsional):
```json
{
  "message": "Untuk pengajuan surat, silakan kunjungi halaman layanan kami.",
  "status": "success",
  "data": {
    "link": "/layanan",
    "estimasi": "3-5 hari kerja"
  }
}
```

**Note:** Chatbot akan menggunakan field `message` atau `reply` dari response untuk ditampilkan ke user.

---

## 🎯 Contoh Workflow n8n Sederhana

### Workflow 1: Auto-Reply Berdasarkan Keyword

```
1. Webhook (Trigger)
   ↓
2. IF Node (Check keyword)
   - Jika message contains "surat" → Response A
   - Jika message contains "pengaduan" → Response B
   - Else → Response Default
   ↓
3. Respond to Webhook
   - Return JSON response
```

### Workflow 2: Simpan ke Database + Notifikasi Admin

```
1. Webhook (Trigger)
   ↓
2. Set Node (Format data)
   ↓
3. MySQL/PostgreSQL (Save to database)
   ↓
4. Send Email/Telegram (Notify admin)
   ↓
5. Respond to Webhook
   - Return confirmation message
```

### Workflow 3: AI Chatbot dengan OpenAI

```
1. Webhook (Trigger)
   ↓
2. OpenAI Node
   - Model: gpt-3.5-turbo
   - Prompt: User message + context
   ↓
3. Respond to Webhook
   - Return AI response
```

---

## 🔍 Testing

### 1. **Test di Browser**

1. Buka website: `http://localhost:5173`
2. Click floating chat bubble
3. Isi form registrasi (nama + nomor WA)
4. Kirim pesan test
5. Lihat response dari n8n

### 2. **Test n8n Webhook Langsung**

Gunakan curl atau Postman:

```bash
curl -X POST https://your-n8n-instance.com/webhook/chatbot-desa-legok \
  -H "Content-Type: application/json" \
  -d '{
    "nama": "Test User",
    "nomorWA": "081234567890",
    "message": "Halo, saya ingin bertanya tentang pengajuan surat",
    "timestamp": "2025-12-05T11:18:53.000Z"
  }'
```

Expected response:
```json
{
  "message": "Terima kasih atas pertanyaan Anda...",
  "status": "success"
}
```

---

## ⚙️ Fitur Chatbot

### ✅ Yang Sudah Ada:

1. **Form Registrasi**
   - Input nama lengkap
   - Input nomor WhatsApp
   - Validasi form

2. **Chat Interface**
   - Message bubbles (user & bot)
   - Timestamp pada setiap pesan
   - Auto-scroll ke pesan terbaru
   - Typing indicator saat menunggu response

3. **Quick Replies**
   - 📄 Pengajuan Surat
   - 📢 Laporan Pengaduan
   - ℹ️ Informasi Umum

4. **n8n Integration**
   - Send message via webhook
   - Receive response dari n8n
   - Error handling
   - Loading state

5. **Data Persistence**
   - User data disimpan di localStorage
   - Chat history dalam session

---

## 🎨 UI/UX Features

- **Responsive design** - Works on mobile & desktop
- **Smooth animations** - Fade in/out, typing indicator
- **Green theme** - Consistent dengan branding Desa Legok
- **User-friendly** - Clear labels dan error messages
- **Real-time** - Instant message sending & receiving

---

## 🔐 Security Considerations

### Untuk Production:

1. **CORS Configuration**
   - Pastikan n8n webhook mengizinkan request dari domain website Anda
   - Set proper CORS headers

2. **Rate Limiting**
   - Implementasi rate limiting di n8n untuk mencegah spam
   - Limit: misalnya 10 pesan per menit per user

3. **Input Validation**
   - n8n harus validate semua input
   - Sanitize data sebelum disimpan ke database

4. **HTTPS Only**
   - Gunakan HTTPS untuk webhook URL
   - Jangan gunakan HTTP di production

5. **Authentication (Optional)**
   - Tambahkan API key atau token untuk extra security
   - Validate token di n8n workflow

---

## 🐛 Troubleshooting

### Problem 1: "Network response was not ok"
**Solusi:**
- Check apakah n8n webhook URL sudah benar
- Pastikan n8n workflow sudah active
- Check CORS settings di n8n

### Problem 2: Response tidak muncul
**Solusi:**
- Check format response dari n8n (harus JSON)
- Pastikan ada field `message` atau `reply`
- Check console browser untuk error

### Problem 3: Pesan tidak terkirim
**Solusi:**
- Check internet connection
- Verify webhook URL accessible
- Check n8n workflow logs

---

## 📊 Monitoring & Analytics

### Data yang Bisa Ditrack:

1. **User Metrics**
   - Jumlah user yang register
   - Jumlah pesan per user
   - Topik yang paling banyak ditanya

2. **System Metrics**
   - Response time dari n8n
   - Success rate
   - Error rate

3. **Business Metrics**
   - Conversion rate (chat → pengajuan surat)
   - Customer satisfaction
   - Peak hours

### Implementasi di n8n:

Tambahkan node untuk logging:
```
Webhook → Save to Database → Analytics Dashboard
```

---

## 🚀 Next Steps (Optional Enhancements)

### Short Term:
1. **File Upload** - Allow user upload dokumen
2. **Rich Messages** - Support images, links, buttons
3. **Chat History** - Persist chat across sessions

### Medium Term:
1. **Multi-language** - Support Bahasa & English
2. **Voice Messages** - Record & send audio
3. **Sentiment Analysis** - Detect user mood

### Long Term:
1. **AI Integration** - OpenAI, Dialogflow
2. **Live Chat** - Connect to real admin
3. **Mobile App** - React Native version

---

## 📞 Support

Jika ada pertanyaan atau masalah:
1. Check n8n workflow logs
2. Check browser console
3. Review dokumentasi n8n: https://docs.n8n.io

---

**Last Updated:** 5 Desember 2025  
**Version:** 1.0.0

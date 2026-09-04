# 🔧 Solusi CORS Error - n8n Webhook

## ❌ Error yang Terjadi

```
Access to fetch at 'https://n8n.kitapunya.web.id/webhook/...' from origin 'http://localhost:5173' 
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present
```

---

## ✅ Solusi 1: Konfigurasi CORS di n8n Workflow (RECOMMENDED)

### Langkah-langkah:

1. **Buka n8n workflow** Anda
2. **Klik Webhook node** yang sudah dibuat
3. **Scroll ke bawah** ke bagian "Options"
4. **Tambahkan Response Headers**

#### Setting yang Perlu Ditambahkan:

**Di Webhook Node → Options → Response Headers:**

```json
{
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type"
}
```

**Atau untuk lebih spesifik (lebih aman):**

```json
{
  "Access-Control-Allow-Origin": "http://localhost:5173",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type"
}
```

5. **Save** workflow
6. **Test** ulang dari browser

---

## ✅ Solusi 2: Tambahkan HTTP Response Node

Jika Webhook node tidak punya option untuk headers, gunakan cara ini:

### Workflow Structure:

```
Webhook (Trigger)
    ↓
[Your Processing Nodes]
    ↓
HTTP Response Node (dengan CORS headers)
```

### Konfigurasi HTTP Response Node:

**Response Code:** 200

**Response Headers:**
```json
{
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
  "Content-Type": "application/json"
}
```

**Response Body:**
```json
{
  "message": "{{ $json.yourMessage }}",
  "status": "success"
}
```

---

## ✅ Solusi 3: Gunakan n8n dengan Mode "Respond to Webhook"

### Langkah-langkah:

1. **Di Webhook Node:**
   - Response Mode: `Respond to Webhook`
   - Response Code: `200`
   - Response Data: `First Entry JSON`

2. **Tambahkan Set Node** sebelum response:

**Set Node Configuration:**
```javascript
// Add these fields:
{
  "message": "Terima kasih atas pesan Anda",
  "status": "success",
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type"
  }
}
```

---

## ✅ Solusi 4: Proxy Server (Development Only)

Jika Anda tidak bisa mengubah konfigurasi n8n, gunakan proxy di development.

### Buat file: `vite.config.js`

Update konfigurasi Vite:

```javascript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api/n8n': {
        target: 'https://n8n.kitapunya.web.id',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api\/n8n/, '')
      }
    }
  }
})
```

### Update FloatingChatBubble.jsx:

```javascript
// Ganti URL dari:
const N8N_WEBHOOK_URL = 'https://n8n.kitapunya.web.id/webhook/62f54e83-6fe6-4907-bc37-420ce307dbd5/chat';

// Menjadi:
const N8N_WEBHOOK_URL = '/api/n8n/webhook/62f54e83-6fe6-4907-bc37-420ce307dbd5/chat';
```

**Note:** Solusi ini hanya untuk development. Di production tetap perlu CORS di n8n.

---

## ✅ Solusi 5: n8n Self-Hosted Configuration

Jika Anda menggunakan n8n self-hosted, tambahkan environment variable:

### Di `.env` file n8n:

```bash
N8N_CORS_ORIGIN=*
# Atau lebih spesifik:
N8N_CORS_ORIGIN=http://localhost:5173,https://your-production-domain.com
```

### Restart n8n:

```bash
docker-compose restart n8n
# atau
pm2 restart n8n
```

---

## 🧪 Testing CORS Configuration

### Test dengan curl:

```bash
curl -X OPTIONS https://n8n.kitapunya.web.id/webhook/62f54e83-6fe6-4907-bc37-420ce307dbd5/chat \
  -H "Origin: http://localhost:5173" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v
```

**Expected Response Headers:**
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

---

## 📝 Contoh n8n Workflow Lengkap dengan CORS

### Workflow Structure:

```
1. Webhook (Trigger)
   - HTTP Method: POST
   - Path: /chat
   - Response Mode: Respond to Webhook

2. Function Node (Process Message)
   - Code:
     const userMessage = $input.item.json.message;
     const userName = $input.item.json.nama;
     
     return {
       json: {
         message: `Halo ${userName}! Terima kasih atas pesan: "${userMessage}"`,
         status: "success",
         timestamp: new Date().toISOString()
       }
     };

3. Set Node (Add CORS Headers)
   - Keep Only Set: false
   - Add these fields:
     {
       "headers": {
         "Access-Control-Allow-Origin": "*",
         "Access-Control-Allow-Methods": "POST, OPTIONS",
         "Access-Control-Allow-Headers": "Content-Type"
       }
     }

4. Respond to Webhook
   - Response Code: 200
   - Response Body: {{ $json }}
```

---

## 🎯 Quick Fix (Paling Mudah)

**Untuk testing cepat, gunakan Solusi 1:**

1. Buka n8n workflow
2. Klik Webhook node
3. Scroll ke "Options"
4. Tambahkan di "Response Headers":
   ```
   Access-Control-Allow-Origin: *
   ```
5. Save & Test

---

## 🔒 Production Recommendations

### Untuk Production, gunakan CORS yang lebih ketat:

```json
{
  "Access-Control-Allow-Origin": "https://desa-legok.com",
  "Access-Control-Allow-Methods": "POST",
  "Access-Control-Allow-Headers": "Content-Type",
  "Access-Control-Max-Age": "86400"
}
```

**Jangan gunakan `*` di production!**

---

## 📞 Troubleshooting

### Masalah: CORS masih error setelah konfigurasi

**Cek:**
1. ✅ Workflow sudah di-save?
2. ✅ Webhook sudah active?
3. ✅ Browser cache sudah di-clear?
4. ✅ Headers sudah benar formatnya?

### Masalah: Preflight request gagal

**Solusi:**
- Pastikan n8n support OPTIONS method
- Tambahkan OPTIONS di Allow-Methods
- Check n8n logs untuk error

---

## 🚀 Next Steps

1. **Pilih solusi** yang paling sesuai (recommend: Solusi 1)
2. **Implementasi** di n8n workflow
3. **Test** dari browser
4. **Verify** response headers di Network tab
5. **Deploy** ke production dengan CORS yang ketat

---

**Status:** Menunggu konfigurasi CORS di n8n  
**Webhook URL:** `https://n8n.kitapunya.web.id/webhook/62f54e83-6fe6-4907-bc37-420ce307dbd5/chat`  
**Origin:** `http://localhost:5173`

# 🔍 Debugging n8n Response - Panduan Troubleshooting

## ❓ Masalah: Jawaban Chatbot Berbeda dengan n8n

Jika jawaban yang muncul di chatbot berbeda dengan yang ada di n8n workflow, ikuti langkah debugging berikut:

---

## 🛠️ Langkah 1: Check Console Browser

### Buka Developer Tools:
1. **Chrome/Edge:** Tekan `F12` atau `Ctrl+Shift+I`
2. **Firefox:** Tekan `F12`
3. Klik tab **Console**

### Kirim Pesan di Chatbot

Setelah mengirim pesan, lihat di console. Akan muncul log seperti ini:

```javascript
Response dari n8n: {
  message: "Ini adalah jawaban dari n8n",
  status: "success",
  // ... field lainnya
}
response.message: "Ini adalah jawaban dari n8n"
response.reply: undefined
```

---

## 📊 Kemungkinan Format Response dari n8n

### Format 1: Standard (RECOMMENDED)
```json
{
  "message": "Jawaban dari bot",
  "status": "success"
}
```
✅ **Chatbot akan menggunakan:** `response.message`

### Format 2: Alternative Field
```json
{
  "reply": "Jawaban dari bot",
  "status": "success"
}
```
✅ **Chatbot akan menggunakan:** `response.reply`

### Format 3: Output Field
```json
{
  "output": "Jawaban dari bot",
  "status": "success"
}
```
✅ **Chatbot akan menggunakan:** `response.output`

### Format 4: Nested Object
```json
{
  "data": {
    "message": "Jawaban dari bot"
  },
  "status": "success"
}
```
❌ **Chatbot TIDAK akan bisa mengambil** karena nested

### Format 5: Array Response
```json
[
  {
    "message": "Jawaban dari bot"
  }
]
```
❌ **Chatbot TIDAK akan bisa mengambil** karena array

---

## 🔧 Solusi Berdasarkan Format Response

### Jika Response Nested (Format 4):

**Update di n8n workflow:**

Tambahkan **Set Node** sebelum response untuk flatten data:

```javascript
// Set Node - Fields to Set
{
  "message": "{{ $json.data.message }}",
  "status": "success"
}
```

### Jika Response Array (Format 5):

**Update di n8n workflow:**

Tambahkan **Set Node** untuk ambil item pertama:

```javascript
// Set Node - Fields to Set
{
  "message": "{{ $json[0].message }}",
  "status": "success"
}
```

### Jika Response Punya Field Custom:

**Contoh:** n8n return `{ "bot_reply": "Jawaban" }`

**Update FloatingChatBubble.jsx:**

```javascript
// Line 145 & 188
text: response.message || response.reply || response.output || response.bot_reply || 'Default message'
```

---

## 🎯 Cara Melihat Exact Response dari n8n

### Method 1: Browser Console (Sudah Aktif)

Setelah kirim pesan, lihat console:
```
Response dari n8n: { ... }
```

Copy object tersebut dan paste ke JSON formatter online untuk lihat struktur lengkap.

### Method 2: n8n Execution Log

1. Buka n8n workflow
2. Klik **Executions** (tab di kanan)
3. Klik execution terakhir
4. Lihat **Output Data** dari Webhook Response node
5. Check format JSON yang di-return

### Method 3: Network Tab Browser

1. Buka Developer Tools → **Network** tab
2. Kirim pesan di chatbot
3. Cari request ke n8n webhook
4. Klik request tersebut
5. Lihat tab **Response** untuk melihat exact response

---

## 📝 Contoh n8n Workflow yang Benar

### Workflow Structure:

```
1. Webhook (Trigger)
   ↓
2. Function/Code Node (Process)
   ↓
3. Set Node (Format Response) ← PENTING!
   ↓
4. Respond to Webhook
```

### Set Node Configuration:

**Keep Only Set:** `false`

**Fields to Set:**
```json
{
  "message": "{{ $json.yourProcessedMessage }}",
  "status": "success",
  "timestamp": "{{ $now.toISO() }}"
}
```

**Example dengan AI:**
```json
{
  "message": "{{ $json.choices[0].message.content }}",
  "status": "success"
}
```

---

## 🐛 Common Issues & Solutions

### Issue 1: Response Undefined

**Symptom:** Console shows `response.message: undefined`

**Cause:** n8n tidak return field `message`

**Solution:**
1. Check n8n execution log
2. Lihat field apa yang di-return
3. Update code atau n8n workflow

### Issue 2: Response adalah String, Bukan Object

**Symptom:** Console shows `Response dari n8n: "Jawaban"`

**Cause:** n8n return plain string

**Solution di n8n:**
```javascript
// Wrap string dalam object
return {
  json: {
    message: "Your response here",
    status: "success"
  }
};
```

### Issue 3: CORS Error Muncul Lagi

**Symptom:** `Access-Control-Allow-Origin` error

**Solution:**
1. Pastikan CORS headers sudah di-set di n8n
2. Atau gunakan Vite proxy (lihat CORS_FIX_GUIDE.md)

### Issue 4: Response Terlalu Lama

**Symptom:** Typing indicator terus muncul

**Cause:** n8n workflow timeout atau lambat

**Solution:**
1. Optimize n8n workflow
2. Tambah timeout handling di code
3. Check n8n logs untuk error

---

## 🔍 Debug Checklist

Gunakan checklist ini untuk troubleshooting:

- [ ] Buka browser console
- [ ] Kirim pesan test
- [ ] Lihat log "Response dari n8n"
- [ ] Check apakah ada field `message`, `reply`, atau `output`
- [ ] Jika tidak ada, lihat field apa yang tersedia
- [ ] Check n8n execution log
- [ ] Verify response format di n8n
- [ ] Update code atau n8n sesuai kebutuhan

---

## 💡 Best Practices

### 1. Konsisten Format Response

Selalu return format yang sama dari n8n:

```json
{
  "message": "Bot response here",
  "status": "success",
  "timestamp": "2025-12-05T11:34:59Z"
}
```

### 2. Error Handling di n8n

Tambahkan error node:

```json
{
  "message": "Maaf, terjadi kesalahan. Silakan coba lagi.",
  "status": "error",
  "error_code": "500"
}
```

### 3. Logging di n8n

Tambahkan log untuk debugging:
- Log input message
- Log processing steps
- Log final response

---

## 📞 Quick Fix

Jika masih bingung, coba ini:

### Di n8n Workflow:

Tambahkan **Set Node** sebelum response dengan config:

```json
{
  "message": "Test response dari n8n",
  "status": "success"
}
```

Hardcode dulu untuk testing. Jika ini berhasil, berarti masalah di processing logic n8n.

---

## 🎓 Understanding the Code

### Bagaimana Chatbot Mengambil Response:

```javascript
// Priority order:
text: response.message       // Check ini dulu
   || response.reply         // Kalau tidak ada, check ini
   || response.output        // Kalau tidak ada, check ini
   || JSON.stringify(response) // Kalau tidak ada, show semua
   || 'Default message'      // Last resort
```

### Console Logs yang Ditambahkan:

```javascript
console.log('Response dari n8n:', response);
console.log('response.message:', response.message);
console.log('response.reply:', response.reply);
```

Ini membantu Anda lihat:
1. Full response object
2. Apakah field `message` ada
3. Apakah field `reply` ada

---

## 📚 Resources

- [n8n Documentation](https://docs.n8n.io)
- [Webhook Node Docs](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/)
- [Set Node Docs](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.set/)

---

**Last Updated:** 5 Desember 2025  
**Status:** Debugging enabled in code

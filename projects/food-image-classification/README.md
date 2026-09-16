# 🍛 Indian & Korean Food Classification with EfficientNetB3

Sistem klasifikasi citra makanan tradisional India dan Korea berbasis **Deep Learning** dan **Computer Vision** menggunakan arsitektur **Transfer Learning EfficientNetB3** dan framework **TensorFlow / Keras**.

Dikembangkan oleh **Dinda Aprilla Dalimunthe** sebagai proyek akademik mata kuliah Jaringan Syaraf Tiruan (JST) Semester 7.

---

## 🎯 Capaian Akurasi Model

| Dataset Makanan | Arsitektur Model | Akurasi Evaluasi | Status / Hasil |
|:---|:---|:---:|:---|
| 🇮🇳 **Indian Food Dataset** | EfficientNetB3 + Fine Tuning | **92.23%** | Konvergensi stabil, generalisasi citra kuat |
| 🇰🇷 **Korean Food Dataset** | EfficientNetB3 + Fine Tuning | **98.70%** | Sangat akurat pada seluruh kelas makanan |

---

## 📂 Struktur Direktori Proyek

```text
food-image-classification/
├── index.html                      # Web Showcase & Simulasi Interaktif Klasifikasi Makanan
├── style.css                       # Styling UI Neon Dark Mode
├── app.js                          # Logika interaktif simulasi & galeri metrik
├── README.md                       # Dokumentasi lengkap proyek
├── Paper JST.docx                  # Naskah ilmiah laporan proyek JST
├── JURNAL/
│   ├── Paper Kelompok 4 JST.pdf    # Publikasi / Paper resmi proyek
│   ├── percobaan colab india.pdf   # Log pelatihan & notebook Google Colab (India)
│   └── *.pdf                       # Referensi ilmiah & literatur internasional
├── hasil evaluasi indian food/
│   ├── confussion matrixs.png      # Confusion matrix model makanan India
│   ├── TREINING ACCURACY.png       # Grafik training & validation accuracy
│   ├── TRAINING LOSS ACCURACY.png  # Grafik training & validation loss
│   └── contoh prediksi *.png       # Sampel visualisasi prediksi citra
├── hasil evaluasi korean food/
│   ├── confussion matrixs.png      # Confusion matrix model makanan Korea
│   ├── precision,recall grafik.png # Kurva presisi & recall per kelas
│   ├── train dan val akurasi.png   # Grafik akurasi per epoch
│   └── contoh prediksi *.png       # Sampel visualisasi prediksi citra
├── dataset_project/                # Dataset citra makanan India (train, val, test)
└── kfood_dataset/                  # Dataset citra makanan Korea (train, val, test)
```

---

## 🔬 Metodologi & Alur Kerja

1. **Pengumpulan & Pra-pemrosesan Data**:
   - Resizing citra ke resolusi input EfficientNet (300x300 piksel).
   - Normalisasi nilai piksel dan augmentasi data (*random rotation, zoom, horizontal flip, shear, brightness adjustment*).
2. **Transfer Learning Architecture**:
   - Backbone: **Pretrained EfficientNetB3** (ImageNet weights) dengan feature extractor dibekukan pada tahap awal.
   - Dense Head: Global Average Pooling 2D, Batch Normalization, Dropout (0.3 - 0.5), dan Dense Layer dengan aktivasi Softmax.
3. **Training & Fine-Tuning**:
   - Optimizer: Adam dengan Learning Rate scheduling (ReduceLROnPlateau) & Early Stopping.
   - Fine-tuning pada lapisan atas (*top layers*) untuk adaptasi fitur spesifik tekstur makanan.
4. **Evaluasi**:
   - Analisis mendalam dengan Confusion Matrix, Precision, Recall, F1-Score, dan Macro/Micro Average.

---

## 🚀 Cara Menjalankan

### 1. Menjalankan Web Demo Interaktif
Buka file `index.html` langsung di browser Anda atau melalui live server lokal:
```bash
# Menggunakan live server apapun (misal Python atau Node)
npx serve .
```

### 2. Membaca Paper & Laporan Ilmiah
- Dokumen naskah lengkap: `Paper JST.docx` atau `JURNAL/Paper Kelompok 4 JST.pdf`.

import React, { useState } from "react";
import { createSurat } from "../../services/suratService";
import { supabase } from "../../config/supabaseClient";

/* ----------------------------------------------
    DATA PERSYARATAN SURAT
---------------------------------------------- */
const PERSYARATAN_AKTA_LAHIR = [
  "Formulir F2.01",
  "Surat Kelahiran asli dari Bidan atau Dokter / Desa",
  "Kartu Keluarga (KK) terbaru",
  "Surat Nikah atau Akta Perkawinan Orang Tua",
  "KTP-eL Pelapor",
  "KTP-eL saksi",
  "Surat Pernyataan anak seorang ibu (jika di luar nikah)",
  "Surat Kehilangan Dari Kepolisian (jika Akta Kelahiran hilang)",
  "Kutipan Kedua (jika Akta Kelahiran rusak)"
];

const PERSYARATAN_AKTA_MATI = [
  "Formulir F2.31",
  "Kartu Keluarga",
  "KTP-eL Jenazah",
  "KTP-eL Pelapor",
  "KTP-eL Saksi",
  "Surat Kematian dari Dokter Rumah sakit atau Desa / Kelurahan"
];

const PERSYARATAN_KIA = [
  "Kartu Keluarga (KK) terbaru",
  "Akta Kelahiran Anak",
  "KTP Orang Tua",
  "Pas Foto 2x3 (latar Merah/Biru, khusus anak > 5 tahun)"
];

const PERSYARATAN_KTP = [
  "Kartu Keluarga asli",
  "Surat Keterangan pengganti KTP-el",
  "Surat Kehilangan Kepolisian (Jika KTP-el hilang)",
  "KTP-el lama jika rusak atau perubahan data",
  "Catatan Khusus: Bagi penduduk yang belum perekaman KTP-el, lakukan di Kecamatan."
];

const PERSYARATAN_SKTM = [
  "Kartu Keluarga Asli",
  "KTP-el Asli",
  "Pengantar RT/RW Setempat"
];

const PERSYARATAN_PINDAH_DATANG = [
  "F1.01",
  "Surat Keterangan Pindah WNI dari Asal",
  "Kartu Keluarga yang akan ditumpangi",
  "Surat Nikah / Akta Cerai",
  "KTP-eL Asli"
];

const PERSYARATAN_PINDAH_KELUAR = [
  "Kartu Keluarga Asli",
  "KTP-el Asli",
  "Surat Nikah / Akta Cerai",
  "Surat Pernyataan lainnya",
  "Izin Suami / Istri bila pindah salah satu",
  "Surat Pernyataan Pindah Anak di bawah umur"
];

const PERSYARATAN_USAHA = [
  "Surat Pengantar RT/RW",
  "Kartu Keluarga (KK)",
  "KTP-eL Pemohon",
  "Foto lokasi usaha (jika ada)"
];

const PERSYARATAN_DOMISILI = [
  "Surat Pengantar RT/RW",
  "Kartu Keluarga (KK)",
  "KTP-eL Pemohon",
  "Bukti PBB / Surat Sewa Rumah"
];

const PERSYARATAN_KK_SUB = {
  Baru: ["Formulir F1.01", "Surat Pengantar RT/RW", "Akta Nikah/Cerai", "Akta Kelahiran"],
  Pindah: ["Formulir F1.06 (Pindah Datang)", "Surat Keterangan Pindah (SKPWNI)"],
  Hilang: ["Surat Kehilangan Polisi", "KTP-el salah satu anggota KK"]
};

const UPLOAD_SURAT_LIST = [
  "aktelahir", "aktemati", "kia", "kk",
  "ktp", "sktm", "datang", "keluar",
  "usaha", "domisili"
];

/* ----------------------------------------------
    KOMPONEN FORM SURAT
---------------------------------------------- */
export default function FormSurat({ jenis, onBack }) {
  const [files, setFiles] = useState({});
  const [kkType, setKkType] = useState("Baru");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [uploadProgress, setUploadProgress] = useState("");
  const [additionalFields, setAdditionalFields] = useState({
    nama: "",
    nomorTelepon: "",
    namaUsaha: "",
    alamatTujuan: ""
  });

  const titleMap = {
    aktelahir: "Akta Kelahiran",
    aktemati: "Akta Kematian",
    kia: "Kartu Identitas Anak",
    ktp: "Kartu Tanda Penduduk",
    kk: "Kartu Keluarga",
    usaha: "Surat Keterangan Usaha",
    domisili: "Surat Keterangan Domisili",
    sktm: "Surat Keterangan Tidak Mampu",
    datang: "Surat Pengantar Pindah Datang",
    keluar: "Surat Pengantar Pindah Keluar"
  };

  const iconMap = {
    aktelahir: "fa-baby",
    aktemati: "fa-skull-crossbones",
    kia: "fa-id-card",
    kk: "fa-users",
    ktp: "fa-id-card-clip",
    sktm: "fa-hand-holding-dollar",
    datang: "fa-arrow-right-to-bracket",
    keluar: "fa-arrow-right-from-bracket",
    usaha: "fa-store",
    domisili: "fa-house-chimney"
  };

  /* ----------------------------------------------
      FUNGSI GET PERSYARATAN
  ---------------------------------------------- */
  const getPersyaratan = (type) => {
    switch (type) {
      case "aktelahir": return PERSYARATAN_AKTA_LAHIR;
      case "aktemati": return PERSYARATAN_AKTA_MATI;
      case "kia": return PERSYARATAN_KIA;
      case "ktp": return PERSYARATAN_KTP;
      case "sktm": return PERSYARATAN_SKTM;
      case "datang": return PERSYARATAN_PINDAH_DATANG;
      case "keluar": return PERSYARATAN_PINDAH_KELUAR;
      case "usaha": return PERSYARATAN_USAHA;
      case "domisili": return PERSYARATAN_DOMISILI;
      case "kk": return PERSYARATAN_KK_SUB[kkType] || [];
      default: return [];
    }
  };

  const currentPersyaratan = getPersyaratan(jenis);

  /* ----------------------------------------------
      HANDLER INPUT
  ---------------------------------------------- */
  const handleFileChange = (e, key) => {
    const file = e.target.files[0];

    if (!file) return;

    // Validate file type
    const allowedTypes = ['application/pdf', 'image/jpeg', 'image/jpg', 'image/png'];
    if (!allowedTypes.includes(file.type)) {
      alert('❌ Tipe file tidak didukung!\n\nHanya file PDF, JPG, JPEG, dan PNG yang diperbolehkan.');
      e.target.value = ''; // Reset input
      return;
    }

    // Validate file size (max 5MB)
    const maxSize = 5 * 1024 * 1024; // 5MB in bytes
    if (file.size > maxSize) {
      alert(`❌ Ukuran file terlalu besar!\n\nFile: ${file.name}\nUkuran: ${(file.size / 1024 / 1024).toFixed(2)} MB\n\nMaksimal ukuran file adalah 5 MB.`);
      e.target.value = ''; // Reset input
      return;
    }

    // File valid, save to state
    setFiles({ ...files, [key]: file });
  };

  const handleAdditionalFieldChange = (e) => {
    setAdditionalFields({
      ...additionalFields,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!e.currentTarget.reportValidity()) return;

    setIsSubmitting(true);
    setUploadProgress("Mempersiapkan data...");

    try {
      // 1. Upload files to Supabase Storage first
      const uploadedFiles = {};
      const fileEntries = Object.entries(files).filter(([_, file]) => file);

      if (fileEntries.length > 0) {
        setUploadProgress(`Mengupload ${fileEntries.length} file...`);

        for (let i = 0; i < fileEntries.length; i++) {
          const [key, file] = fileEntries[i];

          // Generate unique filename
          const timestamp = Date.now();
          const randomStr = Math.random().toString(36).substring(7);
          const fileExt = file.name.split('.').pop();
          const fileName = `${timestamp}_${randomStr}.${fileExt}`;
          const sanitizedName = additionalFields.nama.replace(/[^a-zA-Z0-9]/g, '_');
          const filePath = `${sanitizedName}/${fileName}`;

          setUploadProgress(`Mengupload file ${i + 1}/${fileEntries.length}: ${file.name}...`);

          // Upload to Supabase Storage
          const { data, error } = await supabase.storage
            .from('pengajuan-surat-files')
            .upload(filePath, file, {
              cacheControl: '3600',
              upsert: false
            });

          if (error) {
            console.error('Error uploading file:', error);
            throw new Error(`Gagal upload ${file.name}: ${error.message}`);
          }

          // Get public URL
          const { data: urlData } = supabase.storage
            .from('pengajuan-surat-files')
            .getPublicUrl(filePath);

          uploadedFiles[key] = {
            name: file.name,
            path: filePath,
            url: urlData.publicUrl,
            size: file.size,
            type: file.type
          };
        }
      }

      // 2. Prepare data untuk Supabase
      setUploadProgress("Menyimpan data ke database...");

      const suratData = {
        nama: additionalFields.nama,
        nomor_telepon: additionalFields.nomorTelepon,
        jenis_surat: titleMap[jenis],
        status: 'pending'
      };

      // Add optional fields based on jenis surat
      if (jenis === "usaha" && additionalFields.namaUsaha) {
        suratData.nama_usaha = additionalFields.namaUsaha;
      }

      if ((jenis === "datang" || jenis === "keluar") && additionalFields.alamatTujuan) {
        suratData.alamat_tujuan = additionalFields.alamatTujuan;
      }

      if (jenis === "kk") {
        suratData.jenis_kk = kkType;
      }

      // Store uploaded files info
      if (Object.keys(uploadedFiles).length > 0) {
        suratData.files_uploaded = uploadedFiles;
      }

      // 3. Save to Supabase database
      const { data, error } = await createSurat(suratData);

      if (error) {
        throw error;
      }

      console.log("DATA TERSIMPAN KE SUPABASE:", data);
      alert(`✅ Permohonan ${titleMap[jenis]} berhasil dikirim!\n\nNomor Pengajuan: ${data.id.substring(0, 8).toUpperCase()}\n\nFile berhasil di-upload: ${Object.keys(uploadedFiles).length} file\n\nSilakan tunggu konfirmasi dari admin.`);

      // Reset form
      setFiles({});
      setAdditionalFields({
        nama: "",
        nomorTelepon: "",
        namaUsaha: "",
        alamatTujuan: ""
      });
      setUploadProgress("");

      // Kembali ke daftar surat
      if (onBack) onBack();

    } catch (error) {
      console.error("Error menyimpan data:", error);
      alert("❌ Gagal mengirim permohonan. Silakan coba lagi.\n\nError: " + (error.message || "Unknown error"));
      setUploadProgress("");
    } finally {
      setIsSubmitting(false);
    }
  };


  /* ----------------------------------------------
      VALIDASI JENIS SURAT
  ---------------------------------------------- */
  if (!UPLOAD_SURAT_LIST.includes(jenis)) {
    return (
      <div className="mt-6 p-6 bg-red-100 text-red-800 rounded-xl border border-red-400 shadow">
        <p>Jenis surat "{jenis}" tidak dikenali.</p>
        <button onClick={onBack} className="mt-4 text-sm underline">← Kembali</button>
      </div>
    );
  }

  /* ----------------------------------------------
      RENDER UTAMA
  ---------------------------------------------- */
  return (
    <div className="mt-6 bg-white p-6 rounded-xl shadow-md border">

      {/* BACK BUTTON */}
      <button
        onClick={onBack}
        className="text-sm mb-4 text-blue-600 hover:underline"
      >
        ← Kembali ke daftar surat
      </button>

      {/* TITLE */}
      <h3 className="text-xl font-bold mb-4 text-blue-600">
        <i className={`fas ${iconMap[jenis]} mr-2`}></i>
        {titleMap[jenis]} (Upload Dokumen)
      </h3>

      {/* DROPDOWN KHUSUS KK */}
      {jenis === "kk" && (
        <div className="mb-6">
          <label className="block text-sm font-medium mb-2">Pilih Jenis Permohonan:</label>
          <select
            value={kkType}
            onChange={(e) => {
              setKkType(e.target.value);
              setFiles({});
            }}
            className="w-full border rounded-lg px-4 py-2"
          >
            {Object.entries(PERSYARATAN_KK_SUB).map(([key]) => (
              <option key={key} value={key}>{key}</option>
            ))}
          </select>
        </div>
      )}

      {/* PANEL PERSYARATAN */}
      <div className="p-4 bg-blue-50 border border-blue-300 rounded-lg mb-6 shadow-sm">
        <h4 className="font-bold text-blue-800 mb-2 flex items-center gap-2">
          <i className="fas fa-robot"></i> Asisten Persyaratan
        </h4>

        <ol className="list-decimal list-inside text-sm space-y-1">
          {currentPersyaratan.map((item, idx) => (
            <li key={idx}>{item}</li>
          ))}
        </ol>
      </div>

      {/* FORM UPLOAD */}
      <form onSubmit={handleSubmit} className="space-y-4 border-t pt-4">

        {/* DATA DIRI */}
        <div className="p-4 border rounded-lg bg-gradient-to-r from-blue-50 to-indigo-50 border-blue-200 shadow-sm">
          <h4 className="font-bold text-blue-800 mb-3 flex items-center gap-2">
            <i className="fas fa-user-circle"></i> Data Diri Pengaju
          </h4>

          <div className="space-y-3">

            {/* Nama */}
            <div>
              <label className="text-sm font-medium mb-1 block text-gray-700">
                Nama Lengkap <span className="text-red-500">*</span>
              </label>

              <input
                type="text"
                name="nama"
                value={additionalFields.nama}
                onChange={handleAdditionalFieldChange}
                className="w-full border rounded-lg px-4 py-2 focus:ring-2"
                placeholder="Masukkan nama lengkap Anda"
                required
              />
            </div>

            {/* Nomor Telepon */}
            <div>
              <label className="text-sm font-medium mb-1 block text-gray-700">
                Nomor Telepon / WhatsApp <span className="text-red-500">*</span>
              </label>

              <input
                type="tel"
                name="nomorTelepon"
                value={additionalFields.nomorTelepon}
                onChange={handleAdditionalFieldChange}
                className="w-full border rounded-lg px-4 py-2 focus:ring-2"
                placeholder="Contoh: 08123456789"
                pattern="[0-9]{10,13}"
                title="Nomor telepon harus 10-13 digit angka"
                required
              />

              <p className="text-xs text-gray-500 mt-1">
                <i className="fas fa-info-circle"></i> Format: 10–13 digit angka
              </p>
            </div>

          </div>
        </div>

        {/* FIELD TAMBAHAN: USAHA */}
        {jenis === "usaha" && (
          <div className="p-3 border rounded-lg bg-yellow-50">
            <label className="text-sm font-medium mb-1 block">Nama Usaha</label>

            <input
              type="text"
              name="namaUsaha"
              value={additionalFields.namaUsaha}
              onChange={handleAdditionalFieldChange}
              className="w-full border rounded-lg px-4 py-2"
              required
            />
          </div>
        )}

        {/* FIELD TAMBAHAN: PINDAH */}
        {(jenis === "datang" || jenis === "keluar") && (
          <div className="p-3 border rounded-lg bg-yellow-50">
            <label className="text-sm font-medium mb-1 block">
              Alamat Tujuan Pindah
            </label>

            <textarea
              rows="3"
              name="alamatTujuan"
              value={additionalFields.alamatTujuan}
              onChange={handleAdditionalFieldChange}
              className="w-full border rounded-lg px-4 py-2"
              required
            ></textarea>
          </div>
        )}

        {/* UPLOAD FILE */}
        <h4 className="text-lg font-semibold mt-6 pt-4 border-t">
          Unggah Dokumen Persyaratan:
        </h4>

        {currentPersyaratan.map((req, idx) => (
          <div key={idx} className="p-3 border rounded-lg bg-white shadow-sm">
            <label className="text-sm font-medium block">{req}</label>

            <label className="inline-flex items-center px-4 py-2 mt-2 text-sm font-semibold rounded-md cursor-pointer text-white bg-blue-500 hover:bg-blue-600">
              Pilih File
              <input
                type="file"
                className="hidden"
                accept=".pdf,.jpg,.jpeg,.png,image/jpeg,image/png,application/pdf"
                disabled={req.startsWith("Catatan Khusus:")}
                required={!req.startsWith("Catatan Khusus:")}
                onChange={(e) => handleFileChange(e, req)}
              />
            </label>

            <p className="text-xs text-gray-500 mt-1">
              {files[req] ? `✓ ${files[req].name}` : "Belum ada file"}
            </p>
            <p className="text-xs text-gray-400 mt-1">
              <i className="fas fa-info-circle"></i> Format: PDF, JPG, JPEG, PNG (Max 5MB)
            </p>
          </div>
        ))}

        {/* UPLOAD PROGRESS */}
        {uploadProgress && (
          <div className="p-3 bg-blue-50 border border-blue-300 rounded-lg">
            <p className="text-sm text-blue-800 flex items-center gap-2">
              <i className="fas fa-spinner fa-spin"></i>
              {uploadProgress}
            </p>
          </div>
        )}

        {/* SUBMIT */}
        <button
          type="submit"
          disabled={isSubmitting}
          className="w-full bg-blue-600 text-white font-bold py-3 rounded-lg hover:bg-blue-700 transition disabled:bg-gray-400 disabled:cursor-not-allowed flex items-center justify-center gap-2"
        >
          {isSubmitting ? (
            <>
              <i className="fas fa-spinner fa-spin"></i>
              Mengirim...
            </>
          ) : (
            <>
              <i className="fas fa-paper-plane"></i>
              Submit Semua Dokumen
            </>
          )}
        </button>

      </form>
    </div>
  );
}

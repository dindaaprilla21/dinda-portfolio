import React, { useState } from 'react';
import { createPengaduan } from '../../services/pengaduanService';
import { supabase } from '../../config/supabaseClient';

// Daftar Kategori Pengaduan
const CATEGORIES = [
    { value: 'infrastruktur', label: 'Infrastruktur / Sarana Desa' },
    { value: 'pelayanan', label: 'Kinerja Pegawai / Pelayanan' },
    { value: 'lingkungan', label: 'Lingkungan' },
    { value: 'keamanan', label: 'Keamanan' },
    { value: 'lainnya', label: 'Lainnya' },
];

// Pastikan props 'onBack' diterima jika komponen ini dipanggil dari navigasi
export default function FormPengaduan({ onBack }) {
    const [formData, setFormData] = useState({
        nik: '',
        nama: '',
        telepon: '',
        email: '',
        kategori: '',
        prioritas: 'sedang',
        judul: '',
        deskripsi: '',
        lokasi: '',
    });
    const [buktiFile, setBuktiFile] = useState(null);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [uploadProgress, setUploadProgress] = useState('');

    const handleChange = (e) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value
        });
    };

    const handleFileChange = (e) => {
        const file = e.target.files[0];

        if (!file) return;

        // Validate file type
        const allowedTypes = ['application/pdf', 'image/jpeg', 'image/jpg', 'image/png'];
        if (!allowedTypes.includes(file.type)) {
            alert('❌ Tipe file tidak didukung!\n\nHanya file PDF, JPG, JPEG, dan PNG yang diperbolehkan.');
            e.target.value = '';
            return;
        }

        // Validate file size (max 5MB)
        const maxSize = 5 * 1024 * 1024;
        if (file.size > maxSize) {
            alert(`❌ Ukuran file terlalu besar!\n\nFile: ${file.name}\nUkuran: ${(file.size / 1024 / 1024).toFixed(2)} MB\n\nMaksimal ukuran file adalah 5 MB.`);
            e.target.value = '';
            return;
        }

        setBuktiFile(file);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        setIsSubmitting(true);
        setUploadProgress('Mempersiapkan data...');

        try {
            let buktiUrl = null;

            // Upload bukti file if exists
            if (buktiFile) {
                setUploadProgress('Mengupload bukti...');

                const timestamp = Date.now();
                const randomStr = Math.random().toString(36).substring(7);
                const fileExt = buktiFile.name.split('.').pop();
                const fileName = `${timestamp}_${randomStr}.${fileExt}`;
                const sanitizedName = formData.nama.replace(/[^a-zA-Z0-9]/g, '_');
                const filePath = `pengaduan/${sanitizedName}/${fileName}`;

                const { data, error: uploadError } = await supabase.storage
                    .from('pengajuan-surat-files')
                    .upload(filePath, buktiFile, {
                        cacheControl: '3600',
                        upsert: false
                    });

                if (uploadError) {
                    throw new Error(`Gagal upload bukti: ${uploadError.message}`);
                }

                // Get public URL
                const { data: urlData } = supabase.storage
                    .from('pengajuan-surat-files')
                    .getPublicUrl(filePath);

                buktiUrl = urlData.publicUrl;
            }

            // Prepare data for Supabase
            setUploadProgress('Menyimpan data ke database...');

            const pengaduanData = {
                nama: formData.nama,
                nik: formData.nik || null,
                telepon: formData.telepon,
                email: formData.email || null,
                kategori: formData.kategori,
                judul: formData.judul,
                deskripsi: formData.deskripsi,
                lokasi: formData.lokasi || null,
                status: 'pending',
                prioritas: formData.prioritas
            };

            // Add bukti URL if file was uploaded
            if (buktiUrl) {
                pengaduanData.bukti_foto_url = buktiUrl;
            }

            // Save to Supabase
            const { data, error } = await createPengaduan(pengaduanData);

            if (error) {
                throw error;
            }

            console.log('DATA TERSIMPAN KE SUPABASE:', data);
            alert(`✅ Pengaduan dengan judul "${formData.judul}" berhasil dikirim!\n\nNomor Laporan: ${data.id.substring(0, 8).toUpperCase()}\n\nTerima kasih atas laporannya. Tim kami akan segera menindaklanjuti.`);

            // Reset form
            setFormData({
                nik: '',
                nama: '',
                telepon: '',
                email: '',
                kategori: '',
                prioritas: 'sedang',
                judul: '',
                deskripsi: '',
                lokasi: '',
            });
            setBuktiFile(null);
            setUploadProgress('');

            // Kembali ke halaman sebelumnya
            if (onBack) onBack();

        } catch (error) {
            console.error('Error menyimpan data:', error);
            alert('❌ Gagal mengirim pengaduan. Silakan coba lagi.\n\nError: ' + (error.message || 'Unknown error'));
            setUploadProgress('');
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className={`mt-6 bg-white p-8 rounded-2xl shadow-lg border-t-4 border-red-500`}>

            {/* Tombol Kembali */}
            {onBack && (
                <button
                    onClick={onBack}
                    className={`text-sm mb-4 text-gray-600 hover:underline`}
                >
                    ← Kembali
                </button>
            )}

            {/* Judul */}
            <h3 className={`text-2xl font-bold mb-6 flex items-center gap-2 text-red-600`}>
                <i className="fas fa-bullhorn"></i> Formulir Lapor & Pengaduan
            </h3>

            {/* Kotak Info */}
            <div className={`p-4 bg-gray-100 border border-gray-300 rounded-lg mb-6 shadow-sm`}>
                <p className={`text-sm text-gray-700 font-medium`}>
                    Identitas Anda akan dirahasiakan jika diperlukan. Lengkapi data di bawah ini dengan akurat.
                </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">

                {/* BAGIAN 1: DATA PELAPOR */}
                <div className="border p-4 rounded-lg bg-gray-50">
                    <h4 className="font-semibold text-lg mb-3 text-gray-700">1. Data Pelapor</h4>
                    <div className="space-y-3">
                        {/* NAMA */}
                        <div>
                            <label className="block text-sm font-medium">Nama Lengkap <span className="text-red-500">*</span></label>
                            <input
                                type="text"
                                name="nama"
                                value={formData.nama}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-4 py-2 bg-white"
                                placeholder="Nama Lengkap Anda"
                                required
                            />
                        </div>

                        {/* NIK */}
                        <div>
                            <label className="block text-sm font-medium">NIK (Opsional)</label>
                            <input
                                type="text"
                                name="nik"
                                value={formData.nik}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-4 py-2 bg-white"
                                placeholder="NIK Anda"
                                pattern="[0-9]{16}"
                                title="NIK harus 16 digit"
                            />
                        </div>

                        {/* TELEPON */}
                        <div>
                            <label className="block text-sm font-medium">Nomor Telepon/HP <span className="text-red-500">*</span></label>
                            <input
                                type="tel"
                                name="telepon"
                                value={formData.telepon}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-4 py-2 bg-white"
                                placeholder="08...."
                                pattern="[0-9]{10,13}"
                                title="Nomor telepon harus 10-13 digit"
                                required
                            />
                        </div>

                        {/* EMAIL */}
                        <div>
                            <label className="block text-sm font-medium">Email (Opsional)</label>
                            <input
                                type="email"
                                name="email"
                                value={formData.email}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-4 py-2 bg-white"
                                placeholder="email@example.com"
                            />
                        </div>
                    </div>
                </div>

                {/* BAGIAN 2: DETAIL PENGADUAN */}
                <div className="border p-4 rounded-lg bg-gray-50">
                    <h4 className="font-semibold text-lg mb-3 text-gray-700">2. Detail Pengaduan</h4>
                    <div className="space-y-3">
                        {/* KATEGORI */}
                        <div>
                            <label className="block text-sm font-medium">Kategori Pengaduan <span className="text-red-500">*</span></label>
                            <select
                                name="kategori"
                                value={formData.kategori}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-4 py-2 bg-white"
                                required
                            >
                                <option value="" disabled>-- Pilih Kategori --</option>
                                {CATEGORIES.map(cat => (
                                    <option key={cat.value} value={cat.value}>{cat.label}</option>
                                ))}
                            </select>
                        </div>

                        {/* PRIORITAS */}
                        <div>
                            <label className="block text-sm font-medium">Tingkat Prioritas <span className="text-red-500">*</span></label>
                            <select
                                name="prioritas"
                                value={formData.prioritas}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-4 py-2 bg-white"
                                required
                            >
                                <option value="rendah">🟢 Rendah - Tidak Mendesak</option>
                                <option value="sedang">🟡 Sedang - Perlu Perhatian</option>
                                <option value="tinggi">🔴 Tinggi - Sangat Mendesak</option>
                            </select>
                            <p className="text-xs text-gray-500 mt-1">
                                <i className="fas fa-info-circle"></i> Pilih tingkat prioritas sesuai urgensi pengaduan Anda
                            </p>
                        </div>

                        {/* JUDUL Laporan */}
                        <div>
                            <label className="block text-sm font-medium">Judul Laporan <span className="text-red-500">*</span></label>
                            <input
                                type="text"
                                name="judul"
                                value={formData.judul}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-4 py-2 bg-white"
                                placeholder="Judul Singkat Pengaduan"
                                required
                            />
                        </div>

                        {/* LOKASI */}
                        <div>
                            <label className="block text-sm font-medium">Lokasi Kejadian (Opsional)</label>
                            <input
                                type="text"
                                name="lokasi"
                                value={formData.lokasi}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-4 py-2 bg-white"
                                placeholder="Contoh: Jl. Raya Desa No. 123"
                            />
                        </div>

                        {/* DESKRIPSI */}
                        <div>
                            <label className="block text-sm font-medium">Deskripsi Detail <span className="text-red-500">*</span></label>
                            <textarea
                                rows="4"
                                name="deskripsi"
                                value={formData.deskripsi}
                                onChange={handleChange}
                                className="w-full border rounded-lg px-4 py-2 bg-white"
                                placeholder="Jelaskan detail pengaduan Anda..."
                                required
                            ></textarea>
                        </div>

                        {/* UPLOAD BUKTI */}
                        <div className="pt-2">
                            <label className="block text-sm font-medium text-gray-700 mb-1">
                                Unggah Bukti (Foto/Dokumen, Opsional)
                            </label>
                            <input
                                type="file"
                                accept=".pdf,.jpg,.jpeg,.png,image/jpeg,image/png,application/pdf"
                                onChange={handleFileChange}
                                className={`w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-gray-200 file:text-gray-700 hover:file:bg-gray-300`}
                            />
                            {buktiFile && <p className="text-xs text-green-600 mt-1">✓ File Terunggah: {buktiFile.name}</p>}
                            <p className="text-xs text-gray-400 mt-1">
                                <i className="fas fa-info-circle"></i> Format: PDF, JPG, JPEG, PNG (Max 5MB)
                            </p>
                        </div>
                    </div>
                </div>

                {/* UPLOAD PROGRESS */}
                {uploadProgress && (
                    <div className="p-3 bg-blue-50 border border-blue-300 rounded-lg">
                        <p className="text-sm text-blue-800 flex items-center gap-2">
                            <i className="fas fa-spinner fa-spin"></i>
                            {uploadProgress}
                        </p>
                    </div>
                )}

                {/* Tombol Submit */}
                <button
                    type="submit"
                    disabled={isSubmitting}
                    className={`w-full bg-red-600 text-white font-bold py-3 rounded-lg hover:bg-red-700 transition disabled:bg-gray-400 disabled:cursor-not-allowed flex items-center justify-center gap-2`}
                >
                    {isSubmitting ? (
                        <>
                            <i className="fas fa-spinner fa-spin"></i>
                            Mengirim...
                        </>
                    ) : (
                        <>
                            <i className="fas fa-paper-plane"></i>
                            Kirim Laporan / Pengaduan
                        </>
                    )}
                </button>
            </form>
        </div>
    );
}
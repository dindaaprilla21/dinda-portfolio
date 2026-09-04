import React from 'react';
import BeritaCard from './BeritaCard';
import berita1 from '../../assets/images/berita1.jpeg';
import berita2 from '../../assets/images/berita2.jpeg';
import berita3 from '../../assets/images/berita3.jpg';
import berita4 from '../../assets/images/berita4.jpeg';
import berita5 from '../../assets/images/berita5.png';

// Data Dummy Berita
const BERITA_LIST = [
    { id: 1, tanggal: "17 November 2025", kategori: "Pembangunan", judul: "Pemerintah Desa Legok Umumkan Publikasi Infografik Perubahan APBDesa Tahun 2025", imageUrl: berita5 },
    { id: 2, tanggal: "17 November 2025", kategori: "Sosial", judul: "Musdesus (Musyawarah Desa Khusus) Pembentukan Koperasi Desa Merah Putih Legok Kecamatan Legok", imageUrl: berita1 },
    { id: 3, tanggal: "19 September 2025", kategori: "Pemerintahan", judul: "Desa Legok Tuntas Ikuti Monitoring & Evaluasi ke-3 Percontohan Desa Anti Korupsi 2025", imageUrl: berita2 },
    { id: 4, tanggal: "17 November 2025", kategori: "Pemerintahan", judul: "Pemerintah Desa Legok Meraih Predikat Desa Antikorupsi Tahun 2025 Oleh KPK", imageUrl: berita3 },
    { id: 5, tanggal: "15 September 2025", kategori: "Pemerintahan", judul: "Pembinaan Pencegahan Korupsi dan Gratifikasi di Desa Legok, Inspektorat dan Kejaksaan Negeri Tangerang Perkuat Komitmen Desa Anti Korupsi", imageUrl: berita4 },
];

export default function BeritaSection() {
    return (
        <section id="berita" className="py-2">
            <div className="container mx-auto">

                {/* CARD WRAPPER DENGAN BAYANGAN HIJAU */}
                <div
                    className="bg-white p-6 md:p-8 rounded-xl border-t-8 border-green-600"
                    style={{
                        boxShadow: '0 10px 15px -3px rgba(16, 185, 129, 0.1), 0 4px 6px -2px rgba(16, 185, 129, 0.05)'
                    }}
                >

                    {/* Judul Bagian */}
                    <h2 className="text-2xl font-bold text-gray-800 mb-6 pb-4 border-b border-gray-200">
                        <i className="fas fa-bullhorn mr-2 text-green-600"></i> Kabar Desa Terbaru
                    </h2>

                    {/* GRID BERITA: Layout Card 3 Kolom */}
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        {BERITA_LIST.map(berita => (
                            <BeritaCard key={berita.id} berita={berita} />
                        ))}
                    </div>

                    {/* Tombol Lihat Semua */}
                    <div className="text-center pt-6 mt-6 border-t border-gray-100">
                        <a href="" className="inline-flex items-center text-base font-bold text-green-600 hover:text-green-700 transition">
                            Lihat Seluruh Arsip Berita <i className="fas fa-angle-right ml-2"></i>
                        </a>
                    </div>
                </div>

            </div>
        </section>
    );
}
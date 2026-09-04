import React, { useState } from 'react';
import { Link } from 'react-router-dom';

// Data berita terbaru (bisa diganti dengan API)
const BERITA_TERBARU = [
    { id: 1, tanggal: "15 November 2025", judul: "Peningkatan Mutu Jalan Lingkungan RT 05: Program Tuntas di Akhir Tahun" },
    { id: 2, tanggal: "01 November 2025", judul: "Sosialisasi Pencegahan Stunting dan Peningkatan Gizi Balita" },
    { id: 3, tanggal: "20 Oktober 2025", judul: "Pembukaan Pendaftaran Calon Anggota BPD Masa Jabatan 2026-2032" },
    { id: 4, tanggal: "10 Oktober 2025", judul: "Bantuan Sosial Tunai (BST) Tahap 4: Distribusi Tepat Sasaran" },
    { id: 5, tanggal: "05 Oktober 2025", judul: "Pelatihan Kewirausahaan untuk UMKM Desa Legok" }
];

export default function BeritaSidebar({ currentBeritaId }) {
    const [searchQuery, setSearchQuery] = useState('');

    const handleSearch = (e) => {
        e.preventDefault();
        // Implementasi search nanti
        console.log('Searching for:', searchQuery);
    };

    return (
        <div className="space-y-6">

            {/* Pencarian Berita */}
            <div className="bg-white rounded-xl shadow-md p-6">
                <h3 className="text-lg font-bold text-gray-800 mb-4 flex items-center">
                    <i className="fas fa-search mr-2 text-green-600"></i>
                    Pencarian Berita
                </h3>

                <form onSubmit={handleSearch} className="relative">
                    <input
                        type="text"
                        placeholder="Cari berita..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full px-4 py-3 pr-12 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
                    />
                    <button
                        type="submit"
                        className="absolute right-2 top-1/2 -translate-y-1/2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition"
                    >
                        <i className="fas fa-search"></i>
                    </button>
                </form>
            </div>

            {/* Berita Terakhir */}
            <div className="bg-white rounded-xl shadow-md p-6">
                <h3 className="text-lg font-bold text-gray-800 mb-4 flex items-center border-b border-gray-200 pb-3">
                    <i className="fas fa-newspaper mr-2 text-green-600"></i>
                    Berita Terakhir
                </h3>

                <div className="space-y-4">
                    {BERITA_TERBARU
                        .filter(berita => berita.id !== currentBeritaId)
                        .slice(0, 4)
                        .map((berita) => (
                            <Link
                                key={berita.id}
                                to={`/berita/${berita.id}`}
                                className="block group hover:bg-green-50 p-3 rounded-lg transition"
                            >
                                <h4 className="text-sm font-semibold text-gray-800 group-hover:text-green-700 transition line-clamp-2 mb-2">
                                    {berita.judul}
                                </h4>
                                <p className="text-xs text-gray-500 flex items-center">
                                    <i className="far fa-calendar mr-1"></i>
                                    {berita.tanggal}
                                </p>
                            </Link>
                        ))}
                </div>

                {/* Lihat Semua */}
                <Link
                    to="/#berita"
                    className="block mt-4 pt-4 border-t border-gray-200 text-center text-sm font-semibold text-green-600 hover:text-green-700 transition"
                >
                    Lihat Semua Berita <i className="fas fa-arrow-right ml-1"></i>
                </Link>
            </div>

            {/* Kategori Berita */}
            <div className="bg-white rounded-xl shadow-md p-6">
                <h3 className="text-lg font-bold text-gray-800 mb-4 flex items-center border-b border-gray-200 pb-3">
                    <i className="fas fa-folder mr-2 text-green-600"></i>
                    Kategori
                </h3>

                <div className="space-y-2">
                    {['Pembangunan', 'Kesehatan', 'Pemerintahan', 'Sosial', 'Pendidikan', 'Ekonomi'].map((kategori) => (
                        <a
                            key={kategori}
                            href={`/#berita?kategori=${kategori}`}
                            className="flex items-center justify-between px-3 py-2 rounded-lg hover:bg-green-50 transition group"
                        >
                            <span className="text-sm text-gray-700 group-hover:text-green-700 font-medium">
                                {kategori}
                            </span>
                            <i className="fas fa-chevron-right text-xs text-gray-400 group-hover:text-green-600"></i>
                        </a>
                    ))}
                </div>
            </div>

        </div>
    );
}

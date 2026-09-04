import React from 'react';
import { Link } from 'react-router-dom';

export default function BeritaCard({ berita }) {
    const data = berita || {
        tanggal: "12 Okt 2023",
        kategori: "Pembangunan",
        judul: "Musyawarah Perencanaan Pembangunan Desa Tahun 2024",
        imageUrl: "/images/berita5.png"
    };

    return (
        <Link
            to={`/berita/${data.id}`}
            className="group bg-white rounded-lg overflow-hidden shadow-md hover:shadow-xl transition-all duration-300 border border-gray-100 hover:border-green-200"
        >
            {/* Gambar Berita */}
            <div className="relative h-48 overflow-hidden bg-gray-200">
                <img
                    src={data.imageUrl}
                    alt={data.judul}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
                {/* Badge Kategori */}
                <span className="absolute top-3 left-3 inline-flex items-center px-3 py-1 rounded-full bg-green-600 text-white text-xs font-semibold shadow-md">
                    <i className="fas fa-tag mr-1.5"></i>
                    {data.kategori}
                </span>
            </div>

            {/* Konten Card */}
            <div className="p-4">
                {/* Tanggal */}
                <div className="flex items-center text-xs text-gray-500 mb-2">
                    <i className="far fa-calendar mr-1.5 text-green-600"></i>
                    {data.tanggal}
                </div>

                {/* Judul */}
                <h3 className="font-bold text-base text-gray-800 group-hover:text-green-700 transition line-clamp-2 leading-snug">
                    {data.judul}
                </h3>

                {/* Read More Link */}
                <div className="mt-3 flex items-center text-sm font-semibold text-green-600 group-hover:text-green-700">
                    Baca Selengkapnya
                    <i className="fas fa-arrow-right ml-1.5 text-xs group-hover:translate-x-1 transition-transform"></i>
                </div>
            </div>
        </Link>
    );
}
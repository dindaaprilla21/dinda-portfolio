import React from 'react';
import { Link } from 'react-router-dom';

export default function BeritaBreadcrumb({ judul }) {
    return (
        <div className="bg-white border-b border-gray-200">
            <div className="container mx-auto px-4 py-4">
                <nav className="flex items-center text-sm text-gray-600">

                    {/* Home Icon */}
                    <Link to="/" className="flex items-center hover:text-green-600 transition">
                        <i className="fas fa-home text-green-600"></i>
                    </Link>

                    <span className="mx-2 text-gray-400">/</span>

                    {/* Berita Link */}
                    <Link to="/#berita" className="hover:text-green-600 transition">
                        Berita
                    </Link>

                    <span className="mx-2 text-gray-400">/</span>

                    {/* Current Page */}
                    <span className="text-gray-800 font-medium truncate max-w-md">
                        {judul.length > 50 ? judul.substring(0, 50) + '...' : judul}
                    </span>

                </nav>
            </div>
        </div>
    );
}

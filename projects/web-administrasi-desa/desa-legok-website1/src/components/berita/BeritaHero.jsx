import React from 'react';

export default function BeritaHero({ judul }) {
    return (
        <section className="relative bg-gradient-to-r from-[var(--desa-main)] to-emerald-600 text-white py-16 md:py-24">

            {/* Decorative Pattern Overlay */}
            <div className="absolute inset-0 opacity-10">
                <div className="absolute inset-0" style={{
                    backgroundImage: `url(${pattern})`,
                }}></div>
            </div>

            <div className="container mx-auto px-4 relative z-10">
                <div className="max-w-4xl mx-auto text-center">

                    {/* Badge */}
                    <span className="inline-block px-4 py-1 rounded-full text-xs font-semibold mb-4
            bg-white/20 border border-white/30 text-white">
                        DESA LEGOK - KECAMATAN LEGOK
                    </span>

                    {/* Judul Berita */}
                    <h1 className="text-3xl md:text-5xl font-bold leading-tight mb-4">
                        {judul}
                    </h1>

                </div>
            </div>

            {/* Bottom Wave */}
            <div className="absolute bottom-0 left-0 right-0">
                <svg viewBox="0 0 1440 120" fill="none" xmlns="http://www.w3.org/2000/svg" className="w-full h-auto">
                    <path d="M0 120L60 105C120 90 240 60 360 45C480 30 600 30 720 37.5C840 45 960 60 1080 67.5C1200 75 1320 75 1380 75L1440 75V120H1380C1320 120 1200 120 1080 120C960 120 840 120 720 120C600 120 480 120 360 120C240 120 120 120 60 120H0Z" fill="#F9FAFB" />
                </svg>
            </div>

        </section>
    );
}

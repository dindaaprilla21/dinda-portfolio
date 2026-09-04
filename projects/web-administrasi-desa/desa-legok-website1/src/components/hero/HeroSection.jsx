import kantor from "../../assets/images/kantor.jpg";

export default function HeroSection() {
  return (
    <section
      id="beranda"
      className="relative h-[500px] flex items-center justify-center text-white overflow-hidden"
    >
      <div className="absolute inset-0 z-0">
        <img
          src={kantor}
          alt="Kantor Desa"
          className="w-full h-full object-cover"
        />

        {/* OVERLAY HIJAU – versi aman & stabil */}
        <div className="absolute inset-0 bg-[var(--desa-main)] opacity-60"></div>
      </div>

      <div className="relative z-10 text-center px-4 max-w-3xl">
        <span
          className="
            px-4 py-1 rounded-full 
            text-xs font-semibold mb-4 inline-block
            bg-[color-mix(in_srgb,var(--desa-light) 20%,transparent)]
            border border-[color-mix(in_srgb,var(--desa-light) 50%,transparent)]
            text-[var(--desa-light)]
          "
        >
          Pelayanan Digital
        </span>

        <h1 className="text-4xl md:text-5xl font-bold mb-4">
          Selamat Datang di <br /> Sistem Administrasi Desa Legok
        </h1>

        <p className="text-[var(--desa-light)] mb-4 text-sm md:text-base">
          Wujudkan desa yang mandiri, transparan dan melayani dengan sepenuh hati melalui platform digital terpadu.
        </p>

        {/* INFORMASI WAKTU PROSES BARU (Warna diubah ke text-white) */}
        <div className="mb-8 text-sm md:text-base font-semibold text-white">
          <i className="fas fa-clock mr-2"></i>
          Proses Penerbitan Surat: 3-5 Hari Kerja (setelah dokumen lengkap dan diverifikasi)
        </div>

        <div className="flex flex-col md:flex-row justify-center gap-4">
          <a
            href="#layanan"
            className="
              font-bold py-3 px-8 rounded-xl shadow-lg
              bg-[var(--desa-light)]
              text-[var(--desa-main)]
              hover:bg-green-400 transition transform hover:-translate-y-1
            "
          >
            Mulai Layanan
          </a>

          <a
            href="#kontak-wa"
            className="
              bg-white/10 border border-white text-white 
              font-semibold py-3 px-8 rounded-xl
              hover:bg-white hover:text-[var(--desa-main)] transition
            "
          >
            Hubungi Kami
          </a>
        </div>
      </div>
    </section>
  );
}
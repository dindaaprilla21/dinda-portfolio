import { FaFacebook, FaInstagram, FaYoutube, FaWhatsapp } from "react-icons/fa";

export default function Footer() {
  return (
    <footer className="bg-gray-800 text-white pt-12 pb-6 mt-12">
      <div className="container mx-auto px-6">

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">

          {/* Kolom 1 : Info Desa */}
          <div>
            <h3 className="font-bold text-xl mb-4">Desa Legok</h3>
            <p className="text-gray-400 text-sm leading-relaxed">
              Mewujudkan tata kelola pemerintahan desa yang baik, bersih, dan transparan.
            </p>
          </div>

          {/* Kolom 2 : Kontak */}
          <div>
            <h3 className="font-bold text-lg mb-4">Kontak</h3>
            <ul className="text-gray-400 text-sm space-y-2">
              <li>
                <i className="fas fa-map-marker-alt"></i>  
                {" "}Jl. Jayaningrat No.99, Desa Legok Kec Legok Kab. Tangerang
              </li>
              <li>
                <i className="fas fa-phone"></i>  081367737337
              </li>
              <li>
                <i className="fas fa-envelope"></i>  desalegok.kecamatanlegok@gmail.com
              </li>
            </ul>
          </div>

          {/* Kolom 3 : Media Sosial */}
          <div>
            <h3 className="font-bold text-lg mb-4">Media Sosial</h3>
            <ul className="text-gray-400 text-sm space-y-3">

              <li className="flex items-center gap-2">
                <FaInstagram className="text-pink-400" />
                <a href="https://www.instagram.com/desa_legok/" className="hover:text-white">Instagram</a>
              </li>

              <li className="flex items-center gap-2">
                <FaYoutube className="text-red-500" />
                <a href="https://www.youtube.com/@kabardesalegok" className="hover:text-white">YouTube</a>
              </li>

              <li className="flex items-center gap-2">
                <FaWhatsapp className="text-green-400" />
                <a href="https://wa.me/6281367737337" className="hover:text-white">WhatsApp</a>
              </li>

            </ul>
          </div>

        </div>

        {/* Copyright */}
        <div className="border-t border-gray-700 pt-6 text-center text-xs text-gray-500">
          © 2023 Pemerintah Desa Legok. All rights reserved.
        </div>
      </div>
    </footer>
  );
}

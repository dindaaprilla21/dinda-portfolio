import { useState } from "react";
import SuratList from "./SuratList";
import FormSurat from "./FormSurat";
import FormPengaduan from "./FormPengaduan";

export default function LayananSection() {
  const [showSuratList, setShowSuratList] = useState(false);
  const [selectedSurat, setSelectedSurat] = useState(null);
  const [showAduan, setShowAduan] = useState(false);

  const toggle = (type) => {
    if (type === "surat") {
      setShowSuratList(true);
      setShowAduan(false);
      setSelectedSurat(null); 
    } else {
      setShowAduan(true);
      setShowSuratList(false);
      setSelectedSurat(null);
    }
  };

  const goBack = () => {
    setSelectedSurat(null);      // kembali ke list surat
    setShowSuratList(true);      // tampilkan list lagi
  };

  return (
    <section id="layanan" className="mt-10">
      <div className="flex items-center gap-3 mb-6">
        <div className="w-1 h-8 bg-desa-main rounded-full"></div>
        <h2 className="text-2xl font-bold">Layanan Mandiri</h2>
      </div>

      {/* CARD AWAL */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div
          onClick={() => toggle("surat")}
          className="group cursor-pointer bg-white p-6 rounded-xl shadow-md border hover:border-desa-main"
        >
          <i className="fas fa-envelope-open-text text-3xl text-desa-main mb-3"></i>
          <h3 className="font-bold group-hover:text-desa-main">Buat Surat Online</h3>
          <p className="text-xs text-gray-500 mt-1">SKTM, Domisili, Pengantar, dll.</p>
        </div>

        <div
          onClick={() => toggle("aduan")}
          className="group cursor-pointer bg-white p-6 rounded-xl shadow-md border hover:border-red-500"
        >
          <i className="fas fa-bullhorn text-3xl text-red-500 mb-3"></i>
          <h3 className="font-bold group-hover:text-red-500">Lapor / Pengaduan</h3>
          <p className="text-xs text-gray-500 mt-1">Sampaikan aspirasi anda.</p>
        </div>
      </div>

      {/* LIST SURAT */}
      {showSuratList && !selectedSurat && (
        <SuratList onSelect={(jenis) => setSelectedSurat(jenis)} />
      )}

      {/* FORM SURAT + BACK BUTTON */}
      {selectedSurat && (
        <FormSurat jenis={selectedSurat} onBack={goBack} />
      )}

      {/* FORM ADUAN */}
      {showAduan && <FormPengaduan />}
    </section>
  );
}

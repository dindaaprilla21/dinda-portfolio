export default function SuratList({ onSelect }) {
  const jenisSurat = [
    { id: "aktelahir", title: "Akta Kelahiran" },
    { id: "aktemati", title: "Akta Kematian" },
    { id: "kia", title: "Kartu Identitas Anak" },
    { id: "ktp", title: "Kartu Tanda Penduduk" },
    { id: "kk", title: "Kartu Keluarga" },
    { id: "usaha", title: "Surat Keterangan Usaha" },
    { id: "domisili", title: "Surat Keterangan Domisili" },
    { id: "sktm", title: "Surat Keterangan Tidak Mampu" },
    { id: "datang", title: "Surat Pengantar Pindah Datang" },
    { id: "keluar", title: "Surat Pengantar Pindah Keluar" },
  ];

  return (
    <div className="mt-8">
      <h3 className="text-xl font-bold mb-4">Pilih Jenis Surat</h3>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        {jenisSurat.map((item) => (
          <div
            key={item.id}
            onClick={() => onSelect(item.id)}
            className="cursor-pointer border p-6 rounded-xl shadow-sm hover:shadow-md transition"
          >
            <h4 className="font-semibold">{item.title}</h4>
          </div>
        ))}
      </div>
    </div>
  );
}

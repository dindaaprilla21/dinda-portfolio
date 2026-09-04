export default function KontakWA() {
  return (
    <div id="kontak-wa" className="bg-gradient-to-br from-green-600 to-teal-700 rounded-3xl p-6 text-white shadow-xl">
      <h3 className="text-xl font-bold text-center mb-1">Hubungi Admin</h3>
      <p className="text-xs text-center text-green-100 mb-4">Scan QR atau klik tombol di bawah</p>

      <div className="bg-white p-3 rounded-xl w-40 h-40 mx-auto shadow-lg mb-4">
        <img
          src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=https://wa.me/6289647851864"
          className="w-full h-full"
        />
      </div>

      <a
        href="https://wa.me/6281367737337"
        target="_blank"
        className="flex items-center justify-center gap-2 bg-white text-green-700 font-bold py-3 rounded-xl"
      >
        <i className="fab fa-whatsapp text-xl"></i> Chat WhatsApp
      </a>
    </div>
  );
}

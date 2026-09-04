export default function JamOperasional() {
  return (
    <div className="bg-white p-6 rounded-2xl shadow-md border">
      <h4 className="font-bold mb-4 pb-2 border-b">Jam Operasional</h4>

      <ul className="space-y-3 text-sm text-gray-600">
        <li className="flex justify-between">
          <span>Senin - Jum`at</span>
          <span className="font-semibold">09:00 - 16:00</span>
        </li>
        <li className="flex justify-between text-red-500">
          <span>Sabtu - Minggu</span>
          <span className="font-semibold">Libur</span>
        </li>
      </ul>
    </div>
  );
}

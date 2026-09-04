import React, { useState, useEffect } from "react";
import { getAllSurat, updateSuratStatus } from "../../services/suratService";

export default function TabelPengajuanSurat() {
    const [searchTerm, setSearchTerm] = useState("");
    const [filterStatus, setFilterStatus] = useState("all");
    const [currentPage, setCurrentPage] = useState(1);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [suratData, setSuratData] = useState([]);
    const [totalCount, setTotalCount] = useState(0);
    const itemsPerPage = 10;

    // Fetch data from Supabase
    useEffect(() => {
        fetchSuratData();
    }, [currentPage, filterStatus, searchTerm]);

    const fetchSuratData = async () => {
        setLoading(true);
        setError(null);

        const filters = {
            status: filterStatus,
            search: searchTerm
        };

        const { data, count, error: fetchError } = await getAllSurat(filters, currentPage, itemsPerPage);

        if (fetchError) {
            setError("Gagal memuat data. Silakan coba lagi.");
            console.error(fetchError);
        } else {
            setSuratData(data || []);
            setTotalCount(count || 0);
        }

        setLoading(false);
    };

    // Filter and search (now done on server side, but keep for local display)
    const filteredData = suratData;

    // Pagination
    const totalPages = Math.ceil(totalCount / itemsPerPage);
    const paginatedData = filteredData;

    const getStatusBadge = (status) => {
        const badges = {
            pending: { label: "Pending", color: "bg-yellow-100 text-yellow-800 border-yellow-300" },
            diproses: { label: "Diproses", color: "bg-blue-100 text-blue-800 border-blue-300" },
            selesai: { label: "Selesai", color: "bg-green-100 text-green-800 border-green-300" },
            ditolak: { label: "Ditolak", color: "bg-red-100 text-red-800 border-red-300" }
        };
        return badges[status] || badges.pending;
    };

    const handleStatusChange = async (id, newStatus) => {
        const confirmed = window.confirm(`Ubah status pengajuan menjadi: ${newStatus}?`);
        if (!confirmed) return;

        const { data, error: updateError } = await updateSuratStatus(id, newStatus);

        if (updateError) {
            alert("Gagal mengubah status. Silakan coba lagi.");
            console.error(updateError);
        } else {
            alert(`Status pengajuan berhasil diubah menjadi: ${newStatus}`);
            // Refresh data
            fetchSuratData();
        }
    };

    const formatDate = (dateString) => {
        if (!dateString) return '-';
        const date = new Date(dateString);
        return date.toLocaleDateString('id-ID', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    };

    const handleDownloadFiles = (item) => {
        if (!item.files_uploaded || Object.keys(item.files_uploaded).length === 0) {
            alert('Tidak ada file yang di-upload untuk pengajuan ini.');
            return;
        }

        // Create modal content with file list
        const filesInfo = item.files_uploaded;
        const filesList = Object.entries(filesInfo).map(([key, fileData]) => {
            return `${key}: ${fileData.name}`;
        }).join('\n');

        const confirmed = window.confirm(
            `File yang tersedia untuk didownload:\n\n${filesList}\n\n` +
            `Total: ${Object.keys(filesInfo).length} file\n\n` +
            `Klik OK untuk membuka semua file di tab baru.\n\n` +
            `⚠️ PENTING: Izinkan pop-up di browser Anda!`
        );

        if (confirmed) {
            // Open files sequentially with delay to prevent popup blocker
            const fileEntries = Object.entries(filesInfo);

            fileEntries.forEach(([key, fileData], index) => {
                if (fileData.url) {
                    // Add delay between each file to prevent popup blocker
                    setTimeout(() => {
                        window.open(fileData.url, '_blank');
                    }, index * 300); // 300ms delay between each file
                }
            });

            // Show success message
            setTimeout(() => {
                alert(`✅ Membuka ${fileEntries.length} file...\n\nJika ada file yang tidak terbuka, pastikan pop-up tidak diblokir oleh browser.`);
            }, fileEntries.length * 300 + 500);
        }
    };

    const handleViewDetail = (item) => {
        let detailText = `Detail Pengajuan:\n\n`;
        detailText += `Nama: ${item.nama}\n`;
        detailText += `Telepon: ${item.nomor_telepon}\n`;
        detailText += `Jenis Surat: ${item.jenis_surat}\n`;

        if (item.nama_usaha) {
            detailText += `Nama Usaha: ${item.nama_usaha}\n`;
        }
        if (item.alamat_tujuan) {
            detailText += `Alamat Tujuan: ${item.alamat_tujuan}\n`;
        }
        if (item.jenis_kk) {
            detailText += `Jenis KK: ${item.jenis_kk}\n`;
        }

        detailText += `Status: ${item.status}\n`;
        detailText += `Tanggal: ${formatDate(item.tanggal_pengajuan)}\n`;

        // Add files info
        if (item.files_uploaded && Object.keys(item.files_uploaded).length > 0) {
            detailText += `\nFile yang di-upload:\n`;
            Object.entries(item.files_uploaded).forEach(([key, fileData]) => {
                detailText += `- ${key}: ${fileData.name}\n`;
            });
        } else {
            detailText += `\nTidak ada file yang di-upload.`;
        }

        alert(detailText);
    };


    return (
        <div className="space-y-6">

            {/* Header */}
            <div className="bg-gradient-to-r from-[var(--desa-main)] to-green-700 text-white p-6 rounded-xl shadow-lg">
                <h1 className="text-3xl font-bold mb-2">
                    <i className="fas fa-file-alt mr-3"></i>
                    Pengajuan Surat Online
                </h1>
                <p className="text-green-100">Kelola semua pengajuan surat dari masyarakat</p>
            </div>

            {/* Filters and Search */}
            <div className="bg-white rounded-xl shadow-md p-6">
                {/* Error Message */}
                {error && (
                    <div className="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded-lg flex items-center gap-2">
                        <i className="fas fa-exclamation-circle"></i>
                        <span className="text-sm">{error}</span>
                    </div>
                )}

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">

                    {/* Search */}
                    <div className="md:col-span-2">
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            <i className="fas fa-search mr-2"></i>Cari Pengajuan
                        </label>
                        <input
                            type="text"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--desa-main)]"
                            placeholder="Cari berdasarkan nama atau jenis surat..."
                        />
                    </div>

                    {/* Status Filter */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            <i className="fas fa-filter mr-2"></i>Filter Status
                        </label>
                        <select
                            value={filterStatus}
                            onChange={(e) => setFilterStatus(e.target.value)}
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--desa-main)]"
                        >
                            <option value="all">Semua Status</option>
                            <option value="pending">Pending</option>
                            <option value="diproses">Diproses</option>
                            <option value="selesai">Selesai</option>
                            <option value="ditolak">Ditolak</option>
                        </select>
                    </div>
                </div>

                {/* Results Count */}
                <div className="mt-4 text-sm text-gray-600">
                    {loading ? (
                        <span>Memuat data...</span>
                    ) : (
                        <>Menampilkan <span className="font-semibold">{paginatedData.length}</span> dari <span className="font-semibold">{totalCount}</span> pengajuan</>
                    )}
                </div>
            </div>

            {/* Table */}
            <div className="bg-white rounded-xl shadow-md overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full">
                        <thead className="bg-[var(--desa-main)] text-white">
                            <tr>
                                <th className="px-6 py-4 text-left text-sm font-semibold">No</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Nama Pengaju</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Nomor Telepon</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Jenis Surat</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Tanggal</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Status</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Aksi</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-200">
                            {loading ? (
                                <tr>
                                    <td colSpan="7" className="px-6 py-8 text-center text-gray-500">
                                        <i className="fas fa-spinner fa-spin text-4xl mb-2 block text-[var(--desa-main)]"></i>
                                        Memuat data...
                                    </td>
                                </tr>
                            ) : paginatedData.length > 0 ? (
                                paginatedData.map((item, idx) => (
                                    <tr key={item.id} className="hover:bg-gray-50 transition">
                                        <td className="px-6 py-4 text-sm text-gray-700">{(currentPage - 1) * itemsPerPage + idx + 1}</td>
                                        <td className="px-6 py-4 text-sm font-medium text-gray-900">{item.nama}</td>
                                        <td className="px-6 py-4 text-sm">
                                            <a
                                                href={`https://wa.me/${item.nomor_telepon.replace(/^0/, '62').replace(/\D/g, '')}`}
                                                target="_blank"
                                                rel="noopener noreferrer"
                                                className="text-[var(--desa-main)] hover:text-green-700 hover:underline flex items-center gap-1"
                                                title="Hubungi via WhatsApp"
                                            >
                                                <i className="fab fa-whatsapp"></i>
                                                {item.nomor_telepon}
                                            </a>
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-700">{item.jenis_surat}</td>
                                        <td className="px-6 py-4 text-sm text-gray-700">
                                            <i className="fas fa-calendar mr-2 text-gray-400"></i>
                                            {formatDate(item.tanggal_pengajuan)}
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className={`px-3 py-1 rounded-full text-xs font-semibold border ${getStatusBadge(item.status).color}`}>
                                                {getStatusBadge(item.status).label}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex gap-2">
                                                <button
                                                    onClick={() => handleViewDetail(item)}
                                                    className="px-3 py-1 bg-[var(--desa-main)] hover:bg-green-700 text-white text-xs rounded-lg transition"
                                                    title="Lihat Detail"
                                                >
                                                    <i className="fas fa-eye"></i>
                                                </button>
                                                <select
                                                    onChange={(e) => handleStatusChange(item.id, e.target.value)}
                                                    className="px-2 py-1 border border-gray-300 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-[var(--desa-main)]"
                                                    defaultValue=""
                                                >
                                                    <option value="" disabled>Ubah Status</option>
                                                    <option value="pending">Pending</option>
                                                    <option value="diproses">Diproses</option>
                                                    <option value="selesai">Selesai</option>
                                                    <option value="ditolak">Ditolak</option>
                                                </select>
                                                <button
                                                    onClick={() => handleDownloadFiles(item)}
                                                    className="px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white text-xs rounded-lg transition"
                                                    title="Download File"
                                                    disabled={!item.files_uploaded || Object.keys(item.files_uploaded).length === 0}
                                                >
                                                    <i className="fas fa-download"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan="7" className="px-6 py-8 text-center text-gray-500">
                                        <i className="fas fa-inbox text-4xl mb-2 block text-gray-300"></i>
                                        Tidak ada data yang ditemukan
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>

                {/* Pagination */}
                {totalPages > 1 && (
                    <div className="bg-gray-50 px-6 py-4 flex items-center justify-between border-t">
                        <button
                            onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                            disabled={currentPage === 1}
                            className="px-4 py-2 bg-white border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition"
                        >
                            <i className="fas fa-chevron-left mr-2"></i>
                            Sebelumnya
                        </button>

                        <span className="text-sm text-gray-700">
                            Halaman <span className="font-semibold">{currentPage}</span> dari <span className="font-semibold">{totalPages}</span>
                        </span>

                        <button
                            onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
                            disabled={currentPage === totalPages}
                            className="px-4 py-2 bg-white border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition"
                        >
                            Selanjutnya
                            <i className="fas fa-chevron-right ml-2"></i>
                        </button>
                    </div>
                )}
            </div>
        </div>
    );
}

import React, { useState, useEffect } from "react";
import { getAllPengaduan, updatePengaduanStatus } from "../../services/pengaduanService";

export default function TabelLaporanPengaduan() {
    const [searchTerm, setSearchTerm] = useState("");
    const [filterStatus, setFilterStatus] = useState("all");
    const [filterKategori, setFilterKategori] = useState("all");
    const [currentPage, setCurrentPage] = useState(1);
    const [data, setData] = useState([]);
    const [totalCount, setTotalCount] = useState(0);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const itemsPerPage = 10;

    // Fetch data from Supabase
    useEffect(() => {
        fetchPengaduanData();
    }, [currentPage, filterStatus, filterKategori, searchTerm]);

    const fetchPengaduanData = async () => {
        setLoading(true);
        setError(null);

        try {
            const filters = {};

            if (filterStatus !== "all") {
                filters.status = filterStatus;
            }

            if (filterKategori !== "all") {
                filters.kategori = filterKategori;
            }

            if (searchTerm) {
                filters.search = searchTerm;
            }

            const { data: pengaduanData, totalCount: count, error: fetchError } = await getAllPengaduan(
                filters,
                currentPage,
                itemsPerPage
            );

            if (fetchError) {
                throw fetchError;
            }

            setData(pengaduanData || []);
            setTotalCount(count || 0);
        } catch (err) {
            console.error("Error fetching pengaduan:", err);
            setError("Gagal memuat data pengaduan. Silakan coba lagi.");
        } finally {
            setLoading(false);
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

    const getStatusBadge = (status) => {
        const badges = {
            pending: { label: "Pending", color: "bg-yellow-100 text-yellow-800 border-yellow-300" },
            ditinjau: { label: "Ditinjau", color: "bg-blue-100 text-blue-800 border-blue-300" },
            diproses: { label: "Diproses", color: "bg-purple-100 text-purple-800 border-purple-300" },
            selesai: { label: "Selesai", color: "bg-green-100 text-green-800 border-green-300" },
            ditolak: { label: "Ditolak", color: "bg-red-100 text-red-800 border-red-300" }
        };
        return badges[status] || badges.pending;
    };

    const getPriorityBadge = (prioritas) => {
        const badges = {
            tinggi: { icon: "fa-exclamation-circle", color: "text-red-600" },
            sedang: { icon: "fa-info-circle", color: "text-orange-600" },
            rendah: { icon: "fa-check-circle", color: "text-green-600" }
        };
        return badges[prioritas] || badges.sedang;
    };

    const handleStatusChange = async (id, newStatus) => {
        const confirmed = window.confirm(`Apakah Anda yakin ingin mengubah status pengaduan ini menjadi "${newStatus}"?`);
        if (!confirmed) return;

        const { data, error: updateError } = await updatePengaduanStatus(id, newStatus);

        if (updateError) {
            alert("Gagal mengubah status. Silakan coba lagi.");
            console.error(updateError);
        } else {
            alert(`Status pengaduan berhasil diubah menjadi: ${newStatus}`);
            // Refresh data
            fetchPengaduanData();
        }
    };

    const handleViewDetail = (item) => {
        let detailText = `DETAIL PENGADUAN\n\n`;
        detailText += `Nama: ${item.nama}\n`;
        detailText += `NIK: ${item.nik || '-'}\n`;
        detailText += `Telepon: ${item.telepon}\n`;
        detailText += `Email: ${item.email || '-'}\n`;
        detailText += `Kategori: ${item.kategori}\n`;
        detailText += `Judul: ${item.judul}\n`;
        detailText += `Lokasi: ${item.lokasi || '-'}\n`;
        detailText += `Deskripsi:\n${item.deskripsi}\n\n`;
        detailText += `Status: ${item.status}\n`;
        detailText += `Prioritas: ${item.prioritas}\n`;
        detailText += `Tanggal Laporan: ${formatDate(item.tanggal_laporan)}\n`;

        if (item.tanggapan_admin) {
            detailText += `\nTanggapan Admin:\n${item.tanggapan_admin}`;
        }

        if (item.bukti_foto_url) {
            detailText += `\n\nBukti Foto: Ada (klik OK untuk membuka)`;
            const openBukti = window.confirm(detailText);
            if (openBukti) {
                window.open(item.bukti_foto_url, '_blank');
            }
        } else {
            alert(detailText);
        }
    };

    const truncateText = (text, maxLength = 60) => {
        return text.length > maxLength ? text.substring(0, maxLength) + "..." : text;
    };

    // Pagination
    const totalPages = Math.ceil(totalCount / itemsPerPage);

    return (
        <div className="space-y-6">

            {/* Header */}
            <div className="bg-gradient-to-r from-[var(--desa-main)] to-green-700 text-white p-6 rounded-xl shadow-lg">
                <h1 className="text-3xl font-bold mb-2">
                    <i className="fas fa-comments mr-3"></i>
                    Laporan Pengaduan
                </h1>
                <p className="text-green-100">Kelola semua laporan pengaduan dari masyarakat</p>
            </div>

            {/* Filters and Search */}
            <div className="bg-white rounded-xl shadow-md p-6">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">

                    {/* Search */}
                    <div className="md:col-span-2">
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            <i className="fas fa-search mr-2"></i>Cari Pengaduan
                        </label>
                        <input
                            type="text"
                            value={searchTerm}
                            onChange={(e) => {
                                setSearchTerm(e.target.value);
                                setCurrentPage(1); // Reset to first page
                            }}
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--desa-main)]"
                            placeholder="Cari berdasarkan nama, judul, atau deskripsi..."
                        />
                    </div>

                    {/* Kategori Filter */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            <i className="fas fa-tag mr-2"></i>Kategori
                        </label>
                        <select
                            value={filterKategori}
                            onChange={(e) => {
                                setFilterKategori(e.target.value);
                                setCurrentPage(1);
                            }}
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--desa-main)]"
                        >
                            <option value="all">Semua Kategori</option>
                            <option value="infrastruktur">Infrastruktur</option>
                            <option value="pelayanan">Pelayanan</option>
                            <option value="lingkungan">Lingkungan</option>
                            <option value="keamanan">Keamanan</option>
                            <option value="lainnya">Lainnya</option>
                        </select>
                    </div>

                    {/* Status Filter */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            <i className="fas fa-filter mr-2"></i>Status
                        </label>
                        <select
                            value={filterStatus}
                            onChange={(e) => {
                                setFilterStatus(e.target.value);
                                setCurrentPage(1);
                            }}
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--desa-main)]"
                        >
                            <option value="all">Semua Status</option>
                            <option value="pending">Pending</option>
                            <option value="ditinjau">Ditinjau</option>
                            <option value="diproses">Diproses</option>
                            <option value="selesai">Selesai</option>
                            <option value="ditolak">Ditolak</option>
                        </select>
                    </div>
                </div>

                {/* Results Count */}
                <div className="mt-4 text-sm text-gray-600">
                    Menampilkan <span className="font-semibold">{data.length}</span> dari <span className="font-semibold">{totalCount}</span> pengaduan
                </div>
            </div>

            {/* Table */}
            <div className="bg-white rounded-xl shadow-md overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full">
                        <thead className="bg-[var(--desa-main)] text-white">
                            <tr>
                                <th className="px-6 py-4 text-left text-sm font-semibold">No</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Nama Pelapor</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Kontak</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Kategori</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Judul</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Tanggal</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Prioritas</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Status</th>
                                <th className="px-6 py-4 text-left text-sm font-semibold">Aksi</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-200">
                            {loading ? (
                                <tr>
                                    <td colSpan="9" className="px-6 py-8 text-center">
                                        <i className="fas fa-spinner fa-spin text-3xl text-[var(--desa-main)] mb-2"></i>
                                        <p className="text-gray-500">Memuat data...</p>
                                    </td>
                                </tr>
                            ) : error ? (
                                <tr>
                                    <td colSpan="9" className="px-6 py-8 text-center text-red-500">
                                        <i className="fas fa-exclamation-triangle text-3xl mb-2 block"></i>
                                        {error}
                                    </td>
                                </tr>
                            ) : data.length > 0 ? (
                                data.map((item, idx) => (
                                    <tr key={item.id} className="hover:bg-gray-50 transition">
                                        <td className="px-6 py-4 text-sm text-gray-700">{(currentPage - 1) * itemsPerPage + idx + 1}</td>
                                        <td className="px-6 py-4 text-sm font-medium text-gray-900">{item.nama}</td>
                                        <td className="px-6 py-4 text-sm">
                                            <a
                                                href={`https://wa.me/${item.telepon.replace(/^0/, '62').replace(/\D/g, '')}`}
                                                target="_blank"
                                                rel="noopener noreferrer"
                                                className="text-[var(--desa-main)] hover:text-green-700 hover:underline flex items-center gap-1"
                                                title="Hubungi via WhatsApp"
                                            >
                                                <i className="fab fa-whatsapp"></i>
                                                {item.telepon}
                                            </a>
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className="px-3 py-1 bg-green-100 text-green-800 rounded-full text-xs font-semibold capitalize">
                                                {item.kategori}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-700 max-w-xs">
                                            <span title={item.judul}>{truncateText(item.judul, 40)}</span>
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-700">
                                            <i className="fas fa-calendar mr-2 text-gray-400"></i>
                                            {formatDate(item.tanggal_laporan)}
                                        </td>
                                        <td className="px-6 py-4 text-center">
                                            <i className={`fas ${getPriorityBadge(item.prioritas).icon} ${getPriorityBadge(item.prioritas).color} text-lg`} title={item.prioritas}></i>
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
                                                    <option value="ditinjau">Ditinjau</option>
                                                    <option value="diproses">Diproses</option>
                                                    <option value="selesai">Selesai</option>
                                                    <option value="ditolak">Ditolak</option>
                                                </select>
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan="9" className="px-6 py-8 text-center text-gray-500">
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

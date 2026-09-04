import React, { useState, useEffect } from "react";
import { getSuratStats, getAllSurat } from "../../services/suratService";
import { getPengaduanStats, getAllPengaduan } from "../../services/pengaduanService";
import * as XLSX from 'xlsx';

export default function DashboardBeranda() {
    const [suratStats, setSuratStats] = useState(null);
    const [pengaduanStats, setPengaduanStats] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchStats();
    }, []);

    const fetchStats = async () => {
        setLoading(true);
        try {
            const [suratData, pengaduanData] = await Promise.all([
                getSuratStats(),
                getPengaduanStats()
            ]);

            if (!suratData.error) {
                setSuratStats(suratData.data);
            }

            if (!pengaduanData.error) {
                setPengaduanStats(pengaduanData.data);
            }
        } catch (error) {
            console.error("Error fetching stats:", error);
        } finally {
            setLoading(false);
        }
    };

    const handleExportSurat = async () => {
        try {
            const confirmed = window.confirm('Apakah Anda yakin ingin mengekspor data Pengajuan Surat ke Excel?');
            if (!confirmed) return;

            // Fetch all surat data without pagination
            const { data: suratData } = await getAllSurat({}, 1, 10000);

            if (!suratData || suratData.length === 0) {
                alert('⚠️ Tidak ada data Pengajuan Surat untuk diekspor.');
                return;
            }

            // Prepare Surat data for Excel
            const suratExcelData = suratData.map((item, index) => ({
                'No': index + 1,
                'Nama Pengaju': item.nama,
                'Nomor Telepon': item.nomor_telepon,
                'Jenis Surat': item.jenis_surat,
                'Nama Usaha': item.nama_usaha || '-',
                'Alamat Tujuan': item.alamat_tujuan || '-',
                'Jenis KK': item.jenis_kk || '-',
                'Status': item.status,
                'Tanggal Pengajuan': new Date(item.tanggal_pengajuan).toLocaleDateString('id-ID')
            }));

            // Create workbook
            const wb = XLSX.utils.book_new();
            const ws = XLSX.utils.json_to_sheet(suratExcelData);
            XLSX.utils.book_append_sheet(wb, ws, 'Pengajuan Surat');

            // Generate filename with current date
            const date = new Date().toISOString().split('T')[0];
            const filename = `Pengajuan_Surat_${date}.xlsx`;

            // Save file
            XLSX.writeFile(wb, filename);

            alert(`✅ Data Pengajuan Surat berhasil diekspor! (${suratData.length} data)`);
        } catch (error) {
            console.error('Error exporting Surat to Excel:', error);
            alert('❌ Gagal mengekspor data. Silakan coba lagi.');
        }
    };

    const handleExportPengaduan = async () => {
        try {
            const confirmed = window.confirm('Apakah Anda yakin ingin mengekspor data Laporan Pengaduan ke Excel?');
            if (!confirmed) return;

            // Fetch all pengaduan data without pagination
            const { data: pengaduanData } = await getAllPengaduan({}, 1, 10000);

            if (!pengaduanData || pengaduanData.length === 0) {
                alert('⚠️ Tidak ada data Laporan Pengaduan untuk diekspor.');
                return;
            }

            // Prepare Pengaduan data for Excel
            const pengaduanExcelData = pengaduanData.map((item, index) => ({
                'No': index + 1,
                'Nama Pelapor': item.nama,
                'NIK': item.nik || '-',
                'Telepon': item.telepon,
                'Email': item.email || '-',
                'Kategori': item.kategori,
                'Judul': item.judul,
                'Deskripsi': item.deskripsi,
                'Lokasi': item.lokasi || '-',
                'Status': item.status,
                'Prioritas': item.prioritas,
                'Tanggal Laporan': new Date(item.tanggal_laporan).toLocaleDateString('id-ID'),
                'Tanggapan Admin': item.tanggapan_admin || '-'
            }));

            // Create workbook
            const wb = XLSX.utils.book_new();
            const ws = XLSX.utils.json_to_sheet(pengaduanExcelData);
            XLSX.utils.book_append_sheet(wb, ws, 'Laporan Pengaduan');

            // Generate filename with current date
            const date = new Date().toISOString().split('T')[0];
            const filename = `Laporan_Pengaduan_${date}.xlsx`;

            // Save file
            XLSX.writeFile(wb, filename);

            alert(`✅ Data Laporan Pengaduan berhasil diekspor! (${pengaduanData.length} data)`);
        } catch (error) {
            console.error('Error exporting Pengaduan to Excel:', error);
            alert('❌ Gagal mengekspor data. Silakan coba lagi.');
        }
    };

    const stats = [
        {
            title: "Total Pengajuan Surat",
            value: loading ? "..." : (suratStats?.total || 0),
            icon: "fa-file-alt",
            color: "green",
            details: loading ? [] : [
                { label: "Pending", value: suratStats?.pending || 0, color: "yellow" },
                { label: "Diproses", value: suratStats?.diproses || 0, color: "blue" },
                { label: "Selesai", value: suratStats?.selesai || 0, color: "green" },
                { label: "Ditolak", value: suratStats?.ditolak || 0, color: "red" }
            ]
        },
        {
            title: "Total Laporan Pengaduan",
            value: loading ? "..." : (pengaduanStats?.total || 0),
            icon: "fa-comments",
            color: "green",
            details: loading ? [] : [
                { label: "Pending", value: pengaduanStats?.byStatus?.pending || 0, color: "yellow" },
                { label: "Ditinjau", value: pengaduanStats?.byStatus?.ditinjau || 0, color: "blue" },
                { label: "Diproses", value: pengaduanStats?.byStatus?.diproses || 0, color: "purple" },
                { label: "Selesai", value: pengaduanStats?.byStatus?.selesai || 0, color: "green" }
            ]
        },
        {
            title: "Pengaduan Prioritas Tinggi",
            value: loading ? "..." : (pengaduanStats?.byPrioritas?.tinggi || 0),
            icon: "fa-exclamation-triangle",
            color: "red",
        },
        {
            title: "Total Pengajuan",
            value: loading ? "..." : ((suratStats?.total || 0) + (pengaduanStats?.total || 0)),
            icon: "fa-clipboard-list",
            color: "orange",
            details: loading ? [] : [
                { label: "Pengajuan Surat", value: suratStats?.total || 0, color: "blue" },
                { label: "Laporan Pengaduan", value: pengaduanStats?.total || 0, color: "purple" }
            ]
        }
    ];

    const getColorClasses = (color) => {
        const colors = {
            green: "bg-[var(--desa-main)] text-white",
            red: "bg-red-500 text-white",
            orange: "bg-orange-500 text-white",
            yellow: "bg-yellow-500 text-white",
            blue: "bg-blue-500 text-white",
            purple: "bg-purple-500 text-white"
        };
        return colors[color] || colors.green;
    };

    const getDetailColorClasses = (color) => {
        const colors = {
            yellow: "bg-yellow-100 text-yellow-800",
            green: "bg-green-100 text-green-800",
            blue: "bg-blue-100 text-blue-800",
            purple: "bg-purple-100 text-purple-800",
            red: "bg-red-100 text-red-800"
        };
        return colors[color] || colors.green;
    };

    return (
        <div className="space-y-6">

            {/* Header */}
            <div className="bg-gradient-to-r from-[var(--desa-main)] to-green-700 text-white p-6 rounded-xl shadow-lg">
                <h1 className="text-3xl font-bold mb-2">
                    <i className="fas fa-home mr-3"></i>
                    Dashboard Beranda
                </h1>
                <p className="text-green-100">Selamat datang di Admin Panel Desa Legok</p>
            </div>

            {/* Statistics Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {stats.map((stat, idx) => (
                    <div key={idx} className="bg-white rounded-xl shadow-md hover:shadow-lg transition p-6">
                        <div className="flex items-start justify-between mb-4">
                            <div className={`p-3 rounded-lg ${getColorClasses(stat.color)}`}>
                                <i className={`fas ${stat.icon} text-2xl`}></i>
                            </div>
                        </div>
                        <h3 className="text-gray-600 text-sm font-medium mb-2">{stat.title}</h3>
                        <p className="text-3xl font-bold text-gray-800 mb-1">{stat.value}</p>
                        {stat.subtitle && (
                            <p className="text-sm text-gray-500 capitalize">{stat.subtitle}</p>
                        )}

                        {stat.details && stat.details.length > 0 && (
                            <div className="space-y-1 pt-3 border-t mt-3">
                                {stat.details.map((detail, i) => (
                                    <div key={i} className="flex justify-between items-center text-sm">
                                        <span className="text-gray-600">{detail.label}</span>
                                        <span className={`font-semibold px-2 py-1 rounded ${getDetailColorClasses(detail.color)}`}>
                                            {detail.value}
                                        </span>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                ))}
            </div>

            {/* Summary Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Pengajuan Surat Summary */}
                <div className="bg-white rounded-xl shadow-md p-6">
                    <h2 className="text-xl font-bold text-gray-800 mb-4 flex items-center gap-2">
                        <i className="fas fa-file-alt text-[var(--desa-main)]"></i>
                        Ringkasan Pengajuan Surat
                    </h2>
                    {loading ? (
                        <div className="text-center py-8">
                            <i className="fas fa-spinner fa-spin text-3xl text-[var(--desa-main)]"></i>
                            <p className="text-gray-500 mt-2">Memuat data...</p>
                        </div>
                    ) : suratStats ? (
                        <div className="space-y-3">
                            <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                                <span className="text-gray-700">Total Pengajuan</span>
                                <span className="font-bold text-2xl text-[var(--desa-main)]">{suratStats.total}</span>
                            </div>
                            <div className="grid grid-cols-2 gap-3">
                                <div className="p-3 bg-yellow-50 rounded-lg text-center">
                                    <p className="text-xs text-gray-600 mb-1">Pending</p>
                                    <p className="text-2xl font-bold text-yellow-600">{suratStats.pending || 0}</p>
                                </div>
                                <div className="p-3 bg-blue-50 rounded-lg text-center">
                                    <p className="text-xs text-gray-600 mb-1">Diproses</p>
                                    <p className="text-2xl font-bold text-blue-600">{suratStats.diproses || 0}</p>
                                </div>
                                <div className="p-3 bg-green-50 rounded-lg text-center">
                                    <p className="text-xs text-gray-600 mb-1">Selesai</p>
                                    <p className="text-2xl font-bold text-green-600">{suratStats.selesai || 0}</p>
                                </div>
                                <div className="p-3 bg-red-50 rounded-lg text-center">
                                    <p className="text-xs text-gray-600 mb-1">Ditolak</p>
                                    <p className="text-2xl font-bold text-red-600">{suratStats.ditolak || 0}</p>
                                </div>
                            </div>
                        </div>
                    ) : (
                        <p className="text-gray-500 text-center py-4">Tidak ada data</p>
                    )}
                </div>

                {/* Laporan Pengaduan Summary */}
                <div className="bg-white rounded-xl shadow-md p-6">
                    <h2 className="text-xl font-bold text-gray-800 mb-4 flex items-center gap-2">
                        <i className="fas fa-comments text-[var(--desa-main)]"></i>
                        Ringkasan Laporan Pengaduan
                    </h2>
                    {loading ? (
                        <div className="text-center py-8">
                            <i className="fas fa-spinner fa-spin text-3xl text-[var(--desa-main)]"></i>
                            <p className="text-gray-500 mt-2">Memuat data...</p>
                        </div>
                    ) : pengaduanStats ? (
                        <div className="space-y-3">
                            <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                                <span className="text-gray-700">Total Pengaduan</span>
                                <span className="font-bold text-2xl text-[var(--desa-main)]">{pengaduanStats.total}</span>
                            </div>
                            <div className="space-y-2">
                                <div className="flex justify-between items-center p-2 bg-yellow-50 rounded">
                                    <span className="text-sm text-gray-700">Pending</span>
                                    <span className="font-bold text-yellow-600">{pengaduanStats.byStatus?.pending || 0}</span>
                                </div>
                                <div className="flex justify-between items-center p-2 bg-blue-50 rounded">
                                    <span className="text-sm text-gray-700">Ditinjau</span>
                                    <span className="font-bold text-blue-600">{pengaduanStats.byStatus?.ditinjau || 0}</span>
                                </div>
                                <div className="flex justify-between items-center p-2 bg-purple-50 rounded">
                                    <span className="text-sm text-gray-700">Diproses</span>
                                    <span className="font-bold text-purple-600">{pengaduanStats.byStatus?.diproses || 0}</span>
                                </div>
                                <div className="flex justify-between items-center p-2 bg-green-50 rounded">
                                    <span className="text-sm text-gray-700">Selesai</span>
                                    <span className="font-bold text-green-600">{pengaduanStats.byStatus?.selesai || 0}</span>
                                </div>
                            </div>

                            {/* Priority Stats */}
                            <div className="pt-3 border-t">
                                <p className="text-sm font-medium text-gray-600 mb-2">Berdasarkan Prioritas:</p>
                                <div className="grid grid-cols-3 gap-2">
                                    <div className="text-center p-2 bg-red-50 rounded">
                                        <p className="text-xs text-gray-600">Tinggi</p>
                                        <p className="font-bold text-red-600">{pengaduanStats.byPrioritas?.tinggi || 0}</p>
                                    </div>
                                    <div className="text-center p-2 bg-orange-50 rounded">
                                        <p className="text-xs text-gray-600">Sedang</p>
                                        <p className="font-bold text-orange-600">{pengaduanStats.byPrioritas?.sedang || 0}</p>
                                    </div>
                                    <div className="text-center p-2 bg-green-50 rounded">
                                        <p className="text-xs text-gray-600">Rendah</p>
                                        <p className="font-bold text-green-600">{pengaduanStats.byPrioritas?.rendah || 0}</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    ) : (
                        <p className="text-gray-500 text-center py-4">Tidak ada data</p>
                    )}
                </div>
            </div>

            {/* Quick Actions */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <button
                    onClick={() => fetchStats()}
                    className="bg-[var(--desa-main)] hover:bg-green-700 text-white p-4 rounded-xl shadow-md transition flex items-center justify-center gap-3"
                >
                    <i className="fas fa-sync-alt text-2xl"></i>
                    <span className="font-semibold">Refresh Data</span>
                </button>
                <button
                    onClick={handleExportSurat}
                    className="bg-blue-600 hover:bg-blue-700 text-white p-4 rounded-xl shadow-md transition flex items-center justify-center gap-3"
                >
                    <i className="fas fa-file-excel text-2xl"></i>
                    <span className="font-semibold">Export Pengajuan Surat</span>
                </button>
                <button
                    onClick={handleExportPengaduan}
                    className="bg-purple-600 hover:bg-purple-700 text-white p-4 rounded-xl shadow-md transition flex items-center justify-center gap-3"
                >
                    <i className="fas fa-file-excel text-2xl"></i>
                    <span className="font-semibold">Export Laporan Pengaduan</span>
                </button>
            </div>
        </div>
    );
}

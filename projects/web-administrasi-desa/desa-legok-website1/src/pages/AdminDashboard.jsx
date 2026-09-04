import React, { useState } from "react";
import AdminSidebar from "../components/admin/AdminSidebar";
import DashboardBeranda from "../components/admin/DashboardBeranda";
import TabelPengajuanSurat from "../components/admin/TabelPengajuanSurat";
import TabelLaporanPengaduan from "../components/admin/TabelLaporanPengaduan";

export default function AdminDashboard() {
    const [activeSection, setActiveSection] = useState("beranda");

    return (
        <div className="flex h-screen overflow-hidden bg-gray-100">
            {/* Sidebar - Fixed */}
            <div className="flex-shrink-0">
                <AdminSidebar activeSection={activeSection} setActiveSection={setActiveSection} />
            </div>

            {/* Main Content - Scrollable */}
            <div className="flex-1 overflow-y-auto">
                <div className="p-8">
                    {activeSection === "beranda" && <DashboardBeranda />}
                    {activeSection === "pengajuan" && <TabelPengajuanSurat />}
                    {activeSection === "pengaduan" && <TabelLaporanPengaduan />}
                </div>
            </div>
        </div>
    );
}

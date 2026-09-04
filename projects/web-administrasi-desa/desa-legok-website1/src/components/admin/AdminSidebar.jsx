import React from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../contexts/AuthContext";

export default function AdminSidebar({ activeSection, setActiveSection }) {
    const navigate = useNavigate();
    const { user, logout } = useAuth();

    const menuItems = [
        { id: "beranda", label: "Beranda", icon: "fa-home" },
        { id: "pengajuan", label: "Pengajuan Surat", icon: "fa-file-alt" },
        { id: "pengaduan", label: "Laporan Pengaduan", icon: "fa-comments" }
    ];

    const handleLogout = async () => {
        if (window.confirm("Apakah Anda yakin ingin logout?")) {
            await logout();
            navigate("/admin/login");
        }
    };

    return (
        <aside className="bg-gradient-to-b from-[var(--desa-main)] to-green-800 text-white w-64 h-screen flex flex-col overflow-hidden">

            {/* Header */}
            <div className="p-6 flex-shrink-0">
                <div className="flex items-center gap-3 mb-2">
                    <div className="bg-white p-2 rounded-lg">
                        <i className="fas fa-user-shield text-[var(--desa-main)] text-2xl"></i>
                    </div>
                    <div>
                        <h2 className="font-bold text-lg">Admin Panel</h2>
                        <p className="text-xs text-green-200">Desa Legok</p>
                    </div>
                </div>
                <div className="mt-4 p-3 bg-green-700 rounded-lg">
                    <p className="text-xs text-green-200">Logged in as:</p>
                    <p className="font-semibold text-sm truncate" title={user?.email}>
                        <i className="fas fa-user-circle mr-2"></i>
                        {user?.email || "Admin"}
                    </p>
                </div>
            </div>

            {/* Navigation Menu - Scrollable if needed */}
            <nav className="flex-1 overflow-y-auto px-6 py-4">
                <ul className="space-y-2">
                    {menuItems.map((item) => (
                        <li key={item.id}>
                            <button
                                onClick={() => setActiveSection(item.id)}
                                className={`w-full text-left px-4 py-3 rounded-lg transition flex items-center gap-3 ${activeSection === item.id
                                    ? "bg-white text-[var(--desa-main)] font-semibold shadow-lg"
                                    : "hover:bg-green-700 text-green-100"
                                    }`}
                            >
                                <i className={`fas ${item.icon} text-lg`}></i>
                                <span>{item.label}</span>
                            </button>
                        </li>
                    ))}
                </ul>
            </nav>

            {/* Logout Button */}
            <div className="flex-shrink-0 px-6 py-4 border-t border-green-700">
                <button
                    onClick={handleLogout}
                    className="w-full px-4 py-3 bg-red-600 hover:bg-red-700 rounded-lg transition flex items-center justify-center gap-2 font-semibold"
                >
                    <i className="fas fa-sign-out-alt"></i>
                    Logout
                </button>
            </div>
        </aside>
    );
}

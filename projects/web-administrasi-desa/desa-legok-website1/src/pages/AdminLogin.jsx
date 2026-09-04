import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";
import kantor from "../assets/images/kantor.jpg";

export default function AdminLogin() {
    const [credentials, setCredentials] = useState({ email: "", password: "" });
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();
    const { login, isAuthenticated } = useAuth();

    // Check if already logged in
    useEffect(() => {
        if (isAuthenticated) {
            navigate("/admin");
        }
    }, [isAuthenticated, navigate]);

    const handleChange = (e) => {
        setCredentials({
            ...credentials,
            [e.target.name]: e.target.value
        });
        setError(""); // Clear error when user types
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError("");

        try {
            const { user, error: loginError } = await login(credentials.email, credentials.password);

            if (loginError) {
                setError(loginError);
                setLoading(false);
            } else if (user) {
                // Successfully logged in, navigate to admin
                navigate("/admin");
            }
        } catch (err) {
            setError("Terjadi kesalahan saat login. Silakan coba lagi.");
            setLoading(false);
        }
    };


    return (
        <div className="min-h-screen flex items-center justify-center relative overflow-hidden px-4">
            {/* Background Image */}
            <div className="absolute inset-0 z-0">
                <img
                    src={kantor}
                    alt="Kantor Desa"
                    className="w-full h-full object-cover"
                />
                {/* Green Overlay */}
                <div className="absolute inset-0 bg-[var(--desa-main)] opacity-70"></div>
            </div>

            <div className="max-w-md w-full relative z-10">

                {/* Login Card */}
                <div className="bg-white rounded-2xl shadow-2xl p-8 relative">
                    {/* Back Button - Top Left */}
                    <button
                        onClick={() => navigate("/")}
                        className="absolute top-4 left-4 text-gray-400 hover:text-[var(--desa-main)] transition-colors p-2 rounded-lg hover:bg-green-50"
                        title="Kembali ke Beranda"
                    >
                        <i className="fas fa-arrow-left text-lg"></i>
                    </button>

                    {/* Logo/Header */}
                    <div className="text-center mb-8">
                        <div className="inline-block p-4 bg-green-50 rounded-full shadow-lg mb-4">
                            <i className="fas fa-user-shield text-5xl text-[var(--desa-main)]"></i>
                        </div>
                        <h1 className="text-3xl font-bold text-gray-800 mb-2">Admin Dashboard</h1>
                        <p className="text-gray-600">Desa Legok</p>
                    </div>

                    <h2 className="text-xl font-bold text-gray-800 mb-6 text-center border-t pt-6">
                        Login Admin
                    </h2>

                    {error && (
                        <div className="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded-lg flex items-center gap-2">
                            <i className="fas fa-exclamation-circle"></i>
                            <span className="text-sm">{error}</span>
                        </div>
                    )}

                    <form onSubmit={handleSubmit} className="space-y-5">
                        {/* Email */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                <i className="fas fa-envelope mr-2"></i>Email
                            </label>
                            <input
                                type="text"
                                name="email"
                                value={credentials.email}
                                onChange={handleChange}
                                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--desa-main)] focus:border-transparent transition"
                                placeholder="Masukkan email"
                                required
                            />
                        </div>

                        {/* Password */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                <i className="fas fa-lock mr-2"></i>Password
                            </label>
                            <input
                                type="password"
                                name="password"
                                value={credentials.password}
                                onChange={handleChange}
                                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--desa-main)] focus:border-transparent transition"
                                placeholder="Masukkan password"
                                required
                            />
                        </div>

                        {/* Submit Button */}
                        <button
                            type="submit"
                            disabled={loading}
                            className="w-full bg-[var(--desa-main)] text-white font-bold py-3 rounded-lg hover:bg-green-700 transition disabled:bg-green-400 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                        >
                            {loading ? (
                                <>
                                    <i className="fas fa-spinner fa-spin"></i>
                                    Memproses...
                                </>
                            ) : (
                                <>
                                    <i className="fas fa-sign-in-alt"></i>
                                    Login
                                </>
                            )}
                        </button>
                    </form>
                </div>

            </div>
        </div>
    );
}

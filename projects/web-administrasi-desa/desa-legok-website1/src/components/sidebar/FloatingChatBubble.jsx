import { useState, useRef, useEffect } from 'react';
import { FaWhatsapp, FaTimes, FaUser, FaPhone, FaPaperPlane, FaComments, FaRobot } from 'react-icons/fa';
import { saveChatMessage } from '../../services/chatService';

// Helper function to format message text
const formatMessage = (text) => {
    if (!text) return null;

    // Split by line breaks
    const lines = text.split('\n');

    return lines.map((line, index) => {
        // Check if line is empty
        if (!line.trim()) {
            return <br key={index} />;
        }

        // Check for numbered list (1. 2. 3. etc)
        const numberedMatch = line.match(/^(\d+)\.\s+(.+)$/);
        if (numberedMatch) {
            return (
                <div key={index} className="flex gap-2 mb-1">
                    <span className="font-semibold flex-shrink-0">{numberedMatch[1]}.</span>
                    <span dangerouslySetInnerHTML={{ __html: formatInlineText(numberedMatch[2]) }} />
                </div>
            );
        }

        // Check for bullet points (- or •)
        const bulletMatch = line.match(/^[-•]\s+(.+)$/);
        if (bulletMatch) {
            return (
                <div key={index} className="flex gap-2 mb-1">
                    <span className="flex-shrink-0">•</span>
                    <span dangerouslySetInnerHTML={{ __html: formatInlineText(bulletMatch[1]) }} />
                </div>
            );
        }

        // Regular line with potential bold text
        return (
            <div key={index} className="mb-1" dangerouslySetInnerHTML={{ __html: formatInlineText(line) }} />
        );
    });
};

// Helper to format inline text (bold, etc)
const formatInlineText = (text) => {
    // Replace **text** with <strong>text</strong>
    return text.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
};

export default function FloatingChatBubble() {
    const [isOpen, setIsOpen] = useState(false);
    const [isVisible, setIsVisible] = useState(true);
    const [isRegistered, setIsRegistered] = useState(false);
    const [isSending, setIsSending] = useState(false);

    // Form state
    const [formData, setFormData] = useState({
        nama: '',
        nomorWA: ''
    });
    const [errors, setErrors] = useState({});

    // Chat state
    const [messages, setMessages] = useState([]);
    const [inputMessage, setInputMessage] = useState('');
    const messagesEndRef = useRef(null);

    // n8n Webhook URL - Using Vite proxy to bypass CORS in development
    // For production, update this to direct URL and configure CORS in n8n
    const N8N_WEBHOOK_URL = 'https://n8n.kitapunya.web.id/webhook/62f54e83-6fe6-4907-bc37-420ce307dbd5/chat';

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    const togglePopup = () => {
        setIsOpen(!isOpen);
        // Reset errors when closing
        if (isOpen) {
            setErrors({});
        }
    };

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
        // Clear error for this field
        if (errors[name]) {
            setErrors(prev => ({
                ...prev,
                [name]: ''
            }));
        }
    };

    const validateForm = () => {
        const newErrors = {};

        if (!formData.nama.trim()) {
            newErrors.nama = 'Nama harus diisi';
        } else if (formData.nama.trim().length < 3) {
            newErrors.nama = 'Nama minimal 3 karakter';
        }

        if (!formData.nomorWA.trim()) {
            newErrors.nomorWA = 'Nomor WhatsApp harus diisi';
        } else if (!/^[0-9]{10,13}$/.test(formData.nomorWA.replace(/\s/g, ''))) {
            newErrors.nomorWA = 'Nomor WhatsApp tidak valid (10-13 digit)';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = (e) => {
        e.preventDefault();

        if (validateForm()) {
            // Save to localStorage
            localStorage.setItem('chatUserData', JSON.stringify(formData));
            setIsRegistered(true);

            // Add welcome message
            setMessages([
                {
                    type: 'bot',
                    text: `Halo ${formData.nama}! Selamat datang di layanan chat Desa Legok. Ada yang bisa saya bantu?`,
                    timestamp: new Date().toISOString()
                }
            ]);
        }
    };

    const sendMessageToN8N = async (message) => {
        try {
            const response = await fetch(N8N_WEBHOOK_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    nama: formData.nama,
                    nomorWA: formData.nomorWA,
                    message: message,
                    timestamp: new Date().toISOString()
                })
            });

            if (!response.ok) {
                throw new Error('Network response was not ok');
            }

            const data = await response.json();
            return data;
        } catch (error) {
            console.error('Error sending message to n8n:', error);
            throw error;
        }
    };

    const handleSendMessage = async (e) => {
        e.preventDefault();

        if (!inputMessage.trim()) return;

        // Add user message to chat
        const userMessage = {
            type: 'user',
            text: inputMessage,
            timestamp: new Date().toISOString()
        };

        setMessages(prev => [...prev, userMessage]);
        const currentMessage = inputMessage;
        setInputMessage('');
        setIsSending(true);

        try {
            // Send to n8n webhook
            const response = await sendMessageToN8N(currentMessage);

            // Debug: Log response dari n8n
            console.log('Response dari n8n:', response);
            console.log('response.message:', response.message);
            console.log('response.reply:', response.reply);

            const botResponseText = response.message || response.reply || response.output || JSON.stringify(response) || 'Terima kasih atas pesan Anda. Admin akan segera merespons.';

            // Add bot response
            const botMessage = {
                type: 'bot',
                text: botResponseText,
                timestamp: new Date().toISOString()
            };

            setMessages(prev => [...prev, botMessage]);

            // Save to Supabase
            try {
                await saveChatMessage({
                    nama: formData.nama,
                    email: null,
                    telepon: formData.nomorWA,
                    pesan: currentMessage,
                    n8n_response: botResponseText
                });
                console.log('Chat message saved to Supabase');
            } catch (dbError) {
                console.error('Error saving to database:', dbError);
                // Don't show error to user, just log it
            }
        } catch (error) {
            // Add error message
            const errorMessage = {
                type: 'bot',
                text: 'Maaf, terjadi kesalahan. Silakan coba lagi nanti atau hubungi admin melalui WhatsApp.',
                timestamp: new Date().toISOString()
            };

            setMessages(prev => [...prev, errorMessage]);
        } finally {
            setIsSending(false);
        }
    };

    const handleQuickReply = async (topic) => {
        const message = `Saya ingin bertanya tentang ${topic}`;
        setInputMessage(message);

        // Automatically send the quick reply
        const userMessage = {
            type: 'user',
            text: message,
            timestamp: new Date().toISOString()
        };

        setMessages(prev => [...prev, userMessage]);
        setIsSending(true);

        try {
            const response = await sendMessageToN8N(message);

            // Debug: Log response dari n8n
            console.log('Quick Reply Response dari n8n:', response);

            const botMessage = {
                type: 'bot',
                text: response.message || response.reply || response.output || `Baik, saya akan membantu Anda dengan ${topic}. Silakan jelaskan lebih detail kebutuhan Anda.`,
                timestamp: new Date().toISOString()
            };

            setMessages(prev => [...prev, botMessage]);
        } catch (error) {
            const errorMessage = {
                type: 'bot',
                text: 'Maaf, terjadi kesalahan. Silakan coba lagi.',
                timestamp: new Date().toISOString()
            };

            setMessages(prev => [...prev, errorMessage]);
        } finally {
            setIsSending(false);
        }
    };

    if (!isVisible) return null;

    return (
        <>
            {/* Floating Bubble Button */}
            <div className="fixed bottom-6 right-6 z-50">
                {/* Popup Chat Box */}
                {isOpen && (
                    <div className="absolute bottom-20 right-0 w-96 bg-white rounded-2xl shadow-2xl overflow-hidden mb-2 animate-fade">
                        {/* Header */}
                        <div className="bg-[var(--desa-main)] text-white p-4 flex items-center justify-between">
                            <div className="flex items-center gap-3">
                                <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center">
                                    <FaRobot className="text-[var(--desa-main)] text-2xl" />
                                </div>
                                <div>
                                    <h4 className="font-bold text-sm">Admin Desa Legok</h4>
                                    <p className="text-xs text-green-100">
                                        {isRegistered ? 'Online' : 'Biasanya membalas dalam 1 jam'}
                                    </p>
                                </div>
                            </div>
                            <button
                                onClick={togglePopup}
                                className="text-white hover:text-green-200 transition"
                            >
                                <FaTimes className="text-xl" />
                            </button>
                        </div>

                        {/* Body */}
                        <div className="flex flex-col h-[500px]">

                            {!isRegistered ? (
                                // Registration Form
                                <div className="p-4 bg-gray-50 overflow-y-auto">
                                    <div className="bg-white rounded-lg p-4 shadow-sm mb-4">
                                        <p className="text-sm text-gray-700 mb-2">
                                            👋 Halo! Selamat datang di layanan Desa Legok.
                                        </p>
                                        <p className="text-xs text-gray-500">
                                            Silakan isi data diri Anda terlebih dahulu untuk melanjutkan.
                                        </p>
                                    </div>

                                    <form onSubmit={handleSubmit} className="space-y-4">
                                        {/* Nama Input */}
                                        <div>
                                            <label className="block text-xs font-semibold text-gray-700 mb-2">
                                                <FaUser className="inline mr-1" /> Nama Lengkap
                                            </label>
                                            <input
                                                type="text"
                                                name="nama"
                                                value={formData.nama}
                                                onChange={handleInputChange}
                                                placeholder="Masukkan nama lengkap"
                                                className={`w-full px-4 py-2.5 rounded-lg border ${errors.nama ? 'border-red-500' : 'border-gray-300'
                                                    } focus:outline-none focus:ring-2 focus:ring-[var(--desa-main)] text-sm`}
                                            />
                                            {errors.nama && (
                                                <p className="text-xs text-red-500 mt-1">{errors.nama}</p>
                                            )}
                                        </div>

                                        {/* Nomor WA Input */}
                                        <div>
                                            <label className="block text-xs font-semibold text-gray-700 mb-2">
                                                <FaPhone className="inline mr-1" /> Nomor WhatsApp
                                            </label>
                                            <input
                                                type="tel"
                                                name="nomorWA"
                                                value={formData.nomorWA}
                                                onChange={handleInputChange}
                                                placeholder="08xxxxxxxxxx"
                                                className={`w-full px-4 py-2.5 rounded-lg border ${errors.nomorWA ? 'border-red-500' : 'border-gray-300'
                                                    } focus:outline-none focus:ring-2 focus:ring-[var(--desa-main)] text-sm`}
                                            />
                                            {errors.nomorWA && (
                                                <p className="text-xs text-red-500 mt-1">{errors.nomorWA}</p>
                                            )}
                                            <p className="text-xs text-gray-500 mt-1">
                                                Contoh: 081234567890
                                            </p>
                                        </div>

                                        {/* Submit Button */}
                                        <button
                                            type="submit"
                                            className="w-full bg-[var(--desa-main)] hover:bg-green-800 text-white font-bold py-3 rounded-xl flex items-center justify-center gap-2 transition shadow-md"
                                        >
                                            Mulai Chat
                                        </button>
                                    </form>
                                </div>
                            ) : (
                                // Chat Interface
                                <>
                                    {/* Messages Area */}
                                    <div className="flex-1 p-4 bg-gray-50 overflow-y-auto">
                                        {messages.length === 0 ? (
                                            // Quick Replies (shown when no messages)
                                            <div className="space-y-2">
                                                <p className="text-xs font-semibold text-gray-600 mb-3">Pilih topik atau ketik pesan Anda:</p>
                                                <button
                                                    onClick={() => handleQuickReply('Pengajuan Surat')}
                                                    className="w-full text-left text-xs bg-white hover:bg-gray-100 p-3 rounded-lg border border-gray-200 transition"
                                                    disabled={isSending}
                                                >
                                                    📄 Pengajuan Surat
                                                </button>
                                                <button
                                                    onClick={() => handleQuickReply('Laporan Pengaduan')}
                                                    className="w-full text-left text-xs bg-white hover:bg-gray-100 p-3 rounded-lg border border-gray-200 transition"
                                                    disabled={isSending}
                                                >
                                                    📢 Laporan Pengaduan
                                                </button>
                                                <button
                                                    onClick={() => handleQuickReply('Informasi Umum')}
                                                    className="w-full text-left text-xs bg-white hover:bg-gray-100 p-3 rounded-lg border border-gray-200 transition"
                                                    disabled={isSending}
                                                >
                                                    ℹ️ Informasi Umum
                                                </button>
                                            </div>
                                        ) : (
                                            // Chat Messages
                                            <div className="space-y-3">
                                                {messages.map((msg, index) => (
                                                    <div
                                                        key={index}
                                                        className={`flex ${msg.type === 'user' ? 'justify-end' : 'justify-start'}`}
                                                    >
                                                        <div
                                                            className={`max-w-[85%] rounded-lg p-3 ${msg.type === 'user'
                                                                ? 'bg-[var(--desa-main)] text-white'
                                                                : 'bg-white text-gray-800 border border-gray-200'
                                                                }`}
                                                        >
                                                            <div className="text-sm">
                                                                {formatMessage(msg.text)}
                                                            </div>
                                                            <p className={`text-xs mt-2 ${msg.type === 'user' ? 'text-green-100' : 'text-gray-500'
                                                                }`}>
                                                                {new Date(msg.timestamp).toLocaleTimeString('id-ID', {
                                                                    hour: '2-digit',
                                                                    minute: '2-digit'
                                                                })}
                                                            </p>
                                                        </div>
                                                    </div>
                                                ))}
                                                {isSending && (
                                                    <div className="flex justify-start">
                                                        <div className="bg-white text-gray-800 border border-gray-200 rounded-lg p-3">
                                                            <div className="flex gap-1">
                                                                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                                                                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                                                                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                )}
                                                <div ref={messagesEndRef} />
                                            </div>
                                        )}
                                    </div>

                                    {/* Input Area */}
                                    <div className="p-4 bg-white border-t border-gray-200">
                                        <form onSubmit={handleSendMessage} className="flex gap-2">
                                            <input
                                                type="text"
                                                value={inputMessage}
                                                onChange={(e) => setInputMessage(e.target.value)}
                                                placeholder="Ketik pesan Anda..."
                                                disabled={isSending}
                                                className="flex-1 px-4 py-2.5 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-[var(--desa-main)] text-sm"
                                            />
                                            <button
                                                type="submit"
                                                disabled={isSending || !inputMessage.trim()}
                                                className="bg-[var(--desa-main)] hover:bg-green-800 text-white p-2.5 rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed"
                                            >
                                                <FaPaperPlane className="text-lg" />
                                            </button>
                                        </form>
                                        <p className="text-xs text-gray-500 mt-2 text-center">
                                            Powered by n8n Workflow
                                        </p>
                                    </div>
                                </>
                            )}
                        </div>
                    </div>
                )}

                {/* Main Bubble Button */}
                <button
                    onClick={togglePopup}
                    className="bg-[var(--desa-main)] hover:bg-green-800 text-white w-16 h-16 rounded-full shadow-2xl flex items-center justify-center transition-all duration-300 hover:scale-110 group relative"
                    aria-label="Chat Admin"
                >
                    {isOpen ? (
                        <FaTimes className="text-3xl" />
                    ) : (
                        <FaComments className="text-3xl animate-pulse" />
                    )}

                    {/* Notification Badge */}
                    {!isOpen && (
                        <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs w-5 h-5 rounded-full flex items-center justify-center font-bold">
                            1
                        </span>
                    )}

                    {/* Tooltip */}
                    {!isOpen && (
                        <span className="absolute right-full mr-3 bg-gray-800 text-white text-xs px-3 py-2 rounded-lg whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity">
                            Ada yang bisa kami bantu?
                        </span>
                    )}
                </button>

                {/* Ripple Effect */}
                {!isOpen && (
                    <div className="absolute inset-0 rounded-full bg-[var(--desa-main)] opacity-20 animate-ping pointer-events-none"></div>
                )}
            </div>
        </>
    );
}

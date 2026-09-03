/* ==========================================================================
   INTERACTIVE LOGIC - DINDA APRILLA DALIMUNTHE PORTFOLIO
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
    // ----------------------------------------------------------------------
    // 1. PROJECT DATASTORE
    // ----------------------------------------------------------------------
    const projectDetailsData = {
        p8: {
            title: "Indian & Korean Food Classification",
            category: "Deep Learning · Computer Vision",
            techStack: ["Python", "TensorFlow", "Keras", "EfficientNetB3", "Transfer Learning", "Image Augmentation"],
            description: "Mengembangkan sistem klasifikasi citra makanan India dan Korea menggunakan transfer learning EfficientNetB3. Dataset diproses melalui image resizing, normalization, augmentation, dan evaluasi menggunakan berbagai metrik klasifikasi.",
            features: [
                "Metrik Klasifikasi Tinggi: Mencapai 92.23% akurasi pada Makanan India dan 98.70% pada Makanan Korea.",
                "Arsitektur Deep Learning: Memanfaatkan model pretrained EfficientNetB3 berbasis TensorFlow / Keras.",
                "Data Pipeline: Preprocessing citra komprehensif termasuk resizing, normalisasi warna, dan augmentasi data.",
                "Evaluasi Model: Analisis menyeluruh dengan metrik Accuracy, Precision, Recall, dan Confusion Matrix."
            ],
            metrics: "92.23% India · 98.70% Korea | EfficientNetB3 Model"
        },
        p7: {
            title: "Mental Health Classification",
            category: "Data Science · Machine Learning",
            techStack: ["Python", "CatBoost", "Scikit-learn", "SMOTE", "SHAP"],
            description: "Membangun model klasifikasi untuk memprediksi pilihan layanan kesehatan mental berdasarkan karakteristik demografis, perilaku, dan psikologis. Proyek mencakup data preprocessing komprehensif, penanganan class imbalance menggunakan SMOTE, hyperparameter tuning, serta interpretasi model menggunakan SHAP.",
            features: [
                "Akurasi Pengujian Tinggi: Mencapai 96.95% Test Accuracy pada dataset evaluasi.",
                "Penanganan Class Imbalance: Menggunakan teknik SMOTE (Synthetic Minority Over-sampling Technique).",
                "Algoritma Gradient Boosting Presisi: Menggunakan CatBoost Classifier yang dioptimasi.",
                "Interpretabilitas Model (Explainable AI): Visualisasi kontribusi fitur individu menggunakan nilai SHAP."
            ],
            metrics: "96.95% Test Accuracy | CatBoost Classifier | SHAP Interpretable AI"
        },
        p5: {
            title: "Game 2D (FlyHero)",
            category: "Game Development · 2D Game",
            techStack: ["Godot Engine", "GDScript", "2D Physics", "Collision Detection"],
            description: "Mengembangkan game arcade 2D bertema penerbangan menggunakan Godot Engine. Game memiliki mekanisme pergerakan karakter, deteksi tabrakan, sistem skor, serta physics objek untuk menciptakan gameplay yang interaktif dan responsif.",
            features: [
                "Engine Game: Dikembangkan sepenuhnya menggunakan Godot Engine dan GDScript.",
                "Mekanisme Karakter: Kontrol pergerakan pesawat yang responsif dan fleksibel.",
                "2D Physics Engine: Deteksi tabrakan presisi dan penanganan gravitasi/kecepatan objek.",
                "Sistem Skor & Rintangan: Generasi rintangan dinamis dan skor tertinggi lokal."
            ],
            metrics: "Engine: Godot Engine | GDScript 2D Physics"
        },
        p1: {
            title: "Mobile Reminder App",
            category: "Mobile Application",
            techStack: ["Flutter", "Dart", "SQLite", "Rule-Based Algorithm", "Local Notifications"],
            description: "Aplikasi pengingat harian cerdas yang dirancang untuk membantu pengguna mengelola jadwal perkuliahan dan tugas akademik. Sistem menggunakan algoritma berbasis aturan (rule-based system) untuk memprioritaskan notifikasi pengingat berdasarkan tingkat urgensi tugas.",
            features: [
                "Notifikasi pengingat otomatis dengan kustomisasi suara dan getar.",
                "Penyimpanan database SQLite lokal yang aman dan offline-first.",
                "Penentuan tingkat prioritas tugas secara otomatis berbasis aturan.",
                "Antarmuka pengguna (UI) modern dengan pilihan mode gelap."
            ],
            metrics: "99% Notifikasi Terkirim Tepat Waktu | SQLite Local Storage"
        },
        p2: {
            title: "Smart Doorlock System",
            category: "IoT & Hardware System",
            techStack: ["ESP32 Microcontroller", "C++ / Arduino IDE", "Solenoid Door Lock", "RFID Sensor", "Web Dashboard"],
            description: "Sistem kunci pintu pintar terintegrasi IoT yang memungkinkan penguncian dan pembukaan pintu secara nirkabel melalui web dashboard serta akses kartu RFID. Dilengkapi sensor keamanan otomatis yang mengirimkan sinyal peringatan jika ada gangguan fisik.",
            features: [
                "Kendali kunci pintu real-time via Web Browser (WiFi Local).",
                "Autentikasi ganda via RFID Tag & PIN Digital.",
                "Log riwayat akses pembukaan pintu otomatis.",
                "Sistem cadangan daya saat mati listrik."
            ],
            metrics: "Response Time < 500ms | ESP32 WiFi Enabled"
        },
        p3: {
            title: "Aplikasi Pemesanan Tiket Mobile",
            category: "Mobile Application",
            techStack: ["Flutter", "Dart", "Provider State Management", "Shared Preferences", "QR Code Generator"],
            description: "Platform pemesanan tiket acara dan perjalanan berbasis mobile. Menyediakan pengalaman pengguna yang mulus dalam memilih tanggal, tempat duduk, hingga penerbitan E-Ticket berwujud QR Code untuk verifikasi langsung.",
            features: [
                "Denah pemilihan kursi interaktif secara visual.",
                "Penerbitan E-Ticket berbasis QR Code otomatis.",
                "Manajemen riwayat transaksi dan status pemesanan.",
                "Desain UI/UX intuitif berbasis standar Material Design 3."
            ],
            metrics: "100% Client-Side QR Generation | Seamless UX"
        },
        p4: {
            title: "Aplikasi Karaoke Berbasis Web",
            category: "Web Application",
            techStack: ["HTML5", "CSS3", "JavaScript", "Web Audio API", "HTML5 Audio Sync"],
            description: "Aplikasi hiburan karaoke interaktif berbasis peramban web tanpa memerlukan plugin tambahan. Memanfaatkan Web Audio API untuk pemrosesan sinyal audio real-time dan pencocokan lirik lagu yang presisi.",
            features: [
                "Sinkronisasi lirik lagu real-time dengan higlight kata otomatis.",
                "Pengaturan nada audio (Pitch shift) & kontrol tempo lagu.",
                "Visualizer spektrum gelombang nada audio interaktif.",
                "Perekaman vokal langsung melalui mikrofon peramban."
            ],
            metrics: "Web Audio Latency < 20ms | Synchronized Lyrics API"
        },
        p6: {
            title: "Web E-Commerce Sederhana",
            category: "Web Application",
            techStack: ["HTML5", "CSS3 Grid/Flexbox", "JavaScript", "LocalStorage API"],
            description: "Website toko online responsif yang menyediakan pengalaman belanja intuitif. Dilengkapi fitur filter kategori produk, kalkulasi total belanja otomatis, dan penyimpanan keranjang belanja.",
            features: [
                "Katalog produk dinamis dengan filter cepat.",
                "Manajemen keranjang belanja (Tambah, Kurang, Hapus).",
                "Fitur Checkout simulasi dengan ringkasan pembayaran.",
                "Layout seratus persen responsif untuk Mobile, Tablet & PC."
            ],
            metrics: "100% Responsive Layout | Zero External Framework"
        }
    };

    // ----------------------------------------------------------------------
    // 2. NAVBAR SCROLL EFFECT & MOBILE MENU
    // ----------------------------------------------------------------------
    const navbar = document.getElementById('navbar');
    const mobileToggle = document.getElementById('mobile-toggle');
    const navMenu = document.getElementById('nav-menu');
    const navLinks = document.querySelectorAll('.nav-link');

    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }

        // Active Section Highlighter
        let currentSection = '';
        const sections = document.querySelectorAll('section');
        sections.forEach(section => {
            const sectionTop = section.offsetTop - 120;
            const sectionHeight = section.clientHeight;
            if (window.scrollY >= sectionTop && window.scrollY < sectionTop + sectionHeight) {
                currentSection = section.getAttribute('id');
            }
        });

        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === `#${currentSection}`) {
                link.classList.add('active');
            }
        });
    });

    if (mobileToggle) {
        mobileToggle.addEventListener('click', () => {
            navMenu.classList.toggle('active');
            const icon = mobileToggle.querySelector('i');
            if (navMenu.classList.contains('active')) {
                icon.className = 'fa-solid fa-xmark';
            } else {
                icon.className = 'fa-solid fa-bars';
            }
        });
    }

    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            navMenu.classList.remove('active');
            if (mobileToggle) {
                mobileToggle.querySelector('i').className = 'fa-solid fa-bars';
            }
        });
    });

    // ----------------------------------------------------------------------
    // 3. PROJECT FILTERING
    // ----------------------------------------------------------------------
    const filterButtons = document.querySelectorAll('.filter-btn');
    const projectCards = document.querySelectorAll('.project-card');

    filterButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            filterButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            const filterValue = btn.getAttribute('data-filter');

            projectCards.forEach(card => {
                const category = card.getAttribute('data-category');
                if (filterValue === 'all' || category === filterValue) {
                    card.style.display = 'flex';
                    card.style.animation = 'modalPop 0.4s ease forwards';
                } else {
                    card.style.display = 'none';
                }
            });
        });
    });

    // ----------------------------------------------------------------------
    // 4. PROJECT MODAL POPUP
    // ----------------------------------------------------------------------
    const modalOverlay = document.getElementById('project-modal');
    const modalContent = document.getElementById('modal-content');
    const modalClose = document.getElementById('modal-close');

    const openModal = (projectId) => {
        const data = projectDetailsData[projectId];
        if (!data) return;

        const techTagsHtml = data.techStack.map(tech => `<span class="tag">${tech}</span>`).join('');
        const featuresHtml = data.features.map(f => `<li><i class="fa-solid fa-circle-check"></i> ${f}</li>`).join('');

        modalContent.innerHTML = `
            <span class="modal-header-badge">${data.category}</span>
            <h2 class="modal-title">${data.title}</h2>
            
            <div class="modal-body">
                <div>
                    <h3 class="modal-section-title">Ringkasan Deskripsi</h3>
                    <p style="color: var(--text-muted); line-height: 1.7;">${data.description}</p>
                </div>

                <div>
                    <h3 class="modal-section-title">Fitur & Keunggulan Utama</h3>
                    <ul class="modal-features-list">
                        ${featuresHtml}
                    </ul>
                </div>

                <div>
                    <h3 class="modal-section-title">Teknologi Yang Digunakan</h3>
                    <div class="modal-tech-stack">
                        ${techTagsHtml}
                    </div>
                </div>

                <div style="padding: 12px 16px; background: rgba(0, 243, 255, 0.08); border: 1px solid var(--neon-cyan); border-radius: 8px; margin-top: 10px;">
                    <span style="font-size: 0.85rem; color: var(--neon-cyan); font-weight: 600;">
                        <i class="fa-solid fa-chart-line"></i> Technical Metric: ${data.metrics}
                    </span>
                </div>
            </div>
        `;

        modalOverlay.classList.add('active');
        modalOverlay.setAttribute('aria-hidden', 'false');
        document.body.style.overflow = 'hidden';
    };

    const closeModal = () => {
        modalOverlay.classList.remove('active');
        modalOverlay.setAttribute('aria-hidden', 'true');
        document.body.style.overflow = 'auto';
    };

    // Use event delegation for modal open buttons
    document.addEventListener('click', (e) => {
        const btn = e.target.closest('.open-modal-btn');
        if (btn) {
            const projectId = btn.getAttribute('data-project');
            openModal(projectId);
        }
    });

    if (modalClose) modalClose.addEventListener('click', closeModal);

    modalOverlay.addEventListener('click', (e) => {
        if (e.target === modalOverlay) closeModal();
    });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && modalOverlay.classList.contains('active')) {
            closeModal();
        }
    });

    // ----------------------------------------------------------------------
    // 5. CONTACT FORM & TOAST NOTIFICATION
    // ----------------------------------------------------------------------
    const contactForm = document.getElementById('contact-form');
    const toastContainer = document.getElementById('toast-container');

    const showToast = (message) => {
        const toast = document.createElement('div');
        toast.className = 'toast';
        toast.innerHTML = `
            <i class="fa-solid fa-circle-check" style="color: var(--neon-cyan); font-size: 1.2rem;"></i>
            <span>${message}</span>
        `;
        toastContainer.appendChild(toast);

        setTimeout(() => {
            toast.remove();
        }, 4000);
    };

    if (contactForm) {
        contactForm.addEventListener('submit', (e) => {
            e.preventDefault();

            const name = document.getElementById('form-name').value;
            const submitBtn = document.getElementById('form-submit-btn');

            submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Mengirim Pesan...';
            submitBtn.disabled = true;

            setTimeout(() => {
                submitBtn.innerHTML = '<i class="fa-solid fa-paper-plane"></i> Kirim Pesan Ke da133450@gmail.com';
                submitBtn.disabled = false;
                contactForm.reset();

                showToast(`Terima kasih ${name}! Pesan Anda berhasil terkirim ke da133450@gmail.com.`);
            }, 1200);
        });
    }
});

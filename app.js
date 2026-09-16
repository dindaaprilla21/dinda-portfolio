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
            githubUrl: "https://github.com/dindaaprilla21/dinda-portfolio/tree/main/projects/food-image-classification",
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
            githubUrl: "https://github.com/dindaaprilla21/mental-health-classification",
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
            githubUrl: "https://github.com/dindaaprilla21/dinda-portfolio/tree/main/projects/game-fly-hero",
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
            title: "Reminder AI",
            category: "Mobile Application",
            githubUrl: "https://github.com/dindaaprilla21/dinda-portfolio/tree/main/projects/reminder-ai",
            techStack: ["Flutter", "Dart", "SQLite", "SAW Method", "Rule-Based System", "Android"],
            description: "Mengembangkan aplikasi mobile Reminder AI berbasis Android untuk membantu mahasiswa mengelola tugas dan deadline secara lebih terstruktur. Aplikasi menggunakan metode SAW untuk menentukan prioritas tugas dan Rule-Based System untuk memberikan rekomendasi jadwal belajar. Dilengkapi dengan notifikasi deadline, pengingat harian, kalender, serta mode terang dan gelap.",
            features: [
                "Metode SAW (Simple Additive Weighting): Menghitung dan menentukan tingkat prioritas tugas mahasiswa secara sistematis.",
                "Rule-Based System: Memberikan rekomendasi jadwal belajar yang disesuaikan dengan beban tugas harian.",
                "Manajemen Tugas Lengkap: Dilengkapi notifikasi deadline otomatis, pengingat harian, serta tampilan kalender interaktif.",
                "Tampilan Fleksibel: Dukungan tema terang (Light Mode) dan mode gelap (Dark Mode) yang intuitif."
            ],
            metrics: "SAW Method & Rule-Based System | SQLite Database"
        },
        p3: {
            title: "Aplikasi Pemesanan Tiket Mobile",
            category: "Mobile Application",
            githubUrl: "https://github.com/dindaaprilla21/dinda-portfolio/tree/main/projects/pemesanan-tiket",
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
            githubUrl: "https://github.com/dindaaprilla21/dinda-portfolio/tree/main/projects/web-karaoke",
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
            title: "Web Administrasi Desa Legok",
            category: "Web Application · Digital Public Services",
            githubUrl: "https://github.com/dindaaprilla21/dinda-portfolio/tree/main/projects/web-administrasi-desa",
            techStack: ["React", "Vite", "n8n Workflow (AI Chatbot)", "Supabase Backend DB", "CSS3 / Tailwind"],
            description: "Platform portal pelayanan digital dan administrasi terpadu untuk Desa Legok, Tangerang. Aplikasi memfasilitasi pelayanan mandiri warga (pengajuan surat online SKTM/Domisili, lapor pengaduan aspirasi warga), kabar publikasi desa terbaru, serta integrasi floating AI Chatbot otomatis berbasis n8n workflow dan backend Supabase.",
            features: [
                "Layanan Mandiri Digital: Pengajuan Surat Online (SKTM, Surat Domisili, Surat Pengantar) & Form Lapor Pengaduan Warga.",
                "Floating AI Chatbot (n8n Workflow): Layanan konsultasi & tanya jawab otomatis 24 jam mengenai prosedur administrasi desa.",
                "Backend Supabase: Pengelolaan data pemohon, status persetujuan surat, serta database laporan pengaduan secara real-time.",
                "Portal Informasi Desa: Publikasi Berita Desa terbaru, transparansi anggaran, kontak WhatsApp Admin & jam operasional kantor."
            ],
            metrics: "n8n AI Workflow | Supabase Backend DB | React Vite"
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

                <div style="margin-top: 14px;">
                    <a href="${data.githubUrl}" target="_blank" class="btn btn-neon-sm" style="display: inline-flex; align-items: center; gap: 8px;">
                        <i class="fa-brands fa-github"></i> Buka Repository di GitHub
                    </a>
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
    // 4.1 CV / RESUME MODAL HANDLER
    // ----------------------------------------------------------------------
    const cvModal = document.getElementById('cv-modal');
    const cvModalClose = document.getElementById('cv-modal-close');
    const cvPrintBtn = document.getElementById('cv-print-btn');

    const openCvModal = () => {
        if (!cvModal) return;
        cvModal.classList.add('active');
        cvModal.setAttribute('aria-hidden', 'false');
        document.body.style.overflow = 'hidden';
    };

    const closeCvModal = () => {
        if (!cvModal) return;
        cvModal.classList.remove('active');
        cvModal.setAttribute('aria-hidden', 'true');
        document.body.style.overflow = 'auto';
    };

    document.addEventListener('click', (e) => {
        const cvTrigger = e.target.closest('.open-cv-modal-btn');
        if (cvTrigger) {
            e.preventDefault();
            openCvModal();
        }
    });

    if (cvModalClose) cvModalClose.addEventListener('click', closeCvModal);

    if (cvModal) {
        cvModal.addEventListener('click', (e) => {
            if (e.target === cvModal) closeCvModal();
        });
    }

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && cvModal && cvModal.classList.contains('active')) {
            closeCvModal();
        }
    });

    // CV Language Switcher (Bahasa Indonesia vs English)
    const cvLangBtns = document.querySelectorAll('.cv-lang-btn');
    const cvPdfIframe = document.getElementById('cv-pdf-iframe');
    const cvDownloadBtn = document.getElementById('cv-download-btn');
    const cvDocBadge = document.getElementById('cv-doc-badge');
    const cvFallbackTitle = document.getElementById('cv-fallback-title');
    const cvFallbackDesc = document.getElementById('cv-fallback-desc');
    const cvFallbackDownloadBtn = document.getElementById('cv-fallback-download-btn');

    const switchCvLanguage = (lang) => {
        cvLangBtns.forEach(btn => {
            if (btn.dataset.lang === lang) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });

        if (lang === 'en') {
            if (cvPdfIframe) cvPdfIframe.src = 'assets/CV_Dinda_Aprilla_Dalimunthe_EN.pdf#toolbar=1';
            if (cvDownloadBtn) {
                cvDownloadBtn.href = 'assets/CV_Dinda_Aprilla_Dalimunthe_EN.pdf';
                cvDownloadBtn.setAttribute('download', 'CV_Dinda_Aprilla_Dalimunthe_EN.pdf');
                cvDownloadBtn.innerHTML = '<i class="fa-solid fa-download"></i> Unduh PDF (EN)';
                cvDownloadBtn.title = 'Unduh File PDF CV Versi Bahasa Inggris (93 KB)';
            }
            if (cvDocBadge) {
                cvDocBadge.innerHTML = '<i class="fa-solid fa-file-pdf"></i> Curriculum Vitae (English)';
            }
            if (cvFallbackTitle) cvFallbackTitle.textContent = 'Curriculum Vitae — English Version';
            if (cvFallbackDesc) cvFallbackDesc.textContent = 'Format: Official PDF (93 KB)';
            if (cvFallbackDownloadBtn) {
                cvFallbackDownloadBtn.href = 'assets/CV_Dinda_Aprilla_Dalimunthe_EN.pdf';
                cvFallbackDownloadBtn.setAttribute('download', 'CV_Dinda_Aprilla_Dalimunthe_EN.pdf');
            }
        } else {
            if (cvPdfIframe) cvPdfIframe.src = 'assets/CV_Dinda_Aprilla_Dalimunthe_ID.pdf#toolbar=1';
            if (cvDownloadBtn) {
                cvDownloadBtn.href = 'assets/CV_Dinda_Aprilla_Dalimunthe_ID.pdf';
                cvDownloadBtn.setAttribute('download', 'CV_Dinda_Aprilla_Dalimunthe_ID.pdf');
                cvDownloadBtn.innerHTML = '<i class="fa-solid fa-download"></i> Unduh PDF (ID)';
                cvDownloadBtn.title = 'Unduh File PDF CV Versi Bahasa Indonesia (123 KB)';
            }
            if (cvDocBadge) {
                cvDocBadge.innerHTML = '<i class="fa-solid fa-file-pdf"></i> Curriculum Vitae (Indonesia)';
            }
            if (cvFallbackTitle) cvFallbackTitle.textContent = 'Curriculum Vitae — Versi Bahasa Indonesia';
            if (cvFallbackDesc) cvFallbackDesc.textContent = 'Format: PDF Resmi (123 KB)';
            if (cvFallbackDownloadBtn) {
                cvFallbackDownloadBtn.href = 'assets/CV_Dinda_Aprilla_Dalimunthe_ID.pdf';
                cvFallbackDownloadBtn.setAttribute('download', 'CV_Dinda_Aprilla_Dalimunthe_ID.pdf');
            }
        }
    };

    cvLangBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            switchCvLanguage(btn.dataset.lang);
        });
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
                submitBtn.innerHTML = '<i class="fa-solid fa-paper-plane"></i> Kirim Pesan';
                submitBtn.disabled = false;
                contactForm.reset();

                showToast(`Terima kasih ${name}! Pesan Anda berhasil terkirim.`);
            }, 1200);
        });
    }

    // Copy Email to Clipboard Feature
    const copyEmailBtn = document.getElementById('copy-email-btn');
    if (copyEmailBtn) {
        copyEmailBtn.addEventListener('click', () => {
            navigator.clipboard.writeText('da133450@gmail.com').then(() => {
                showToast('Email da133450@gmail.com berhasil disalin!');
                copyEmailBtn.innerHTML = '<i class="fa-solid fa-check" style="color: #4ade80;"></i>';
                setTimeout(() => {
                    copyEmailBtn.innerHTML = '<i class="fa-regular fa-clone"></i>';
                }, 2000);
            }).catch(() => {
                showToast('Email: da133450@gmail.com');
            });
        });
    }

    // ----------------------------------------------------------------------
    // 6. GITHUB API - LIVE STATS (dindaaprilla21)
    // ----------------------------------------------------------------------
    (async () => {
        try {
            const res = await fetch('https://api.github.com/users/dindaaprilla21');
            if (res.ok) {
                const data = await res.json();
                const reposEl = document.getElementById('gh-repos');
                const followersEl = document.getElementById('gh-followers');
                const followingEl = document.getElementById('gh-following');
                if (reposEl && data.public_repos !== undefined) reposEl.textContent = data.public_repos;
                if (followersEl && data.followers !== undefined) followersEl.textContent = data.followers;
                if (followingEl && data.following !== undefined) followingEl.textContent = data.following;
            }
        } catch (e) {
            // Silently fallback to static defaults
        }
    })();

    // ----------------------------------------------------------------------
    // 7. PROFILE PHOTO INTERACTIVE 3D TILT EFFECT
    // ----------------------------------------------------------------------
    const profileTiltWrapper = document.getElementById('profile-tilt-wrapper');
    const profileCard = document.getElementById('profile-card');

    if (profileTiltWrapper && profileCard) {
        let isHovered = false;

        profileTiltWrapper.addEventListener('mouseenter', () => {
            isHovered = true;
            profileCard.style.animation = 'none';
            profileCard.style.transition = 'transform 0.12s ease-out, box-shadow 0.3s ease, border-color 0.3s ease';
        });

        profileTiltWrapper.addEventListener('mousemove', (e) => {
            if (!isHovered) return;
            const rect = profileTiltWrapper.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;

            // Maximum tilt angle of 10 degrees
            const rotateX = ((y - centerY) / centerY) * -9;
            const rotateY = ((x - centerX) / centerX) * 9;

            profileCard.style.transform = `perspective(900px) rotateX(${rotateX.toFixed(2)}deg) rotateY(${rotateY.toFixed(2)}deg) scale3d(1.025, 1.025, 1.025)`;
        });

        profileTiltWrapper.addEventListener('mouseleave', () => {
            isHovered = false;
            profileCard.style.transition = 'transform 0.6s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.4s ease, border-color 0.4s ease';
            profileCard.style.transform = 'translateY(0px) rotate(0deg)';
            
            // Re-enable floating breathing animation after smooth return
            setTimeout(() => {
                if (!isHovered) {
                    profileCard.style.animation = 'floatPhoto 5s ease-in-out infinite alternate';
                }
            }, 600);
        });
    }

    // ----------------------------------------------------------------------
    // 8. DYNAMIC HERO STATS COUNT-UP ANIMATION
    // ----------------------------------------------------------------------
    const statElements = document.querySelectorAll('.stat-number[data-target]');
    if ('IntersectionObserver' in window && statElements.length > 0) {
        const statsObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const el = entry.target;
                    const target = parseInt(el.getAttribute('data-target'), 10);
                    let current = 0;
                    const duration = 1200;
                    const stepTime = 50;
                    const steps = duration / stepTime;
                    const increment = target / steps;

                    const counter = setInterval(() => {
                        current += increment;
                        if (current >= target) {
                            el.textContent = `${target}+`;
                            clearInterval(counter);
                        } else {
                            el.textContent = `${Math.ceil(current)}+`;
                        }
                    }, stepTime);

                    observer.unobserve(el);
                }
            });
        }, { threshold: 0.5 });

        statElements.forEach(el => statsObserver.observe(el));
    }

    // ----------------------------------------------------------------------
    // 9. SCROLL REVEAL ANIMATIONS (INTERSECTION OBSERVER)
    // ----------------------------------------------------------------------
    if ('IntersectionObserver' in window) {
        const revealTargets = document.querySelectorAll(
            '.about-card, .timeline-card, .skill-category, .project-card, .contact-card, .github-profile-card, .section-header'
        );

        revealTargets.forEach((target, index) => {
            target.classList.add('reveal-init');
            // Add staggered delay based on sibling index
            const siblingIndex = Array.from(target.parentElement.children).indexOf(target);
            if (siblingIndex === 1) target.classList.add('delay-1');
            else if (siblingIndex === 2) target.classList.add('delay-2');
            else if (siblingIndex >= 3) target.classList.add('delay-3');
        });

        const revealObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('reveal-active');
                    observer.unobserve(entry.target);
                }
            });
        }, {
            threshold: 0.12,
            rootMargin: '0px 0px -40px 0px'
        });

        revealTargets.forEach(target => revealObserver.observe(target));
    }
});

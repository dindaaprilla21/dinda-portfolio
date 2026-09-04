import React, { useCallback, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
// --- LIBRARY UNTUK PDF (Pastikan sudah terinstal: html2canvas & jspdf) ---
import html2canvas from 'html2canvas';
import { jsPDF } from 'jspdf';
// ---------------------------------------------------

// Import Assets
import berita1 from '../assets/images/berita1.jpeg';
import berita2 from '../assets/images/berita2.jpeg';
import berita3 from '../assets/images/berita3.jpg';
import berita4 from '../assets/images/berita4.jpeg';
import berita5 from '../assets/images/berita5.png';

// --- FUNGSI HELPER UNTUK MENGHASILKAN KONTEN (Termasuk Gambar di Awal) ---
const generateContent = (imageUrl, judul, paragraphs) => {
    // Styling dasar untuk gambar di dalam konten
    const imageHtml = `<img src="${imageUrl}" alt="${judul}" style="width: 100%; height: auto; border-radius: 12px; margin-bottom: 25px; object-fit: cover; box-shadow: 0 4px 12px rgba(0,0,0,0.1);" />`;
    return imageHtml + paragraphs;
};
// --------------------------------------------------------------------------


// --- DATA BERITA (Konstanta Data Statis) ---
const BERITA_DATA = {
    1: {
        id: 1,
        tanggal: "17 November 2025",
        kategori: "Pembangunan",
        judul: "Pemerintah Desa Legok Umumkan Publikasi Infografik Perubahan APBDesa Tahun 2025",
        imageUrl: berita5,
        konten: generateContent(
            berita5, // Variabel Import Gambar
            "Infografik APBDesa",
            `<p>Legok — Pemerintah Desa Legok di bawah kepemimpinan Kepala Desa Mulyana, S.E., secara resmi merilis Infografik Perubahan Anggaran Pendapatan dan Belanja Desa (APBDesa) Tahun 2025 sebagai wujud komitmen terhadap transparansi, akuntabilitas, dan keterbukaan informasi publik.</p>
            <p>Publikasi ini merupakan tindak lanjut dari proses penyusunan perubahan APBDesa yang sebelumnya telah dibahas dalam forum musyawarah desa bersama Badan Permusyawaratan Desa (BPD) yang dipimpin oleh H. Wahyudin, M.Pd. Perubahan anggaran dilakukan berdasarkan evaluasi kebutuhan pembangunan desa, penyesuaian program prioritas nasional, serta usulan masyarakat dari berbagai unsur.</p>
            <p>Kepala Desa Mulyana, S.E. menyampaikan bahwa perubahan APBDesa tahun 2025 menekankan pada penguatan pembangunan infrastruktur desa, peningkatan kualitas layanan dasar, pemberdayaan masyarakat, serta pengembangan ekonomi lokal. "Publikasi infografik ini merupakan bentuk komitmen kami terhadap keterbukutan informasi. Masyarakat berhak mengetahui alokasi anggaran dan arah pembangunan yang sedang kita jalankan," ujar Mulyana, S.E.</p>
            <p>Ketua BPD H. Wahyudin, M.Pd. mendukung penuh transparansi anggaran melalui penyebaran informasi dalam bentuk infografik, karena langkah ini memudahkan masyarakat memahami struktur anggaran yang sebelumnya hanya disajikan dalam format dokumen resmi yang cukup teknis. Infografik Perubahan APBDesa Tahun 2025 kini dapat diakses melalui papan informasi kantor desa, media sosial resmi Pemerintah Desa Legok, serta kanal komunikasi publik lainnya.</p>
            <p>Pemerintah Desa Legok berharap publikasi ini menjadi momentum penguatan partisipasi masyarakat dalam pengawasan dan evaluasi pembangunan desa, sehingga tercipta tata kelola pemerintahan desa yang transparan, responsif, dan berpihak pada kebutuhan masyarakat.</p>`
        )
    },
    2: {
        id: 2,
        tanggal: "17 November 2025",
        kategori: "Sosial",
        judul: "Musdesus Pembentukan Koperasi Desa Merah Putih",
        imageUrl: berita1,
        konten: generateContent(
            berita1, // Variabel Import Gambar
            "Musdesus Koperasi",
            `
            <p>Legok, — Pemerintah Desa Legok menggelar Musyawarah Desa Khusus (Musdesus) dalam rangka pembentukan Koperasi Desa Merah Putih, bertempat di Aula Kantor Desa Legok. Musdesus ini merupakan langkah strategis desa dalam memperkuat sektor ekonomi masyarakat dan menciptakan kelembagaan ekonomi desa yang lebih mandiri, profesional, dan berkelanjutan.</p>
            <p>Acara Musdesus dipimpin langsung oleh Kepala Desa Legok, Mulyana, S.E., serta dihadiri oleh Ketua BPD Desa Legok, H. Wahyudin, M.Pd, perangkat desa, ketua RT/RW, tokoh masyarakat, tokoh perempuan, pemuda, serta unsur kelembagaan desa lainnya.</p>
            <p>Dalam sambutannya, Kepala Desa Mulyana, S.E. menyampaikan bahwa pembentukan koperasi desa merupakan jawaban atas kebutuhan masyarakat akan lembaga ekonomi yang mampu mengelola potensi lokal secara lebih transparan dan akuntabel. “Koperasi Desa Merah Putih diharapkan menjadi wadah pemberdayaan ekonomi warga, membantu meningkatkan pendapatan masyarakat, sekaligus menjadi pilar penggerak ekonomi desa,” ujar Kepala Desa.</p>
            <p>Sementara itu, Ketua BPD H. Wahyudin, M.Pd menegaskan bahwa Musdesus ini merupakan amanat dari peraturan perundangan yang menekankan pentingnya partisipasi masyarakat dalam pembentukan lembaga desa. “BPD mendukung penuh pembentukan koperasi ini. Kami berharap koperasi berjalan profesional, terbuka, dan benar-benar membawa manfaat bagi seluruh warga Desa Legok,” ungkapnya.</p>
            <h3>Agenda Musdesus</h3>
            <p>Dalam Musdesus ini dibahas beberapa poin penting, di antaranya:</p>
            <ul>
                <li>1. Penetapan nama koperasi: Koperasi Desa Merah Putih Legok Kecamatan Legok.</li>
                <li>2. Pembahasan tujuan dan bidang usaha koperasi, termasuk pengelolaan ekonomi produktif desa, pelayanan simpan pinjam, dan usaha lain berbasis kebutuhan masyarakat.</li>
                <li>3. Pembentukan tim formatur untuk penyusunan AD/ART koperasi.</li>
                <li>4. Penetapan rencana tindak lanjut menuju legalitas koperasi melalui Dinas Koperasi Kabupaten Tangerang.</li>
            </ul>
            <p>Seluruh peserta Musdesus menyetujui pembentukan Koperasi Desa Merah Putih secara mufakat. Dukungan penuh masyarakat menunjukkan tingginya harapan terhadap hadirnya lembaga ekonomi desa yang mampu memberikan manfaat nyata bagi warga.</p>
            <p>Dengan terbentuknya koperasi ini, Desa Legok berharap ke depan dapat memperkuat kemandirian ekonomi desa, meningkatkan kualitas layanan masyarakat, dan membuka lebih banyak peluang usaha bagi warga.</p>
        `
        )
    },
    3: {
        id: 3,
        tanggal: "19 September 2025",
        kategori: "Pemerintahan",
        judul: "Desa Legok Tuntas Ikuti Monitoring & Evaluasi",
        imageUrl: berita2,
        konten: generateContent(
            berita2, // Variabel Import Gambar
            "Monitoring & Evaluasi",
            `<p>Tangerang – Desa Legok, Kecamatan Legok, Kabupaten Tangerang, kembali menorehkan langkah penting dalam perjalanan menuju Desa Anti Korupsi tahun 2025. Pada Kamis, 18 September 2025, Pemerintah Desa Legok telah selesai mengikuti Monitoring & Evaluasi (Monev) ke-3 yang digelar di Kantor Inspektorat Provinsi Banten.</p>
            <p>Kegiatan ini dilaksanakan dalam rangka menilai sejauh mana implementasi program Desa Anti Korupsi yang telah berjalan, sekaligus memastikan keberlanjutan komitmen desa dalam membangun tata kelola pemerintahan yang bersih, transparan, dan akuntabel.</p>
            <p>Dalam Monev ke-3 ini, Komisi Pemberantasan Korupsi (KPK) RI bertindak sebagai tim Monitoring dan Evaluasi utama, didukung oleh Inspektorat Provinsi Banten, Inspektorat Kabupaten Tangerang, Dinas Pemberdayaan Masyarakat dan Desa (DPMD), serta Dinas Komunikasi dan Informatika (KOMINFO) Kabupaten Tangerang dan Provinsi Banten.</p>
            <p>Kepala Desa Legok, Mulyana, S.E., menyampaikan rasa syukur atas terlaksananya Monev tahap ketiga ini. Ia menegaskan bahwa Desa Legok akan terus konsisten menjadi teladan dalam penerapan nilai-nilai integritas, keterbukuan informasi publik, serta pelayanan yang bebas dari praktik korupsi dan gratifikasi.</p>
            <p>“Alhamdulillah, Desa Legok telah menyelesaikan rangkaian Monitoring & Evaluasi ke-3 ini bersama KPK RI dan jajaran pemerintah daerah. Kami berkomitmen untuk menjaga kepercayaan yang telah diberikan, serta terus memperkuat pelayanan kepada masyarakat dengan prinsip transparansi, akuntabilitas, dan integritas,” ujar Mulyana.</p>
            <p>Dengan selesainya Monev ke-3 ini, Desa Legok semakin mantap melangkah menuju tahap Penilaian dalam program Percontohan Desa Anti Korupsi 2025, sekaligus membawa nama Kabupaten Tangerang dan Provinsi Banten sebagai perwakilan di tingkat nasional.</p>
            <p>Pemerintah Desa Legok berharap dukungan dari seluruh perangkat desa, masyarakat, dan stakeholder terkait, agar cita-cita bersama mewujudkan tata kelola desa yang bersih, transparan, serta bebas dari praktik korupsi dapat tercapai.</p>`
        )
    },
    4: {
        id: 4,
        tanggal: "17 November 2025",
        kategori: "Pemerintahan",
        judul: "Pemerintah Desa Legok Meraih Predikat Desa Antikorupsi",
        imageUrl: berita3,
        konten: generateContent(
            berita3, // Variabel Import Gambar
            "Desa Antikorupsi",
            `<p>Legok, Kabupaten Tangerang — Pemerintah Desa Legok kembali menorehkan prestasi membanggakan setelah meraih Predikat Istimewa dengan nilai 92 dalam Perlombaan Percontohan Desa Antikorupsi Tingkat Provinsi Banten yang diselenggarakan oleh Komisi Pemberantasan Korupsi (KPK) Republik Indonesia. Dalam kegiatan tersebut, Desa Legok bukan hanya meraih nilai tinggi, tetapi juga ditetapkan sebagai Desa Percontohan Antikorupsi Tahun 2025.</p>
            <p>Menambah kehormatan, kegiatan penilaian dan pengumuman pemenang ini diselenggarakan langsung di Desa Legok, yang menjadi tuan rumah acara tingkat provinsi tersebut. Acara ini dihadiri oleh berbagai unsur pemerintah, termasuk Wakil Bupati Tangerang, Ibu Intan, yang memberikan apresiasi khusus atas komitmen Desa Legok dalam menjaga transparansi dan integritas pemerintahan.</p>
            
            <h3>Indikator Keunggulan Desa Legok</h3>
            <p>Dalam penilaian KPK, Desa Legok dianggap unggul dalam berbagai indikator penting, mulai dari:</p>
            <ul>
                <li>1. Transparansi layanan publik</li>
                <li>2. Pengelolaan keuangan desa yang akuntabel</li>
                <li>3. Inovasi digital dalam penyajian dan publikasi informasi</li>
                <li>4. Tata kelola pemerintahan desa yang tertib</li>
                <li>5. Partisipasi aktif masyarakat dalam pengawasan pembangunan</li>
                <li>6. Penerapan nilai-nilai integritas di seluruh perangkat desa</li>
            </ul>
            <p>Nilai 92 yang diraih Desa Legok masuk kategori Predikat Istimewa, sekaligus menjadi salah satu nilai tertinggi dalam ajang tersebut.</p>
            
            <p>Kepala Desa Legok, Mulyana, S.E., menyampaikan rasa syukur dan bangga atas pencapaian ini. Ia menegaskan bahwa prestasi tersebut merupakan hasil kerja kolektif perangkat desa, BPD, lembaga desa, dan seluruh masyarakat.</p>
            <p>“Nilai 92 dan predikat istimewa ini adalah bukti bahwa Desa Legok benar-benar menerapkan prinsip transparansi dan integritas dalam setiap proses pemerintahan. Kami berterima kasih kepada seluruh warga yang telah mendukung, dan ini akan menjadi motivasi untuk terus menjaga budaya antikorupsi di desa,” ujar Mulyana, S.E.</p>
            
            <p>Sementara itu, Ketua BPD, H. Wahyudin, M.Pd., menegaskan bahwa BPD akan terus mengawal pemerintahan desa agar tetap konsisten menjalankan sistem yang bersih dan akuntabel.</p>
            <p>“Predikat ini bukan akhir, tetapi awal dari semakin kuatnya komitmen kita terhadap tata kelola desa yang jujur dan transparan. BPD akan terus memperkuat fungsi pengawasan agar Desa Legok selalu menjadi desa teladan,” ungkapnya.</p>
            
            <p>Dalam sambutannya, Wakil Bupati Tangerang, Ibu Intan Nurul Hikmah S.E., memberi apresiasi tinggi kepada Pemerintah Desa Legok. Ia menyebut Desa Legok sebagai contoh nyata bahwa desa dapat menjadi *role model* dalam gerakan antikorupsi di tingkat Provinsi Banten.</p>
            <p>“Keberhasilan Desa Legok meraih nilai 92 dan predikat istimewa membuktikan bahwa desa mampu menjadi pionir dalam pelayanan publik yang bersih. Semoga prestasi ini menjadi inspirasi bagi desa-desa lain di Kabupaten Tangerang dan Provinsi Banten,” ujarnya.</p>
            
            <p>Dengan pencapaian luar biasa ini, Desa Legok resmi menyandang status sebagai Desa Percontohan Antikorupsi Provinsi Banten Tahun 2025. Pemerintah desa berkomitmen untuk terus mempertahankan dan meningkatkan standar integritas demi terwujudnya tata kelola pemerintahan yang bersih, transparan, dan berpihak pada masyarakat.</p>`
        )
    },
    5: {
        id: 5,
        tanggal: "15 September 2025",
        kategori: "Pemerintahan",
        judul: "Pembinaan Pencegahan Korupsi dan Gratifikasi di Desa Legok",
        imageUrl: berita4,
        konten: generateContent(
            berita4, // Variabel Import Gambar
            "Pembinaan Pencegahan Korupsi",
            `<p>Legok – Dalam rangka mendukung program Lomba Desa Anti Korupsi 2025 yang diselenggarakan oleh Komisi Pemberantasan Korupsi Republik Indonesia (KPK RI), Pemerintah Desa Legok, Kecamatan Legok, Kabupaten Tangerang, menggelar kegiatan pembinaan pencegahan korupsi dan gratifikasi pada Rabu (10/09/2025) di Aula Kantor Desa Legok.</p>
            <p>Kegiatan tersebut dihadiri langsung oleh jajaran Inspektorat Kabupaten Tangerang dan Kejaksaan Negeri Kabupaten Tangerang sebagai narasumber utama. Hadir pula seluruh perangkat Desa Legok yang menjadi peserta utama pembinaan. Desa Legok sendiri dipercaya mewakili Kabupaten Tangerang dalam ajang Lomba Desa Anti Korupsi tingkat nasional.</p>
            <p>Dalam sambutannya, Kepala Desa Legok, Mulyana, S.E., menyampaikan bahwa kegiatan ini menjadi momentum penting untuk memperkuat komitmen pemerintahan desa yang bersih, transparan, dan akuntabel.</p>
            <p>“Kami merasa bangga Desa Legok mendapat kepercayaan mewakili Kabupaten Tangerang. Tugas ini tidak hanya soal lomba, tetapi lebih pada komitmen nyata bagaimana pemerintah desa bersama masyarakat menolak segala bentuk korupsi dan gratifikasi,” ujar Mulyana.</p>
            <p>Sementara itu, perwakilan dari Inspektorat Kabupaten Tangerang menekankan pentingnya penguatan pengendalian internal di tingkat desa. Materi pembinaan difokuskan pada tata kelola pemerintahan desa, pengelolaan keuangan desa, hingga peningkatan integritas perangkat desa dalam melayani masyarakat.</p>
            <p>“Pencegahan lebih penting daripada penindakan. Aparatur desa harus memahami aturan sejak dini agar tidak terjerumus pada praktik korupsi maupun gratifikasi,” ungkap narasumber dari Inspektorat.</p>
            <p>Sedangkan dari Kejaksaan Negeri Kabupaten Tangerang, pembinaan diarahkan pada aspek hukum dan konsekuensi pidana dari tindak korupsi maupun penerimaan gratifikasi. Aparatur desa diingatkan untuk bekerja sesuai regulasi, mengutamakan keterbukuan informasi publik, serta selalu mengedepankan kepentingan masyarakat di atas kepentingan pribadi.</p>
            <p>“Kami tidak ingin perangkat desa menjadi korban ketidaktahuan hukum. Karena itu, edukasi dan pencegahan seperti ini sangat penting agar setiap aparatur bekerja sesuai aturan dan bebas dari korupsi,” jelas perwakilan Kejaksaan.</p>
            <p>Melalui kegiatan ini, Desa Legok semakin mantap meneguhkan diri sebagai desa percontohan dalam upaya pencegahan tindak pidana korupsi. Komitmen ini diharapkan mampu menginspirasi desa-desa lain di Kabupaten Tangerang, bahkan secara nasional, untuk terus memperkuat nilai-nilai integritas, transparansi, serta pelayanan publik yang bersih.</p>
            <p>Acara berlangsung dengan lancar dan penuh semangat. Seluruh perangkat Desa Legok bertekad menjadikan hasil pembinaan ini sebagai pedoman nyata dalam mewujudkan pemerintahan desa yang bebas dari praktik korupsi.</p>`
        )
    }
};

// --- KONSTANTA STYLE UTAMA (Didefinisikan sekali di awal) ---
const PRIMARY_COLOR = '#047857'; // Hijau Gelap
const SECONDARY_COLOR = '#059669'; // Hijau Terang

const BASE_BUTTON_STYLE = {
    flex: '1',
    minWidth: '160px',
    padding: '16px 25px',
    color: 'white',
    borderRadius: '12px',
    fontWeight: '600',
    transition: 'all 0.3s ease',
    border: 'none',
    cursor: 'pointer',
    fontSize: 'clamp(14px, 2vw, 16px)',
    textAlign: 'center',
};

// Fungsi pembantu untuk menghasilkan style dengan hover effect
const getButtonStyle = (color, shadow) => ({
    ...BASE_BUTTON_STYLE,
    backgroundColor: color,
    boxShadow: `0 4px 12px ${shadow}`,
    // Style Hover yang digunakan untuk Object.assign
    ':hover': {
        transform: 'translateY(-2px)',
        boxShadow: `0 6px 16px ${shadow.replace('0.25', '0.3')}`,
    }
});

const KEMBALI_STYLE = getButtonStyle(SECONDARY_COLOR, 'rgba(5, 150, 105, 0.25)');
const UNDUH_PDF_STYLE = getButtonStyle('#1d4ed8', 'rgba(29, 78, 216, 0.25)'); // Biru
const BAGIKAN_LINK_STYLE = getButtonStyle('#7c3aed', 'rgba(124, 58, 237, 0.25)'); // Ungu

// Fungsi Helper untuk mengelola hover style secara inline
const applyHoverStyle = (e, style) => {
    Object.assign(e.currentTarget.style, style[':hover']);
};
const removeHoverStyle = (e, baseShadow) => {
    Object.assign(e.currentTarget.style, { 
        transform: 'none', 
        boxShadow: baseShadow,
    });
};
// --- AKHIR KONSTANTA STYLE ---


// --- KOMPONEN UTAMA ---
export default function BeritaDetail() {
    const { id } = useParams();
    const berita = BERITA_DATA[id] || BERITA_DATA[1];
    
    const [isLoadingPdf, setIsLoadingPdf] = useState(false);

    // FUNGSI MENGUNDUH PDF (Dipeparkan dengan useCallback)
    const handleDownloadPdf = useCallback(() => {
        const input = document.getElementById('article-to-pdf');
        
        if (!input) {
            alert("Error: Konten berita tidak ditemukan.");
            return;
        }
        
        const confirmDownload = window.confirm("File PDF akan diunduh. Setelah selesai, Anda dapat membagikannya melalui platform lain.");
        if (!confirmDownload) return;

        setIsLoadingPdf(true);
        
        html2canvas(input, {
            scale: 2, 
            useCORS: true,
            windowWidth: 960 
        })
        .then((canvas) => {
            const imgData = canvas.toDataURL('image/jpeg', 1.0); 
            const pdf = new jsPDF('p', 'mm', 'a4');

            const imgProps= pdf.getImageProperties(imgData);
            const pdfWidth = pdf.internal.pageSize.getWidth();
            const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;

            pdf.addImage(imgData, 'JPEG', 0, 0, pdfWidth, pdfHeight);
            
            const safeTitle = berita.judul.replace(/[^a-z0-9]/gi, '_').toLowerCase();
            pdf.save(`${safeTitle}.pdf`); 
        })
        .catch(error => {
            console.error("Gagal membuat PDF:", error);
            alert("Maaf, terjadi kesalahan saat membuat PDF.");
        })
        .finally(() => {
            setIsLoadingPdf(false);
        });
    }, [berita.judul]);

    // FUNGSI MEMBAGIKAN TAUTAN (Dipeparkan dengan useCallback)
    const handleShareLink = useCallback(() => {
        if (navigator.share) {
            navigator.share({ 
                title: berita.judul, 
                text: `Baca berita terbaru: ${berita.judul}`, 
                url: window.location.href 
            })
            .then(() => console.log('Berhasil berbagi link'))
            .catch((error) => console.error('Gagal berbagi link:', error));
        } else {
            // Fallback: Salin ke clipboard
            navigator.clipboard.writeText(window.location.href);
            alert("Fitur Berbagi Tautan (Native Share) tidak didukung di browser ini. Tautan berita telah disalin ke clipboard.");
        }
    }, [berita.judul]);


    return (
        <div style={{ 
            minHeight: '100vh',
            backgroundColor: '#f8fafc',
            paddingTop: '0',
            paddingBottom: '40px',
            fontFamily: "'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif"
        }}>
            {/* Style CSS Global (Dipertahankan di sini untuk mengatur style HTML konten berita) */}
            <style>{`
                /* Global Styles for Responsiveness & Typography */
                body { margin: 0; padding: 0; }
                * { box-sizing: border-box; }
                
                /* Responsive Content Padding */
                .content-wrapper {
                    max-width: 960px;
                    margin: 0 auto;
                    padding-left: 16px;
                    padding-right: 16px;
                }

                /* Article Content Styling (untuk konten dari dangerouslySetInnerHTML) */
                .article-content p {
                    margin-bottom: 24px;
                    line-height: 1.8;
                    color: #374151;
                    text-align: justify;
                    text-justify: inter-word;
                }
                .article-content h2, .article-content h3 {
                    margin-top: 2rem;
                    margin-bottom: 1rem;
                    color: ${PRIMARY_COLOR};
                }
                .article-content ul {
                    margin-bottom: 24px;
                    padding-left: 20px;
                }
                .article-content li {
                    margin-bottom: 8px;
                    color: #374151;
                }
                /* Style untuk Gambar yang dimasukkan melalui generateContent */
                .article-content img {
                    /* Memastikan gambar di dalam konten responsif penuh */
                    max-width: 100%;
                    height: auto;
                    display: block; 
                }

                /* PENYESUAIAN GAYA UNTUK HURUF PERTAMA (DROP CAP) - Dibuat lebih kecil (sekitar 2 baris) */
                .article-content p:first-of-type::first-letter {
                    font-size: 2.2rem; /* Ukuran yang lebih kecil dan pas 2 baris */
                    font-weight: 800; 
                    color: ${PRIMARY_COLOR}; 
                    float: left; 
                    line-height: 1.1; 
                    margin-right: 8px; /* Jarak yang lebih rapat */
                    padding-right: 0px;
                    padding-top: 0px; /* Menghapus padding atas */
                }
                /* AKHIR PENAMBAHAN STYLE */

                @media (max-width: 640px) {
                    .article-content p {
                        text-align: left;
                        line-height: 1.7;
                    }
                    /* Menonaktifkan efek drop cap di layar kecil/mobile untuk menjaga responsivitas */
                    .article-content p:first-of-type::first-letter {
                        font-size: inherit; 
                        font-weight: inherit; 
                        float: none; 
                        margin-right: 0;
                        padding-right: 0;
                        padding-top: 0;
                        line-height: inherit;
                        color: inherit; 
                    }
                }
            `}</style>

            {/* HEADER BERITA - Dengan Background Gradien */}
            <div style={{
                background: `linear-gradient(135deg, ${SECONDARY_COLOR} 0%, ${PRIMARY_COLOR} 100%)`,
                color: 'white',
                padding: '30px 16px 40px',
                marginBottom: '30px',
                boxShadow: '0 10px 20px rgba(4, 120, 87, 0.25)',
                borderBottomLeftRadius: '25px',
                borderBottomRightRadius: '25px',
            }}>
                <div style={{ maxWidth: '960px', margin: '0 auto' }}>
                    
                    {/* Tombol Kembali (Link) - Style Ringkas */}
                    <Link 
                        to="/" 
                        style={{ 
                            color: 'rgba(255,255,255,0.95)', 
                            textDecoration: 'none',
                            fontSize: '14px',
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: '8px',
                            marginBottom: '25px',
                            padding: '8px 16px',
                            borderRadius: '25px',
                            backgroundColor: 'rgba(255,255,255,0.15)',
                            backdropFilter: 'blur(10px)',
                            border: '1px solid rgba(255,255,255,0.2)',
                            fontWeight: '500',
                            transition: 'all 0.3s ease',
                        }} 
                        onMouseOver={(e) => e.currentTarget.style.backgroundColor = 'rgba(255,255,255,0.3)'}
                        onMouseOut={(e) => e.currentTarget.style.backgroundColor = 'rgba(255,255,255,0.15)'}
                    >
                        <span style={{ fontSize: '18px', lineHeight: '1' }}>⮜</span> Kembali ke Beranda
                    </Link>

                    {/* Judul Utama */}
                    <h1 style={{ 
                        fontSize: 'clamp(1.5rem, 6vw, 2.5rem)',
                        marginBottom: '18px',
                        fontWeight: '800', 
                        lineHeight: '1.3',
                        letterSpacing: '-0.7px',
                        textShadow: '0 2px 4px rgba(0,0,0,0.1)'
                    }}>
                        {berita.judul}
                    </h1>
                    
                    {/* Badge Kategori & Tanggal */}
                    <div style={{ display: 'flex', gap: '15px', flexWrap: 'wrap', alignItems: 'center' }}>
                        <span style={{ 
                            backgroundColor: 'white', 
                            color: PRIMARY_COLOR, 
                            padding: '8px 16px', 
                            borderRadius: '50px',
                            fontSize: 'clamp(12px, 2vw, 14px)',
                            fontWeight: '700',
                            boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
                        }}>
                            {berita.kategori}
                        </span>
                        <span style={{ fontSize: 'clamp(13px, 2vw, 15px)', opacity: 0.9, fontWeight: '500', display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <span style={{ fontSize: '1.2em' }}>🗓️</span> {berita.tanggal}
                        </span>
                    </div>
                </div>
            </div>

            {/* KONTEN UTAMA */}
            <div className="content-wrapper">
                {/* Article Card - Konten Berita (Target PDF) */}
                <div 
                    id="article-to-pdf" // Target untuk html2canvas
                    style={{
                        backgroundColor: 'white',
                        borderRadius: '20px',
                        padding: 'clamp(25px, 6vw, 40px)',
                        boxShadow: '0 8px 24px rgba(0,0,0,0.05)',
                        borderLeft: `8px solid ${PRIMARY_COLOR}`,
                        marginBottom: '40px',
                    }}
                >
                    {/* Konten HTML Berita */}
                    <div className="article-content" dangerouslySetInnerHTML={{ __html: berita.konten }} />
                </div>

                {/* KELOMPOK TOMBOL AKSI */}
                <div style={{
                    display: 'flex',
                    gap: '15px',
                    padding: '20px',
                    backgroundColor: 'white',
                    borderRadius: '16px',
                    flexWrap: 'wrap',
                    justifyContent: 'center',
                    boxShadow: '0 4px 16px rgba(0,0,0,0.08)',
                    border: '1px solid #e2e8f0'
                }}>
                    
                    {/* 1. Tombol Kembali */}
                    <Link 
                        to="/" 
                        style={KEMBALI_STYLE}
                        onMouseOver={(e) => applyHoverStyle(e, KEMBALI_STYLE)}
                        onMouseOut={(e) => removeHoverStyle(e, KEMBALI_STYLE.boxShadow)}
                    >
                        ← Kembali
                    </Link>

                    {/* 2. Tombol Unduh PDF */}
                    <button 
                        onClick={handleDownloadPdf} 
                        disabled={isLoadingPdf} 
                        style={{
                            ...UNDUH_PDF_STYLE,
                            opacity: isLoadingPdf ? 0.6 : 1,
                            cursor: isLoadingPdf ? 'not-allowed' : 'pointer',
                        }}
                        onMouseOver={(e) => !isLoadingPdf && applyHoverStyle(e, UNDUH_PDF_STYLE)}
                        onMouseOut={(e) => !isLoadingPdf && removeHoverStyle(e, UNDUH_PDF_STYLE.boxShadow)}
                    >
                        {isLoadingPdf ? '⏳ Mempersiapkan PDF...' : '⬇️ Unduh File PDF'}
                    </button>

                    {/* 3. Tombol Bagikan Tautan */}
                    <button 
                        onClick={handleShareLink} 
                        style={BAGIKAN_LINK_STYLE}
                        onMouseOver={(e) => applyHoverStyle(e, BAGIKAN_LINK_STYLE)}
                        onMouseOut={(e) => removeHoverStyle(e, BAGIKAN_LINK_STYLE.boxShadow)}
                    >
                        📤 Bagikan Tautan
                    </button>
                </div>
            </div>
        </div>
    );
}
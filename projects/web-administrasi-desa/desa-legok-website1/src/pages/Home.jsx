import Navbar from "../components/navbar/Navbar";
import HeroSection from "../components/hero/HeroSection";
import StatistikCards from "../components/statistik/StatistikCards";
import LayananSection from "../components/layanan/LayananSection";
import BeritaSection from "../components/berita/BeritaSection";
import KontakWA from "../components/sidebar/KontakWA";
import JamOperasional from "../components/sidebar/JamOperasional";
import FloatingChatBubble from "../components/sidebar/FloatingChatBubble";
import Footer from "../components/footer/Footer";

export default function Home() {
  return (
    <>
      <Navbar />
      <HeroSection />
      <StatistikCards />

      <main className="container mx-auto px-6 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-10">

          <div className="lg:col-span-2 space-y-12">
            <LayananSection />
            <BeritaSection />
          </div>

          <aside className="space-y-8">
            <KontakWA />
            <JamOperasional />
          </aside>

        </div>
      </main>

      <Footer />

      {/* Floating WhatsApp Chat Bubble */}
      <FloatingChatBubble />
    </>
  );
}

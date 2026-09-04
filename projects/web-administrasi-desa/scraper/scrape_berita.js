import { chromium } from "playwright";

(async () => {
    const browser = await chromium.launch({
        headless: false,
        channel: "chrome",
    });

    const page = await browser.newPage();

    console.log("⏳ Masuk ke halaman berita...");
    await page.goto("https://legok-legok.desa.id/berita", {
        waitUntil: "networkidle",
        timeout: 0,
    });

    await page.waitForTimeout(3000); // berikan waktu render

    await page.waitForSelector("article .title a", { timeout: 30000 });

    const artikel = await page.$$eval("article", items =>
        items.map(el => ({
            judul: el.querySelector("h2.title a")?.innerText.trim(),
            tanggal: el.querySelector("p.post-date time")?.innerText.trim(),
            link: el.querySelector("h2.title a")?.href,
            thumbnail: el.querySelector(".post-img img")?.src
        }))
    );

    console.log("Total artikel:", artikel);
})();

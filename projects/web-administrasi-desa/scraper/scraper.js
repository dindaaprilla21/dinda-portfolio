const fs = require("fs");
const axios = require("axios");
const cheerio = require("cheerio");

async function scrapeBeritaList() {
    const url = "https://legok-legok.desa.id/";
    const { data } = await axios.get(url);

    const $ = cheerio.load(data);
    const berita = [];

    $(".jeg_post").each((i, el) => {
        const judul = $(el).find(".jeg_post_title a").text().trim();
        const tanggal = $(el).find(".jeg_meta_date").text().trim();
        const link = $(el).find(".jeg_post_title a").attr("href");
        const image = $(el).find("img").attr("data-src") || $(el).find("img").attr("src");

        if (judul && link) {
            berita.push({ judul, tanggal, link, image });
        }
    });

    fs.writeFileSync("berita.json", JSON.stringify(berita, null, 2));
    console.log("📌 Scraping daftar berita selesai:", berita.length);
}

async function run() {
    console.log("⏳ Scraping daftar berita...");
    await scrapeBeritaList();
    console.log("✅ Selesai. File: berita.json");
}

run();

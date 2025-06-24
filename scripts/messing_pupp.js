const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const puppeteer = require('puppeteer-core');

/**
 * Reads a CSV of `url,status`, navigates to each URL with Puppeteer,
 * saves the page content as .html, and updates statuses accordingly.
 * @param {string} csvPath - Path to the input CSV file.
 * @param {string} outputDir - Directory to save downloaded HTML.
 * @param {object} opts - Options: { wait, waitRetry, browserPath }.
 */
async function processCsvUrls(csvPath, outputDir, opts = {}) {
  const { wait = 2000, waitRetry = 5000, browserPath = '/usr/bin/chromium' } = opts;

  // Ensure output directory exists
  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

  // Load CSV
  const entries = [];
  await new Promise((resolve, reject) => {
    fs.createReadStream(csvPath)
      .pipe(csv(['url','status']))
      .on('data', row => entries.push({ url: row.url, status: row.status }))
      .on('end', resolve)
      .on('error', reject);
  });

  const browser = await puppeteer.launch({
    executablePath: browserPath,
    headless: true
  });
  const page = await browser.newPage();

  for (let entry of entries) {
    if (!['0','6','8'].includes(entry.status)) {
      try {
        console.log(`👉 Navigating to ${entry.url}`);
        await page.goto(entry.url, { waitUntil: 'networkidle2', timeout: 30000 });
        const html = await page.content();

        const filename = entry.url.replace(/[^a-zA-Z0-9\-]/g, '_') + '.html';
        fs.writeFileSync(path.join(outputDir, filename), html);
        entry.status = '0';
        console.log(`✅ Saved ${filename}`);
        await new Promise(r => setTimeout(r, wait));
      } catch (err) {
        console.error(`❌ Error on ${entry.url}: ${err.message}`);
        entry.status = '8';
        console.log(`⏳ Retrying after ${waitRetry}ms`);
        await new Promise(r => setTimeout(r, waitRetry));
      }
    } else {
      console.log(`⏭ Skipping ${entry.url} (status=${entry.status})`);
    }
  }

  await browser.close();

  // Write updated CSV
  const lines = entries.map(e => `${e.url},${e.status}`);
  fs.writeFileSync(csvPath, ['url,status', ...lines].join('\n'));
  console.log('✅ All done! CSV updated.');
}
module.exports = { processCsvUrls };

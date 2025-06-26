const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const puppeteer = require('puppeteer-core');

/**
 * Reads a CSV of `url,status`, navigates to each URL with Puppeteer,
 * saves the page content as .html, and updates statuses accordingly.
 * @param {string} csvPath - Path to the input CSV file.
 * @param {string} outputDir - Directory to save downloaded HTML.
 * @param {number} start_row - Line number to start processing from (0-based, excluding header).
 * @param {object} opts - Options: { wait, waitRetry, browserPath }.
 */
async function processCsvUrls(csvPath, outputDir, start_row = 0, opts = {}) {
  const { wait = 2000, waitRetry = 5000, browserPath = '/usr/bin/chromium' } = opts;

  // Ensure output directory exists
  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

  // Load CSV
  const entries = [];
  let currentRow = 0;
  await new Promise((resolve, reject) => {
    fs.createReadStream(csvPath)
      .pipe(csv(['url','status']))
      .on('data', row => {
        if (currentRow >= start_row) {
          entries.push({ url: row.url, status: row.status });
        }
        currentRow++;
      })
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

        const { pathname } = new URL(entry.url);
        const segments = pathname.split('/').filter(Boolean);
        const name = segments.pop() || segments[segments.length - 1];
        const filename = `${name}.html`;
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

  // Read original CSV to preserve rows before start_row
  const allEntries = [];
  await new Promise((resolve, reject) => {
    fs.createReadStream(csvPath)
      .pipe(csv(['url','status']))
      .on('data', row => allEntries.push({ url: row.url, status: row.status }))
      .on('end', resolve)
      .on('error', reject);
  });

  // Update statuses for processed rows
  for (let i = 0; i < entries.length; i++) {
    const index = i + start_row;
    if (index < allEntries.length) {
      allEntries[index].status = entries[i].status;
    }
  }

  // Write updated CSV
  const lines = allEntries.map(e => `${e.url},${e.status}`);
  fs.writeFileSync(csvPath, ['url,status', ...lines].join('\n'));
  console.log('✅ All done! CSV updated.');
}

module.exports = { processCsvUrls };

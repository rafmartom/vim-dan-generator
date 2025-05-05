const puppeteer = require('puppeteer-core');
const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const { parse } = require('json2csv');
const bz2 = require('unbzip2-stream');
//const Command = require('commander');
const { program } = require('commander');
//import { Command } from 'commander'
//const program = new Command();

program
    .requiredOption('-d, --docu-path <path>', 'Path to the downloads directory')
    .requiredOption('-c, --csv-path <path>', 'Path to the CSV file (bz2 compressed)')
    .option('-w, --wait <ms>', 'Wait time between downloads', 2000)
    .option('-r, --wait-retry <ms>', 'Wait time after a failed download', 5000);
program.parse(process.argv);

const options = program.opts();
const DOCU_PATH = options.docuPath;
const CSV_PATH = options.csvPath;
const WAIT = parseInt(options.wait, 10);
const WAIT_RETRY = parseInt(options.waitRetry, 10);

/*
if (!fs.existsSync(DOCU_PATH)) {
    fs.mkdirSync(DOCU_PATH, { recursive: true });
}

async function downloadFromListWaitRetry(csvFilePath) {
    const urls = [];
    const decompressedCsvPath = csvFilePath.replace(/\.bz2$/, '');
    
    // Decompress bz2 file if necessary
    if (csvFilePath.endsWith('.bz2')) {
        console.log('Decompressing CSV file...');
        const fileStream = fs.createReadStream(csvFilePath).pipe(bz2());
        const outputStream = fs.createWriteStream(decompressedCsvPath);
        fileStream.pipe(outputStream);
        await new Promise(resolve => outputStream.on('finish', resolve));
    }
    
    if (!fs.existsSync(decompressedCsvPath)) {
        console.error('CSV file not found:', decompressedCsvPath);
        return;
    }
    
    fs.createReadStream(decompressedCsvPath)
        .pipe(csv())
        .on('data', (row) => {
            urls.push({ url: row.url, status: row.status || 'pending' });
        })
        .on('end', async () => {
            const browser = await puppeteer.launch({
                executablePath: '/usr/bin/chromium',
                headless: true 
            });


            const page = await browser.newPage();
            
            for (let i = 0; i < urls.length; i++) {
                const { url, status } = urls[i];
                if (status !== '0' && status !== '6' && status !== '8') {
                    try {
                        console.log(`Downloading: ${url}`);
                        await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });
                        const content = await page.content();
                        
                        const sanitizedFilename = url.replace(/[^a-zA-Z0-9]/g, '_') + '.html';
                        const filePath = path.join(DOCU_PATH, sanitizedFilename);
                        fs.writeFileSync(filePath, content);
                        
                        urls[i].status = '0';
                        console.log(`Downloaded: ${url}`);
                        await new Promise(resolve => setTimeout(resolve, WAIT));
                    } catch (error) {
                        console.error(`Error downloading ${url}:`, error.message);
                        urls[i].status = '8';
                        console.log(`Retrying in ${WAIT_RETRY / 1000} seconds...`);
                        await new Promise(resolve => setTimeout(resolve, WAIT_RETRY));
                    }
                }
            }
            
            await browser.close();
            
            // Save updated CSV
            const updatedCsv = parse(urls, { fields: ['url', 'status'] });
            fs.writeFileSync(decompressedCsvPath, updatedCsv);
            console.log('Download process completed.');
        });
}

downloadFromListWaitRetry(CSV_PATH);
*/

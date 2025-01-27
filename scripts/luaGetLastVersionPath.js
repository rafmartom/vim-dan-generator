// Get the url for the last version of Lua

const puppeteer = require('puppeteer-core');

// Get the target URL from command line arguments
const targetUrl = process.argv[2]; 


async function main () {
    const browser = await puppeteer.launch({
        executablePath: '/usr/bin/chromium'
    });
    const page = await browser.newPage();
    page.setDefaultTimeout(0);
    await page.goto(targetUrl);
    console.log(await page.content());
    // PENDING ISSUE WITH PUPPETEER NOT WORKING
    // JUST SELECTING THE WEBSITE TO INDEX MANUALY
    
//    var urlPath = await page.$eval('a[data-original-title="download raw javadoc"]', (element) => {
//        return element.getAttribute('href');
//    });
//    console.log(`https://javadoc.io${urlPath}`);

    await browser.close();
}

main();

const { processCsvUrls } = require('./download_from_list_wait_retry_pupp');

// Parse command-line arguments
const args = process.argv.slice(2);
const startRowIndex = args.indexOf('-r') + 1;
const start_row = startRowIndex > 0 && startRowIndex < args.length ? parseInt(args[startRowIndex], 10) : 0;

// Log the start_row value
console.log('start_row:', start_row);

processCsvUrls(
  '/home/fakuve/downloads/vim-dan/py-pi/https___pypi.org.csv',
  '/home/fakuve/downloads/vim-dan/py-pi/downloaded/project/',
  start_row,
  {
    wait: 2000,
    waitRetry: 5000,
    browserPath: '/usr/bin/chromium'
  }
).catch(err => {
  console.error('FATAL:', err);
  process.exit(1);
});

const counts = require('download-counts');
const fs = require('fs');

// Get top 50,000 packages (for example)
const packageNames = Object.keys(counts).slice(0, 50000);

// Create the CSV content
const csvContent = packageNames.map(packageName => {
  return `https://www.npmjs.com/package/${packageName},-1`;
}).join('\n');

// Write to the file
fs.writeFileSync('https___www.npmjs.com.csv', csvContent);

console.log('File saved as https___www.npmjs.com.csv');

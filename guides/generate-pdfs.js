const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const guides = [
  { file: 'guide-1-high-protein.html', output: 'nutrilish-7-day-high-protein-meal-prep.pdf' },
  { file: 'guide-2-macro-cheat-sheet.html', output: 'nutrilish-macro-counting-cheat-sheet.pdf' },
  { file: 'guide-3-30min-recipes.html', output: 'nutrilish-30-minute-meal-prep-recipes.pdf' },
  { file: 'guide-4-grocery-list.html', output: 'nutrilish-smart-grocery-list.pdf' },
  { file: 'guide-5-cutting-bulking.html', output: 'nutrilish-cutting-vs-bulking-guide.pdf' },
];

async function generatePDFs() {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  for (const guide of guides) {
    const inputPath = path.join(__dirname, 'templates', guide.file);
    const outputPath = path.join(__dirname, 'pdfs', guide.output);

    if (!fs.existsSync(inputPath)) {
      console.log(`⚠️  Skipping ${guide.file} — file not found`);
      continue;
    }

    console.log(`📄 Generating: ${guide.output}`);

    const page = await browser.newPage();

    await page.goto(`file://${inputPath}`, {
      waitUntil: 'networkidle0',
      timeout: 30000
    });

    // Wait for fonts to load
    await page.evaluate(() => document.fonts.ready);
    await new Promise(resolve => setTimeout(resolve, 1000));

    await page.pdf({
      path: outputPath,
      format: 'Letter',
      printBackground: true,
      preferCSSPageSize: true,
      margin: { top: 0, right: 0, bottom: 0, left: 0 }
    });

    const stats = fs.statSync(outputPath);
    const sizeMB = (stats.size / 1024 / 1024).toFixed(2);
    console.log(`   ✅ Done — ${sizeMB} MB`);

    await page.close();
  }

  await browser.close();
  console.log('\n🎉 All PDFs generated!');
}

generatePDFs().catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});

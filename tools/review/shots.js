// Visual review: full-page section screenshots at several widths + console/overflow check.
// Usage: node tools/review/shots.js <url> <outDir> [widths=360,390,430,1440] [waitMs=8000]
// Prints: errors, horizontal overflow, elements wider than the viewport. Uses the pre-installed Playwright.
const { chromium } = require('playwright');
(async () => {
  const [url, out, w = '360,390,430,1440', wait = '8000'] = process.argv.slice(2);
  const fs = require('fs'); fs.mkdirSync(out, { recursive: true });
  const b = await chromium.launch();
  for (const width of w.split(',').map(Number)) {
    const p = await b.newPage({ viewport: { width, height: width < 800 ? 844 : 900 }, deviceScaleFactor: width < 800 ? 3 : 1 });
    const errs = []; p.on('pageerror', e => errs.push(e.message)); p.on('console', m => m.type() === 'error' && errs.push(m.text()));
    p.on('requestfailed', r => errs.push('FAILED ' + r.url()));
    await p.goto(url, { waitUntil: 'domcontentloaded' }); await p.waitForTimeout(+wait);
    const H = await p.evaluate(() => document.documentElement.scrollHeight);
    let i = 0; for (let y = 0; y < H; y += (width < 800 ? 780 : 860)) { await p.evaluate(v => scrollTo(0, v), y); await p.waitForTimeout(900); await p.screenshot({ path: `${out}/w${width}-${String(i++).padStart(2, '0')}.png` }); }
    const ov = await p.evaluate(() => ({ scrollW: document.documentElement.scrollWidth, wide: [...document.querySelectorAll('body *')].filter(e => { const r = e.getBoundingClientRect(); if (!r.width || !(r.right > innerWidth + 1 || r.left < -1)) return false; for (let n = e; n && n !== document.body; n = n.parentElement) { const cs = getComputedStyle(n); if (cs.position === 'fixed' || cs.visibility === 'hidden' || cs.display === 'none' || ((cs.overflowX === 'hidden' || cs.overflowX === 'auto' || cs.overflowX === 'scroll') && n !== e)) return false; } return true; }).slice(0, 8).map(e => e.tagName + '.' + (e.className && e.className.baseVal === undefined ? e.className : '')) }));
    console.log(JSON.stringify({ width, shots: i, height: H, errors: errs.slice(0, 10), ...ov }));
    await p.close();
  }
  await b.close();
})();

const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch({ args:['--no-sandbox'] });
  const p = await b.newPage();
  const hits = new Set();
  p.on('request', r => {
    const u = r.url();
    if (/manifest|presentation|\/pages|\/iiif\/(?!image)/i.test(u)) hits.add(u);
  });
  try {
    await p.goto('https://viewer.onb.ac.at/131CAA08', { waitUntil:'networkidle', timeout:60000 });
  } catch(e){ console.log('nav:', e.message); }
  await p.waitForTimeout(4000);
  console.log('CAPTURED:');
  [...hits].forEach(u=>console.log(' ', u));
  await b.close();
})();

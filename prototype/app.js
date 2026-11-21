/* Ava-Makar — home page design prototype. */
(() => {
  const D = window.AVA_DATA;
  const $ = (s, r = document) => r.querySelector(s);
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const hasGsap = !!window.gsap;
  if (hasGsap && window.ScrollTrigger) gsap.registerPlugin(ScrollTrigger);
  const ar = (n) => String(n).replace(/\d/g, (d) => '٠١٢٣٤٥٦٧٨٩'[d]);
  const esc = (s) => s.replace(/[&<>]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c]));
  const dayNo = Math.floor(Date.now() / 86400000);

  /* ---------- Menu drawer: all sections (Product Blueprint V1) ---------- */
  const SECTIONS = [
    ['الرئيسية', ['قراءات اليوم', 'آخر الأخبار', 'إرشادات هامة', 'خدمات الدير', 'القديس أنبا مقار الكبير', 'أحدث الإصدارات']],
    ['الصلوات والقراءات الكنسية', ['قراءات وصلوات اليوم', 'التقويم القبطي والأعياد والأصوام', 'القطمارس', 'الأجبية', 'الخولاجي المقدس', 'السنكسار', 'الكتاب المقدس', 'الإبصلمودية والتسبحة والألحان', 'البصخة وأسبوع الآلام', 'كتب وخدمات طقسية أخرى']],
    ['جولة داخل دير أبو مقار', ['مرشدك داخل الدير', 'تاريخ الدير', 'كنيسة أنبا مقار الأثرية', 'كنيسة أبا سخيرون القليني', 'كنيسة الشهداء التسعة والأربعين', 'الحصن الأثري', 'القوس الأثري', 'قبة الميرون الأثرية', 'القلالي الأثرية', 'المائدة الأثرية', 'متحف الدير', 'قديسو الدير وآباؤه']],
    ['المكتبة والتراث والإصدارات', ['مكتبة الدير', 'المخطوطات الأثرية', 'ما كُتب عن دير أبو مقار', 'مطبوعات الدير', 'مجلة مرقس وأرشيفها', 'مؤلفات وعظات آباء الدير', 'المكتبة الرقمية']],
    ['خدمات الدير', ['بيت الخلوة', 'طلبات الصلاة', 'النذور والتبرعات', 'الزيارات', 'منتجات الدير']],
  ];
  $('#drawerNav').innerHTML = SECTIONS.map(([h, items], i) =>
    `<details${i === 0 ? ' open' : ''}><summary>${h}</summary><ul>${items.map((x) => `<li>${x}</li>`).join('')}</ul></details>`).join('');
  const drawer = $('#drawer'), scrim = $('#scrim');
  const setDrawer = (on) => { drawer.classList.toggle('open', on); scrim.classList.toggle('on', on); drawer.setAttribute('aria-hidden', String(!on)); };
  $('#menuBtn').onclick = () => setDrawer(true);
  $('#drawerClose').onclick = scrim.onclick = () => setDrawer(false);

  /* ---------- Top bar turns to leather after the hero ---------- */
  const bar = $('#topbar');
  // header stays fixed and visible (owner, 2026-11-04)
  // metallic light sweeping slowly across the header name
  if (hasGsap && !reduce) gsap.fromTo('#hdrLight', { attr: { azimuth: 160 } }, { attr: { azimuth: 330 }, duration: 6, ease: 'sine.inOut', yoyo: true, repeat: -1 });

  /* ---------- 0. Opening ---------- */
  const intro = $('#intro');
  function endIntro() { intro.remove(); startSlides(); revealAll(); }
  if (reduce || !hasGsap) { intro.remove(); }
  else {
    const seam = document.createElement('div'); seam.className = 'seam'; intro.appendChild(seam);
    const lines = gsap.utils.toArray('.intro-line');
    const tl = gsap.timeline({ onComplete: endIntro });
    gsap.set(lines, { opacity: 0, scale: 1.25, filter: 'blur(6px) drop-shadow(0 8px 10px rgba(0,0,0,.65))' });
    // fade + zoom in: background and each line; then fade + zoom out of the whole opening
    tl.fromTo('.intro-art', { scale: 1.14, opacity: 0 }, { scale: 1, opacity: 1, duration: 6.4, ease: 'power1.out' }, 0)
      .fromTo('.halo', { opacity: .15 }, { opacity: .85, duration: 2, ease: 'sine.inOut', yoyo: true, repeat: 2 }, .2)
      .to(lines, { opacity: 1, scale: 1, filter: 'blur(0px) drop-shadow(0 8px 10px rgba(0,0,0,.65))', duration: 1.4, ease: 'power2.out', stagger: .5 }, .5)
      .add(() => lines.forEach((l, k) => setTimeout(() => l.classList.add('shine'), k * 350)), 2.4)
      .to(intro, { opacity: 0, scale: 1.08, duration: 1.3, ease: 'power2.inOut' }, 5.2);
    intro.addEventListener('click', () => tl.progress(1));
  }

  /* ---------- 1. Cinematic slides ---------- */
  const PHOTOS = ['m1', 'm2', 'm3', 'm4', 'm5', 'm6', 'm7'];
  const slides = $('#slides'), prog = $('#slideProgress');
  const FOCUS = { m1: '50% 38%', m2: '50% 50%', m3: '50% 48%', m4: '50% 50%', m5: '50% 55%', m6: '50% 52%', m7: '50% 40%' };
  slides.innerHTML = PHOTOS.map((p) => `<img src="img/${p}.jpg" alt="" decoding="async" style="--focus:${FOCUS[p]}">`).join('');
  prog.innerHTML = PHOTOS.map(() => '<i><b></b></i>').join('');
  const imgs = [...slides.children], bars = [...prog.querySelectorAll('b')];
  const MOVES = [
    { from: { scale: 1.06, xPercent: 0, yPercent: 2 }, to: { scale: 1.2, xPercent: -3, yPercent: -2 } },
    { from: { scale: 1.22, xPercent: 3, yPercent: 0 }, to: { scale: 1.08, xPercent: -2, yPercent: 0 } },
    { from: { scale: 1.1, xPercent: -3, yPercent: 3 }, to: { scale: 1.22, xPercent: 3, yPercent: -1 } },
    { from: { scale: 1.18, xPercent: 0, yPercent: -3 }, to: { scale: 1.06, xPercent: 0, yPercent: 2 } },
  ];
  let slideStarted = false;
  function startSlides() {
    if (slideStarted) return; slideStarted = true;
    if (reduce || !hasGsap) { imgs[0].style.opacity = 1; return; }
    const HOLD = 6.5, FADE = 1.6;
    const tl = gsap.timeline({ repeat: -1 });
    imgs.forEach((img, i) => {
      const m = MOVES[i % MOVES.length];
      const t = i * HOLD;
      tl.set(img, { zIndex: i + 1 }, t)
        .fromTo(img, { opacity: 0, ...m.from }, { opacity: 1, duration: FADE, ease: 'sine.inOut' }, t)
        .to(img, { ...m.to, duration: HOLD + FADE, ease: 'none' }, t)
        .fromTo(bars[i], { width: '0%' }, { width: '100%', duration: HOLD, ease: 'none' }, t)
        .set(bars[i], { width: '0%' }, t + HOLD + .01);
    });
    tl.set(imgs, { opacity: 0 }, PHOTOS.length * HOLD);
  }
  if (!document.getElementById('intro')) startSlides();

  /* ---------- 2. Readings on the lectern ---------- */
  $('#dayLabel').textContent = D.day.label;
  const R = D.readings;
  const ref = (r) => `${r.book} ${ar(r.ref).replace(/:/g, ' : ').replace(/-/g, ' - ').replace(/,/g, '، ')}`;
  const GROUPS = [
    { tab: 'عشية', items: [R[0], R[1]] },
    { tab: 'باكر', items: [R[2], R[3]] },
    { tab: 'البولس', items: [R[4]] },
    { tab: 'الكاثوليكون', items: [R[5]] },
    { tab: 'الإبركسيس', items: [R[6]] },
    { tab: 'القداس', items: [R[7], R[8]] },
    { tab: 'السنكسار', synax: true },
  ];
  let current = 5; // Liturgy gospel first
  const tabs = $('#readingTabs');
  tabs.innerHTML = GROUPS.map((g, i) => `<button role="tab" data-i="${i}">${g.tab}</button>`).join('');
  const versesHtml = (r) => r.verses.map(([, v, t]) => `<span class="vn">${ar(v)}</span> ${esc(t)} `).join('');

  function fillPages(i) {
    const g = GROUPS[i];
    let right, left;
    if (g.synax) {
      const s = D.synaxarium;
      right = `<div class="p-label">السنكسار</div><div class="p-ref">${esc(s.heading)}</div><div class="p-orn"></div>${s.titles.map((t) => `<div>${esc(t)}</div>`).join('')}`;
      left = esc(s.text.join(' ').slice(0, 300)) + ' …';
    } else {
      const main = g.items[g.items.length - 1];
      const plain = main.verses.map(([, v, t]) => `${ar(v)} ${t}`).join(' ');
      const first = plain.replace(/^[٠-٩]+\s*/, '');
      const sp = first.indexOf(' ');
      right = `<div class="p-label">${main.label}</div><div class="p-ref">${esc(ref(main))}</div><div class="p-orn"></div>` +
        `<span class="lead">${esc(first.slice(0, sp))}</span>${esc(first.slice(sp, 120))}`;
      left = esc(first.slice(120, 380)) + ' …';
    }
    $('#pageRight').innerHTML = right;
    $('#pageLeft').innerHTML = left;
    [...tabs.children].forEach((b, k) => b.classList.toggle('on', k === i));
  }
  function selectReading(i) {
    if (i === current) return;
    const forward = i > current; current = i;
    if (reduce || !hasGsap) return fillPages(i);
    const leaf = $('#flipLeaf');
    gsap.timeline()
      .set(leaf, { opacity: 1, rotateY: forward ? 0 : -180, left: forward ? '49.5%' : '9%', right: forward ? '9%' : '50.5%', transformOrigin: forward ? '0% 50%' : '100% 50%' })
      .to('.page-inner', { opacity: 0, duration: .18 }, 0)
      .to(leaf, { rotateY: forward ? -180 : 0, duration: .75, ease: 'power2.inOut' }, 0)
      .add(() => fillPages(i), .38)
      .to('.page-inner', { opacity: 1, duration: .3 }, .45)
      .set(leaf, { opacity: 0 });
  }
  tabs.addEventListener('click', (e) => { const b = e.target.closest('button'); if (b) selectReading(+b.dataset.i); });
  fillPages(current);

  function readingHtml(i) {
    const g = GROUPS[i];
    let h = '';
    if (g.synax) {
      const s = D.synaxarium;
      h = `<h2>السنكسار</h2><p class="ref">${esc(s.heading)}</p><div class="orn"></div><ul class="synax-list">${s.titles.map((t) => `<li>${esc(t)}</li>`).join('')}</ul>` +
        `<div class="text">${s.text.map((p) => `<p>${esc(p)}</p>`).join('')}</div>`;
    } else {
      h = g.items.map((r) => `<h2>${r.label}</h2><p class="ref">${esc(ref(r))}</p><div class="orn"></div><div class="text"><p>${versesHtml(r)}</p></div>`).join('');
    }
    const prev = i > 0 ? `<button data-go="${i - 1}">‹ ${GROUPS[i - 1].tab}</button>` : '<span></span>';
    const next = i < GROUPS.length - 1 ? `<button data-go="${i + 1}">${GROUPS[i + 1].tab} ›</button>` : '<span></span>';
    return `<p class="ref" style="font-family:Display,serif">${D.day.label}</p>${h}<p class="ref" style="font-size:12px;margin-top:20px">${D.sources.readings}</p><div class="overlay-nav">${next}${prev}</div>`;
  }
  const overlay = $('#overlay'), oc = $('#overlayContent');
  function openOverlay(html) {
    oc.innerHTML = html; oc.scrollTop = 0; overlay.classList.add('open'); overlay.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
    if (hasGsap && !reduce) gsap.fromTo('.overlay-page', { opacity: 0, scale: .94, y: 20 }, { opacity: 1, scale: 1, y: 0, duration: .45, ease: 'power3.out' });
  }
  function closeOverlay() { overlay.classList.remove('open'); overlay.setAttribute('aria-hidden', 'true'); document.body.style.overflow = ''; }
  $('#overlayClose').onclick = closeOverlay;
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) closeOverlay();
    const go = e.target.closest('[data-go]');
    if (go) { current = +go.dataset.go; fillPages(current); openOverlay(readingHtml(current)); }
  });
  const openReading = () => openOverlay(readingHtml(current));
  $('#bookStage').onclick = openReading;
  $('#bookStage').onkeydown = (e) => { if (e.key === 'Enter') openReading(); };
  $('#openReading').onclick = (e) => { sheen(e.currentTarget); openReading(); };

  function sheen(btn) { btn.classList.remove('sheen'); void btn.offsetWidth; btn.classList.add('sheen'); }
  document.querySelectorAll('.btn-gold').forEach((b) => b.addEventListener('click', () => sheen(b)));

  /* Candle flicker (randomised, light on the book follows the flame) */
  if (!reduce && hasGsap) {
    document.querySelectorAll('.candle').forEach((c) => {
      const flame = c.querySelector('.flame'), glow = c.querySelector('.glow');
      const flick = () => {
        const s = .88 + Math.random() * .24;
        gsap.to(flame, { scaleY: s, scaleX: 2 - s - .05 + Math.random() * .1, skewX: (Math.random() - .5) * 8, duration: .08 + Math.random() * .14, ease: 'sine.inOut', onComplete: flick });
        gsap.to(glow, { opacity: .72 + Math.random() * .28, duration: .12, ease: 'sine.inOut' });
      };
      flick();
    });
  }

  /* ---------- 3–5. Sayings, renewed daily ---------- */
  const SAY = {
    macarius: { list: D.macarius.map((m) => m.text), i: dayNo % D.macarius.length, src: D.sources.macarius },
    matta: { list: D.matta, i: dayNo % D.matta.length, src: D.sources.matta },
  };
  function showSaying(key, animate) {
    const s = SAY[key];
    const el = $(`#${key}Text`);
    const set = () => { const t = s.list[s.i].trim(), sp = t.indexOf(' '); el.innerHTML = `<span class="lead">${esc(t.slice(0, sp))}</span>${esc(t.slice(sp))}`; $(`#${key}Src`).textContent = `${s.src} — ${ar(s.i + 1)} من ${ar(s.list.length)}`; };
    if (animate && hasGsap && !reduce) gsap.timeline().to(el, { opacity: 0, y: -8, duration: .25 }).add(set).to(el, { opacity: 1, y: 0, duration: .4 });
    else set();
  }
  showSaying('macarius'); showSaying('matta');
  document.querySelectorAll('[data-next]').forEach((b) => b.onclick = () => { const s = SAY[b.dataset.next]; s.i = (s.i + 1) % s.list.length; showSaying(b.dataset.next, true); });

  /* ---------- 6. News ---------- */
  const fmtDate = (iso) => { const [y, m, d] = iso.split('-').map(Number); return `${ar(d)} ${['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'][m - 1]} ${ar(y)}`; };
  const news = [...D.news].sort((a, b) => b.date.localeCompare(a.date));
  $('#newsRail').innerHTML = news.map((n, i) => {
    const lead = n.body.find((p) => !p.startsWith('[[')) || '';
    if (n.kind === 'warning') {
      return `<article class="news-card warning reveal" data-n="${i}"><div class="warn-paper"></div><div class="news-body"><span class="news-kicker">تحذير من الدير · ${fmtDate(n.date)}</span><h3>${esc(n.title)}</h3><p>${esc(lead)}</p></div>` +
        `<div class="wax-seal"><svg viewBox="0 0 100 100"><path d="M50 4c8 0 9 6 16 8s12-2 16 4 0 11 4 17 9 7 9 17-6 10-8 16 2 12-4 16-11 0-17 4-7 9-16 9-10-6-16-8-12 2-16-4 0-11-4-17-9-7-9-17 6-10 8-16-2-12 4-16 11 0 17-4 7-9 16-9z"/></svg><span>تحذير</span></div></article>`;
    }
    return `<article class="news-card reveal" data-n="${i}"><div class="news-photo" style="background-image:url(img/${n.images[0]})"><span class="news-date">${fmtDate(n.date)}</span></div>` +
      `<div class="news-body"><h3>${esc(n.title)}</h3><p>${esc(lead)}</p></div></article>`;
  }).join('');
  function articleHtml(n) {
    let fnCount = 0;
    const body = n.body.map((p) => {
      let m;
      if ((m = p.match(/^\[\[img:([^|]+)\|(.+)\]\]$/))) return `<figure><img src="img/${m[1]}" alt=""><figcaption>${esc(m[2])}</figcaption></figure>`;
      if ((m = p.match(/^\[\[fn:(\d+)(\+?)\]\]\s*([\s\S]*)$/))) return `<p class="fn" id="fn${m[1]}${m[2] ? 'b' : ''}">${m[2] ? '' : `(${ar(m[1])}) `}${esc(m[3])}</p>`;
      if ((m = p.match(/^\[\[letter:([^|]+)\|(.+)\]\]\n([\s\S]*)$/))) return `<div class="letter"><h3>${esc(m[1])}</h3>${m[3].split('\n').map((l) => `<p>${esc(l)}</p>`).join('')}<div class="sign">${esc(m[2])}</div></div>`;
      return `<p>${esc(p).replace(/\(\[(\d+)\]\)/g, (_, k) => { fnCount++; return `<sup><a href="#fn${k}">(${ar(k)})</a></sup>`; })}</p>`;
    }).join('');
    const facts = n.facts.length ? `<div class="facts">${n.facts.map((f) => `<span>${esc(f)}</span>`).join('')}</div>` : '';
    const lead = n.kind === 'repose' && n.images[0] ? `<figure><img src="img/${n.images[0]}" alt=""></figure>` : '';
    const fakes = n.kind === 'warning' ? n.images.map((f) => `<figure><span class="fake"><img src="img/${f}" alt="صفحة مزورة"></span></figure>`).join('') : '';
    return `<p class="ref">${fmtDate(n.date)}</p><h2>${esc(n.title)}</h2><div class="orn"></div>${facts}${lead}<div class="text">${body}</div>${fakes}`;
  }
  $('#newsRail').addEventListener('click', (e) => { const c = e.target.closest('[data-n]'); if (c) openOverlay(articleHtml(news[+c.dataset.n])); });

  /* ---------- Rising dust in the light (subtle) ---------- */
  (() => {
    const cv = document.getElementById('dust'); if (!cv || reduce) return;
    const ctx = cv.getContext('2d'); let W, H, dpr = Math.min(devicePixelRatio || 1, 2);
    const fit = () => { W = cv.width = innerWidth * dpr; H = cv.height = innerHeight * dpr; };
    fit(); addEventListener('resize', fit);
    const P = Array.from({ length: 34 }, () => ({ x: Math.random(), y: Math.random(), r: .6 + Math.random() * 1.6, v: .00006 + Math.random() * .00014, a: .15 + Math.random() * .35, w: Math.random() * 6.28 }));
    const tick = (t) => {
      ctx.clearRect(0, 0, W, H);
      for (const p of P) {
        p.y -= p.v * 16; if (p.y < -.02) { p.y = 1.02; p.x = Math.random(); }
        const x = (p.x + Math.sin(t / 4000 + p.w) * .01) * W, y = p.y * H;
        ctx.beginPath(); ctx.arc(x, y, p.r * dpr, 0, 6.283); ctx.fillStyle = `rgba(255,220,160,${p.a * (0.6 + 0.4 * Math.sin(t / 900 + p.w))})`; ctx.fill();
      }
      requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  })();

  /* ---------- Scroll reveals ---------- */
  let revealed = false;
  function revealAll() {
    if (revealed || reduce || !hasGsap || !window.ScrollTrigger) return; revealed = true;
    gsap.utils.toArray('.reveal').forEach((el) => {
      gsap.fromTo(el, { opacity: 0, y: 46 }, { opacity: 1, y: 0, duration: .9, ease: 'power3.out', scrollTrigger: { trigger: el, start: 'top 88%' } });
    });
    ScrollTrigger.create({ trigger: '#macarius', start: 'top bottom', once: true, onEnter: () => gsap.fromTo('.scroll-paper', { scaleX: .12 }, { scaleX: 1, duration: 1.3, ease: 'power3.out' }) });
    gsap.fromTo('#macarius .saying-body', { opacity: 0 }, { opacity: 1, duration: .8, delay: .6, scrollTrigger: { trigger: '#macarius', start: 'top 80%' } });
    gsap.fromTo('#macarius .wax-seal', { scale: 2.2, opacity: 0, rotate: -30 }, { scale: 1, opacity: 1, rotate: -8, duration: .7, delay: 1.1, ease: 'back.out(2)', scrollTrigger: { trigger: '#macarius', start: 'top 80%' } });
    const path = $('#routePath'); const len = path.getTotalLength();
    gsap.fromTo(path, { strokeDashoffset: len, strokeDasharray: `${len} ${len}` }, { strokeDashoffset: 0, duration: 2, ease: 'power2.inOut', scrollTrigger: { trigger: '.guide-card', start: 'top 80%' },
      onComplete: () => gsap.set(path, { strokeDasharray: '6 7' }) });
    gsap.from('.route circle', { scale: 0, transformOrigin: '50% 50%', stagger: .25, duration: .4, ease: 'back.out(3)', scrollTrigger: { trigger: '.guide-card', start: 'top 80%' } });
    gsap.to('.slides', { yPercent: 8, ease: 'none', scrollTrigger: { trigger: '.hero', start: 'top top', end: 'bottom top', scrub: true } });
    gsap.utils.toArray('.gold-text').forEach((el) => gsap.fromTo(el, { backgroundPosition: '0 -40px' }, { backgroundPosition: '0 0', duration: 1.2, scrollTrigger: { trigger: el, start: 'top 90%' } }));
  }
  if (!document.getElementById('intro')) revealAll();
})();

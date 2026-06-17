/* ════════════════════════════════════
   CleanYourMacKeyboard — app.js
   Fetches live GitHub data for stats,
   version, and download links.
   ════════════════════════════════════ */

const GITHUB_OWNER = 'kaushalboii';
const GITHUB_REPO  = 'cleanyourmackeyboard';
const API_BASE     = 'https://api.github.com';

/* ── Helpers ── */
function formatNum(n) {
  if (n == null || n === undefined) return '—';
  if (n >= 1000) return (n / 1000).toFixed(1) + 'k';
  return String(n);
}

function setEl(id, value) {
  const el = document.getElementById(id);
  if (el) el.textContent = value;
}

function setHref(id, url) {
  const el = document.getElementById(id);
  if (el && url) el.href = url;
}

/* ── Fetch repo metadata (stars, forks, watchers) ── */
async function fetchRepoStats() {
  try {
    const res = await fetch(`${API_BASE}/repos/${GITHUB_OWNER}/${GITHUB_REPO}`);
    if (!res.ok) throw new Error('Repo fetch failed');
    const data = await res.json();

    setEl('stat-stars',   formatNum(data.stargazers_count));
    setEl('os-stars',     formatNum(data.stargazers_count));
    setEl('os-forks',     formatNum(data.forks_count));
    setEl('os-watchers',  formatNum(data.watchers_count));
  } catch (e) {
    console.warn('[GitHub] Could not fetch repo stats:', e.message);
  }
}

/* ── Fetch latest release (version + download links + download count) ── */
async function fetchLatestRelease() {
  try {
    const res = await fetch(`${API_BASE}/repos/${GITHUB_OWNER}/${GITHUB_REPO}/releases/latest`);
    if (!res.ok) throw new Error('Release fetch failed');
    const data = await res.json();

    const version = data.tag_name || '—';
    setEl('stat-version',      version);
    setEl('dl-version-badge',  `Latest: ${version}`);

    // Count total downloads across all assets
    let totalDownloads = 0;
    let dmgUrl = null;
    let zipUrl = null;

    if (Array.isArray(data.assets)) {
      data.assets.forEach(asset => {
        totalDownloads += asset.download_count || 0;
        const name = asset.name.toLowerCase();
        if (!dmgUrl && name.endsWith('.dmg')) dmgUrl = asset.browser_download_url;
        if (!zipUrl && name.endsWith('.zip')) zipUrl = asset.browser_download_url;
      });
    }

    setEl('stat-downloads', formatNum(totalDownloads));

    // Set download button links
    const releasePageUrl = data.html_url || `https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/latest`;
    setHref('dmg-download-btn',  dmgUrl  || releasePageUrl);
    setHref('zip-download-btn',  zipUrl  || releasePageUrl);
    setHref('hero-download-btn', dmgUrl  || releasePageUrl);
    setHref('nav-download-btn',  dmgUrl  || releasePageUrl);

  } catch (e) {
    console.warn('[GitHub] Could not fetch latest release:', e.message);
    // Fallback: point all download buttons to releases page
    const fallback = `https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases`;
    ['dmg-download-btn', 'zip-download-btn', 'hero-download-btn', 'nav-download-btn'].forEach(id => setHref(id, fallback));
  }
}

/* ── Nav scroll effect ── */
function initNavScroll() {
  const nav = document.querySelector('.nav');
  if (!nav) return;
  window.addEventListener('scroll', () => {
    nav.style.borderBottomColor = window.scrollY > 20
      ? 'rgba(255,255,255,0.1)'
      : 'rgba(255,255,255,0.05)';
  }, { passive: true });
}

/* ── Smooth counter animation ── */
function animateCounters() {
  const counters = document.querySelectorAll('.stat-num');
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const el = entry.target;
        const rawText = el.textContent;
        // Only animate if numeric
        const num = parseFloat(rawText);
        if (!isNaN(num) && rawText !== '—' && rawText !== '100%') {
          let start = 0;
          const end = num;
          const duration = 1200;
          const startTime = performance.now();
          function update(currentTime) {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const eased = 1 - Math.pow(1 - progress, 3);
            const current = Math.round(eased * end);
            el.textContent = rawText.includes('k')
              ? (current / 1000).toFixed(1) + 'k'
              : String(current);
            if (progress < 1) requestAnimationFrame(update);
          }
          requestAnimationFrame(update);
        }
        observer.unobserve(el);
      }
    });
  }, { threshold: 0.5 });
  counters.forEach(c => observer.observe(c));
}

/* ── Scroll-reveal animation ── */
function initScrollReveal() {
  const style = document.createElement('style');
  style.textContent = `
    .reveal { opacity: 0; transform: translateY(24px); transition: opacity 0.6s ease, transform 0.6s ease; }
    .reveal.visible { opacity: 1; transform: translateY(0); }
    .reveal-delay-1 { transition-delay: 0.1s; }
    .reveal-delay-2 { transition-delay: 0.2s; }
    .reveal-delay-3 { transition-delay: 0.3s; }
  `;
  document.head.appendChild(style);

  const cards = document.querySelectorAll('.feature-card, .step, .dl-card, .os-card');
  cards.forEach((el, i) => {
    el.classList.add('reveal', `reveal-delay-${(i % 3) + 1}`);
  });

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.15 });

  document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
}

/* ── Init ── */
document.addEventListener('DOMContentLoaded', () => {
  fetchRepoStats();
  fetchLatestRelease();
  initNavScroll();
  initScrollReveal();
  // Slight delay to let DOM render before animating
  setTimeout(animateCounters, 500);
});

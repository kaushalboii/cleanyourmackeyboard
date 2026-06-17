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

/* ── Virtual Keyboard Interactive Simulator ── */
function initKeyboardSimulator() {
  const mockupStatus = document.getElementById('mockup-status');
  const statusDot = document.getElementById('mockup-status-dot');
  const statusText = document.getElementById('mockup-status-text');
  const mockupLockBtn = document.getElementById('mockup-lock-btn');
  const mockupKeyboard = document.getElementById('mockup-keyboard');
  const mockupOverlay = document.getElementById('mockup-overlay');
  const blockedCountText = document.getElementById('blocked-count-text');
  const keyboardContainer = document.querySelector('.mockup-keyboard-container');
  
  if (!mockupLockBtn || !mockupKeyboard || !keyboardContainer) return;

  const lockIconContainer = mockupOverlay.querySelector('.lock-icon-container');
  let isLocked = false;
  let blockedCount = 0;

  function toggleLock() {
    isLocked = !isLocked;
    if (isLocked) {
      keyboardContainer.classList.add('locked');
      mockupLockBtn.textContent = 'UNLOCK KEYBOARD';
      if (statusText) statusText.textContent = 'LOCK ACTIVE';
      if (statusDot) {
        statusDot.style.background = '#ffffff';
        statusDot.style.boxShadow = '0 0 8px #ffffff';
      }
      if (blockedCountText) {
        blockedCountText.textContent = 'Keyboard is locked • Keys are safe to clean';
      }
    } else {
      isLocked = false;
      blockedCount = 0;
      keyboardContainer.classList.remove('locked');
      mockupLockBtn.textContent = 'LOCK KEYBOARD';
      if (statusText) statusText.textContent = 'UNLOCKED & READY';
      if (statusDot) {
        statusDot.style.background = '';
        statusDot.style.boxShadow = '';
      }
      // Clear active styles
      mockupKeyboard.querySelectorAll('.key').forEach(k => k.classList.remove('active'));
    }
  }

  mockupLockBtn.addEventListener('click', toggleLock);

  // Keyboard Event Handlers
  window.addEventListener('keydown', (e) => {
    // Skip if focus is on interactive inputs
    if (document.activeElement.tagName === 'INPUT' || document.activeElement.tagName === 'TEXTAREA') {
      return;
    }

    const keyCode = e.code;
    const keyEl = mockupKeyboard.querySelector(`[data-key="${keyCode}"]`);

    if (isLocked) {
      // Prevent browser default actions except important system/tab controls
      if (!e.metaKey && !e.ctrlKey) {
        e.preventDefault();
      }

      blockedCount++;
      if (blockedCountText) {
        blockedCountText.textContent = `Blocked ${blockedCount} keystrokes`;
      }
      
      // Pulse animation on lock icon container
      if (lockIconContainer) {
        lockIconContainer.classList.remove('pulse');
        void lockIconContainer.offsetWidth; // Trigger reflow
        lockIconContainer.classList.add('pulse');
        setTimeout(() => {
          lockIconContainer.classList.remove('pulse');
        }, 120);
      }
    } else {
      if (keyEl) {
        keyEl.classList.add('active');
        
        // Prevent key down scrolls (spacebar / arrows) while typing on virtual layout
        if (['Space', 'ArrowUp', 'ArrowDown', 'Tab'].includes(keyCode)) {
          e.preventDefault();
        }
      }
    }
  });

  window.addEventListener('keyup', (e) => {
    if (isLocked) return;
    const keyCode = e.code;
    const keyEl = mockupKeyboard.querySelector(`[data-key="${keyCode}"]`);
    if (keyEl) {
      keyEl.classList.remove('active');
    }
  });

  // Clear stuck keys when focus leaves the window
  window.addEventListener('blur', () => {
    if (!isLocked) {
      mockupKeyboard.querySelectorAll('.key').forEach(k => k.classList.remove('active'));
    }
  });
}

/* ── Init ── */
document.addEventListener('DOMContentLoaded', () => {
  fetchRepoStats();
  fetchLatestRelease();
  initNavScroll();
  initScrollReveal();
  initKeyboardSimulator();
  // Slight delay to let DOM render before animating
  setTimeout(animateCounters, 500);
});

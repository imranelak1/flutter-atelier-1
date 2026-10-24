'use strict';

// Run from the repository root after building both Flutter Web applications.
// Uses the installed Google Chrome; no Playwright browser download is needed.
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const { chromium } = require('playwright');
const { PNG } = require('pngjs');

const root = path.resolve(__dirname, '..');
const output = path.join(root, 'docs', 'screenshots');
const apps = [
  { name: 'atelier1', port: 8765 },
  { name: 'profil_etudiant', port: 8766 },
];
const captures = [
  { file: 'exercice-a.png', app: 'atelier1', query: 'exercise=a&theme=light', width: 390, height: 844 },
  { file: 'exercice-b.png', app: 'atelier1', query: 'exercise=b&theme=light', width: 390, height: 844 },
  { file: 'exercice-c.png', app: 'atelier1', query: 'exercise=c&theme=light', width: 430, height: 1000 },
  { file: 'atelier-clair.png', app: 'atelier1', query: 'exercise=d&theme=light', width: 430, height: 1100 },
  { file: 'atelier-sombre.png', app: 'atelier1', query: 'exercise=d&theme=dark', width: 430, height: 1100 },
  { file: 'atelier-violet.png', app: 'atelier1', query: 'exercise=d&theme=light&seed=0xFF7C3AED', width: 430, height: 1100 },
  { file: 'alignements.png', app: 'atelier1', query: 'exercise=alignments&theme=light', width: 430, height: 1800 },
  { file: 'profil-clair.png', app: 'profil_etudiant', query: 'theme=light', width: 390, height: 844 },
  { file: 'profil-sombre.png', app: 'profil_etudiant', query: 'theme=dark', width: 390, height: 844 },
  { file: 'profil-desktop.png', app: 'profil_etudiant', query: 'theme=light', width: 1100, height: 850 },
];
const mimeTypes = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.wasm': 'application/wasm',
  '.css': 'text/css; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
};

function serveApp(app) {
  const buildRoot = path.join(root, app.name, 'build', 'web');
  if (!fs.existsSync(path.join(buildRoot, 'index.html'))) {
    throw new Error(`Missing ${app.name}/build/web/index.html. Run flutter build web in both app directories first.`);
  }
  const server = http.createServer((request, response) => {
    let pathname;
    try {
      pathname = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
    } catch {
      response.writeHead(400).end('Invalid request path');
      return;
    }
    const file = path.resolve(buildRoot, `.${pathname.endsWith('/') ? `${pathname}index.html` : pathname}`);
    if (!file.startsWith(`${buildRoot}${path.sep}`)) {
      response.writeHead(403).end('Forbidden');
      return;
    }
    fs.stat(file, (error, stat) => {
      if (error || !stat.isFile()) {
        response.writeHead(404).end('Not found');
        return;
      }
      response.writeHead(200, {
        'Content-Type': mimeTypes[path.extname(file).toLowerCase()] || 'application/octet-stream',
        'Content-Length': stat.size,
        'Cache-Control': 'no-store',
      });
      fs.createReadStream(file).pipe(response);
    });
  });
  return new Promise((resolve, reject) => {
    server.once('error', reject);
    server.listen(app.port, '127.0.0.1', () => resolve(server));
  });
}

function imageStats(buffer) {
  const png = PNG.sync.read(buffer);
  const colors = new Set();
  const background = Array.from(png.data.subarray(0, 3));
  let changed = 0;
  let samples = 0;
  // Sample the full viewport, preserving text and widget details at this scale.
  for (let y = 0; y < png.height; y += 3) {
    for (let x = 0; x < png.width; x += 3) {
      const offset = (y * png.width + x) * 4;
      const [r, g, b] = png.data.subarray(offset, offset + 3);
      colors.add((r << 16) | (g << 8) | b);
      if (Math.abs(r - background[0]) + Math.abs(g - background[1]) + Math.abs(b - background[2]) > 35) changed++;
      samples++;
    }
  }
  const stats = { width: png.width, height: png.height, sampledColors: colors.size, nonBackgroundFraction: changed / samples };
  if (stats.sampledColors < 16 || stats.nonBackgroundFraction < 0.01) {
    throw new Error(`Screenshot appears blank: ${JSON.stringify(stats)}`);
  }
  return stats;
}

async function main() {
  fs.mkdirSync(output, { recursive: true });
  const servers = [];
  let browser;
  const report = {
    generatedAt: new Date().toISOString(),
    renderer: 'Flutter Web running in headless Google Chrome',
    deviceScaleFactor: 1,
    playwrightVersion: require('playwright/package.json').version,
    browserVersion: null,
    captures: [],
    status: 'running',
  };
  try {
    for (const app of apps) servers.push(await serveApp(app));
    browser = await chromium.launch({ channel: 'chrome', headless: true, args: ['--enable-unsafe-swiftshader'] });
    report.browserVersion = browser.version();
    for (const capture of captures) {
      const app = apps.find((entry) => entry.name === capture.app);
      const url = `http://127.0.0.1:${app.port}/?${capture.query}`;
      const context = await browser.newContext({
        viewport: { width: capture.width, height: capture.height },
        deviceScaleFactor: 1,
        locale: 'fr-FR',
        colorScheme: capture.query.includes('theme=dark') ? 'dark' : 'light',
        reducedMotion: 'reduce',
      });
      const page = await context.newPage();
      const errors = [];
      page.on('pageerror', (error) => errors.push({ type: 'pageerror', message: error.message }));
      page.on('console', (message) => {
        if (message.type() === 'error') errors.push({ type: 'console.error', message: message.text() });
      });
      const entry = { file: capture.file, app: capture.app, url, viewport: { width: capture.width, height: capture.height }, errors };
      report.captures.push(entry);
      try {
        await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 });
        await page.locator('flutter-view, flt-glass-pane').first().waitFor({ state: 'attached', timeout: 45000 });
        // The Flutter engine can attach its host before the first rasterized frame.
        await page.waitForTimeout(4000);
        const buffer = await page.screenshot({ path: path.join(output, capture.file), fullPage: false, animations: 'disabled' });
        entry.image = imageStats(buffer);
        if (errors.length) throw new Error(`${capture.file} emitted runtime errors: ${JSON.stringify(errors)}`);
        entry.status = 'passed';
        console.log(`${capture.file}: ${capture.width}×${capture.height}, ${entry.image.sampledColors} sampled colors, no runtime errors`);
      } catch (error) {
        entry.status = 'failed';
        entry.failure = error.message;
        throw error;
      } finally {
        await context.close();
      }
    }
    report.status = 'passed';
  } catch (error) {
    report.status = 'failed';
    report.failure = error.message;
    throw error;
  } finally {
    fs.writeFileSync(path.join(output, 'capture-report.json'), `${JSON.stringify(report, null, 2)}\n`);
    if (browser) await browser.close();
    await Promise.all(servers.map((server) => new Promise((resolve) => server.close(resolve))));
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});

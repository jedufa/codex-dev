const {test, expect} = require('@playwright/test');
const fs = require('node:fs');
const path = require('node:path');

test('real simulated chat, progress, tab drafts and reconnect work offline', async ({page, context}) => {
  const external = [], errors = [], nonStatic = [];
  const root = path.resolve('build/web');
  const staticFiles = new Set();
  const walk = dir => {for (const e of fs.readdirSync(dir,{withFileTypes:true})) {const f=path.join(dir,e.name);if(e.isDirectory())walk(f);else staticFiles.add('/'+path.relative(root,f).split(path.sep).join('/'));}};
  walk(root);
  staticFiles.add('/');
  page.on('pageerror', e => errors.push(e.message));
  page.on('request', r => {if (!r.url().startsWith('http://127.0.0.1:41763/') && !r.url().startsWith('blob:') && !r.url().startsWith('data:')) external.push(r.url());});
  await page.route('**/*', route => {const r=route.request(), u=new URL(r.url());if(u.origin==='http://127.0.0.1:41763' && !u.search && r.method()==='GET' && staticFiles.has(u.pathname)) return route.continue();nonStatic.push(r.url());return route.abort();});
  await page.goto('http://127.0.0.1:41763/');
  await expect(page.getByText('SIMULATED DEMO · NO LIVE CODEX CONNECTION', {exact:true})).toBeVisible();
  await expect(page.getByText('Here is a fictional starting point.', {exact:false})).toBeVisible();
  const capture = async name => {
    if (!process.env.CAPTURE_DIR) return;
    fs.mkdirSync(process.env.CAPTURE_DIR,{recursive:true});
    await page.screenshot({path:path.join(process.env.CAPTURE_DIR,`${name}.png`)});
  };
  await capture('chat');
  await page.getByRole('textbox').click();
  await page.getByRole('textbox').fill('Make a small plan for the garden notes.');
  await page.getByRole('button',{name:'Send',exact:true}).click();
  await expect(page.getByText('Simulated progress · no tools are running', {exact:true}).first()).toBeVisible();
  await capture('progress');
  await expect(page.getByText('Simulated reply: your request stays in memory.',{exact:false})).toBeVisible();
  await capture('reply');
  // The first turn loads the bundled symbol font, a static renderer asset.
  // Subsequent operations run with all network entry points denied.
  await page.waitForFunction(() => performance.getEntriesByType('resource').some(e => e.name.includes('font-fallback/')));
  await page.evaluate(() => {
    window.__ioAttempts=[];
    for (const name of ['fetch','XMLHttpRequest','WebSocket','EventSource']) window[name]=function(...args){window.__ioAttempts.push({name, url:String(args[0])});throw Error('Runtime network forbidden');};
    navigator.sendBeacon=()=>{window.__ioAttempts.push('beacon');return false;};
  });
  await context.setOffline(true);

  await page.getByRole('textbox').click();
  await page.getByRole('textbox').fill('A draft for C1');
  await page.getByRole('button',{name:'C2',exact:true}).click();
  await page.getByRole('textbox').click();
  await expect(page.getByRole('textbox')).toHaveValue('');
  await page.getByRole('button',{name:'C1',exact:true}).click();
  await page.getByRole('textbox').click();
  await expect(page.getByRole('textbox')).toHaveValue('A draft for C1');
  await page.getByRole('button',{name:'Demo settings',exact:true}).click();
  await page.getByRole('button',{name:'Simulate disconnect',exact:true}).click();
  await expect(page.getByText('Simulation disconnected',{exact:true})).toBeVisible();
  await capture('reconnect');
  await page.getByRole('button',{name:'Reconnect simulation',exact:true}).click();
  await page.getByRole('button',{name:'Open navigation',exact:true}).click();
  await page.getByRole('button',{name:'Chat',exact:true}).click();
  await page.getByRole('textbox').click();
  await expect(page.getByRole('textbox')).toHaveValue('A draft for C1');
  await expect(page.getByText('Simulated reply: your request stays in memory.',{exact:false})).toBeVisible();
  await page.getByRole('button',{name:'Send',exact:true}).click();
  await expect(page.getByText('Simulated reply: your request stays in memory.',{exact:false}).last()).toBeVisible();
  await expect(page.getByRole('button',{name:'Stop Codex turn',exact:true})).toHaveCount(0);
  expect(nonStatic).toEqual([]);
  expect(await page.evaluate(()=>window.__ioAttempts)).toEqual([]);
  expect(external).toEqual([]);
  expect(errors).toEqual([]);
});

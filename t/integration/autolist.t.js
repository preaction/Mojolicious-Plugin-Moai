#!/usr/bin/env node
import t from 'tap';
import ServerStarter from '@mojolicious/server-starter';
import { chromium } from 'playwright';

t.test('Test the autolist', async t => {
  const server = await ServerStarter.newServer();
  await server.launch('perl', ['-Ilib', 't/wrappers/autolist.pl']);
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  page.on('console', msg => console.log(msg.text()));
  page.on('pageerror', exception => {
    t.fail(`Uncaught exception: "${exception}"`);
  });
  const url = server.url();

  await t.test('Click "more" link to get more', async t => {
    await page.goto(url + '?$limit=3');

    await page.click('button[data-more]')
    const newItem = page.locator('[data-list-wrapper] :nth-child(4)')
    t.equal(await newItem.innerHTML(), 'Brittany')

    await page.click('button[data-more]')
    const anotherItem = page.locator('[data-list-wrapper] :nth-child(7)')
    t.equal(await anotherItem.innerHTML(), 'Linda')
  });

  await t.test('Render links correctly', async t => {
    await page.goto(url + '/links?$limit=3');

    await page.click('button[data-more]')
    const newItem = page.locator('[data-list-wrapper] :nth-child(4)')
    t.equal(await newItem.innerHTML(), 'Brittany')
    t.equal(await newItem.getAttribute('href'), '/user/4')

    await page.click('button[data-more]')
    const anotherItem = page.locator('[data-list-wrapper] :nth-child(7)')
    t.equal(await anotherItem.innerHTML(), 'Linda')
    t.equal(await anotherItem.getAttribute('href'), '/user/7')
  });

  await t.test('Render links and arbitrary content', async t => {
    await page.goto(url + '/content?$limit=3');

    await page.click('button[data-more]')
    const newItem = page.locator('[data-list-wrapper] :nth-child(4)')
    t.equal(await newItem.innerHTML(), 'Brittany (4)')
    t.equal(await newItem.getAttribute('href'), '/user/4')

    await page.click('button[data-more]')
    const anotherItem = page.locator('[data-list-wrapper] :nth-child(7)')
    t.equal(await anotherItem.innerHTML(), 'Linda (7)')
    t.equal(await anotherItem.getAttribute('href'), '/user/7')
  });

  await context.close();
  await browser.close();
  await server.close();
});

#!/usr/bin/env -S npx playwright test
import ServerStarter from '@mojolicious/server-starter';
import { test, expect } from '@playwright/test';

let server = null
test.beforeAll(async () => {
  server = await ServerStarter.newServer();
  await server.launch('perl', ['-Ilib', 't/wrappers/autolist.pl']);
})
test.afterAll(async () => {
  await server.close();
})

test.beforeEach(({page}) => {
  page.on('console', msg => console.log(msg.text()));
  page.on('pageerror', exception => {
    console.log(`Uncaught exception: "${exception}"`);
  });
});

test.describe('Test the autolist', () => {
  test('Click "more" link to get more', async ({page}) => {
    const url = server.url();
    await page.goto(url + '?$limit=3');

    await page.click('button[data-more]')
    const newItem = page.locator('[data-list-wrapper] :nth-child(4)', {hasText: 'Brittany'})
    await expect(newItem).toContainText('Brittany')

    await page.click('button[data-more]')
    const anotherItem = page.locator('[data-list-wrapper] :nth-child(7)')
    await expect(anotherItem).toContainText('Linda')
  });

  test('Render links correctly', async ({page}) => {
    const url = server.url();
    await page.goto(url + '/links?$limit=3');

    await page.click('button[data-more]')
    const newItem = page.locator('[data-list-wrapper] :nth-child(4)')
    await expect(newItem).toContainText('Brittany')
    await expect(newItem).toHaveAttribute('href', '/user/4')

    await page.click('button[data-more]')
    const anotherItem = page.locator('[data-list-wrapper] :nth-child(7)')
    await expect(anotherItem).toContainText('Linda')
    await expect(anotherItem).toHaveAttribute('href', '/user/7')
  });

  test('Render links and arbitrary content', async ({page}) => {
    const url = server.url();
    await page.goto(url + '/content?$limit=3');

    await page.click('button[data-more]')
    const newItem = page.locator('[data-list-wrapper] :nth-child(4)')
    await expect(newItem).toContainText('Brittany (4)')
    await expect(newItem).toHaveAttribute('href', '/user/4')

    await page.click('button[data-more]')
    const anotherItem = page.locator('[data-list-wrapper] :nth-child(7)')
    await expect(anotherItem).toContainText('Linda (7)')
    await expect(anotherItem).toHaveAttribute('href', '/user/7')
  });
});

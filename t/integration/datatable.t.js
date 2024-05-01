#!/usr/bin/env -S npx playwright test
import ServerStarter from '@mojolicious/server-starter';
import { test, expect } from '@playwright/test';

let server = null
test.beforeAll(async () => {
  server = await ServerStarter.newServer();
  await server.launch('perl', ['-Ilib', 't/wrappers/datatable.pl']);
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

test.describe('Test the data table', async () => {
  test('show filter above table', async ({page}) => {
    const url = server.url();
    await page.goto(url);
    expect(page.url()).toBe(url + '/');
    await expect(page.locator('form input[name=name]')).toBeEnabled()
    await expect(page.locator('form select[name=grade]')).toBeEnabled()
    await expect(page.locator('moai-pager [aria-current]')).toContainText('1')

    // Input string filter
    await page.locator('form input[name=name]').fill('in')
    await page.locator('form button').click()
    // Linda and Tina remain
    await expect(page.locator('tbody tr:nth-child(1) td:nth-child(2)')).toContainText('Linda')
    await expect(page.locator('tbody tr:nth-child(2) td:nth-child(2)')).toContainText('Tina')
    // Pager shows correct pages (1, the current)
    await expect(page.locator('moai-pager [aria-current]')).toContainText('1')

    // Input grade filter
    await page.locator('form select[name=grade]').selectOption('D')
    await page.locator('form button').click()
    // Only Tina remains
    await expect(page.locator('tbody tr:nth-child(1) td:nth-child(2)')).toContainText('Tina')
    // Pager shows correct pages (1, the current)
    await expect(page.locator('moai-pager [aria-current]')).toContainText('1')

    // Back button works
    await page.goBack();
    // Linda and Tina remain
    await expect( page.locator('tbody tr:nth-child(1) td:nth-child(2)')).toContainText('Linda')
    await expect( page.locator('tbody tr:nth-child(2) td:nth-child(2)')).toContainText('Tina')
    // Pager shows correct pages (1, the current)
    await expect(page.locator('moai-pager [aria-current]')).toContainText('1')

    // Back button works twice
    await page.goBack();
    // Linda and Tina remain
    await expect( page.locator('tbody tr:nth-child(1) td:nth-child(2)')).toContainText('Doug')
    // Pager shows correct pages (2)
    await expect(page.locator('moai-pager [aria-current]')).toContainText('1')
  });

  // Navigate pages
  test('navigate pager', async ({page}) => {
    const url = server.url();
    await page.goto(url);
    const pageLink = page.getByRole('link', {name: '2'});
    await expect(pageLink).toContainText('2');
    await pageLink.click();

    await expect(page.locator('tbody tr:nth-child(1) td:nth-child(2)')).toContainText('Rudy')
    await expect(page.locator('tbody tr:nth-child(2) td:nth-child(2)')).toContainText('Darryl')
    await expect(page.locator('tbody tr:nth-child(3) td:nth-child(2)')).toContainText('Jimmy Jr.')
    // Pager updated: 2 is current, 1 is link
    await expect(page.locator('moai-pager [aria-current]')).toContainText('2')

    // Back button works
    await page.goBack();
    await expect(page.locator('tbody tr:nth-child(1) td:nth-child(2)', {hasText: 'Doug'})).toContainText('Doug')
    // Pager updated: 1 is current, 2 is link
    await expect(page.locator('moai-pager [aria-current]')).toContainText('1')
  });

  // XXX: Sorting

  test('disabled javascript still works', async ({page}) => {
    const url = server.url();
    await page.goto(url + '/?javascript=0');
    await expect(page.locator('form input[name=name]')).toBeEnabled()
    await expect(page.locator('form select[name=grade]')).toBeEnabled()

    // XXX: Pagination
    // XXX: Sorting

    // input string filter
    await page.locator('form input[name=name]').fill('in')
    await page.locator('form button').click()
    // Linda and Tina remain
    await expect(page.locator('tbody tr:nth-child(1) td:nth-child(2)', { hasText: 'Linda' })).toContainText('Linda')
    await expect(page.locator('tbody tr:nth-child(2) td:nth-child(2)', { hasText: 'Tina' })).toContainText('Tina')
  });
});

import { PlaywrightTestConfig } from '@playwright/test';
const config: PlaywrightTestConfig = {
  reporter: '@yancyjs/tap-playwright',
  testMatch: /.*\.t\.js$/,
};
export default config;

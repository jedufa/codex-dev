const {defineConfig} = require('@playwright/test');
module.exports = defineConfig({
  testDir: 'tests/browser', workers: 1, retries: 0,
  use: {browserName: 'chromium', viewport: {width:430,height:850}, locale:'en-GB', timezoneId:'UTC', colorScheme:'light'},
  webServer: {command:'python3 -m http.server 41763 --bind 127.0.0.1 --directory build/web', url:'http://127.0.0.1:41763', reuseExistingServer:false},
});

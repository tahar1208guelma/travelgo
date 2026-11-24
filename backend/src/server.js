/**
 * @file server.js
 * @description TravelGo Backend Gateway Server Entrypoint.
 */

import { createApp } from './app.js';
import { config, validateProductionConfig } from './config/environment.js';

const validation = validateProductionConfig();
if (!validation.isValid) {
  console.warn('[WARNING] Configuration warnings detected:', validation.issues);
}

const app = createApp();

app.listen(config.port, config.host, () => {
  console.log(`=======================================================`);
  console.log(` TravelGo Secure Backend API Gateway running`);
  console.log(` Port: ${config.port} | Mode: ${config.env}`);
  console.log(` Address: http://${config.host}:${config.port}`);
  console.log(` Security: Zero Client Secrets Enforced`);
  console.log(` Rate Limiting: Active (Global: ${config.rateLimit.maxGeneral} req/min)`);
  console.log(` Commission: Standard Direct Platform Fee $${config.commission.standardDirectFeeUSD.toFixed(2)} USD`);
  console.log(`=======================================================`);
});

process.on('SIGTERM', () => {
  console.log('Received SIGTERM, closing gateway server...');
  app.close(() => {
    process.exit(0);
  });
});

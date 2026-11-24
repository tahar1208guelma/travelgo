/**
 * @file zero_client_secrets.test.js
 * @description Automated Security Audit Test: Scans the entire Flutter client codebase
 * to assert that zero third-party private API keys, payment secrets, or secret tokens are bundled in the client.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';

function findDartFiles(dir, fileList = []) {
  if (!fs.existsSync(dir)) return fileList;
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      findDartFiles(fullPath, fileList);
    } else if (file.endsWith('.dart')) {
      fileList.push(fullPath);
    }
  }
  return fileList;
}

test('Security Audit - Zero Client Secrets Verification', async (t) => {
  const libDir = path.resolve(process.cwd(), 'lib');
  const dartFiles = findDartFiles(libDir);

  assert(dartFiles.length > 0, 'Flutter lib/ directory must contain Dart source files');

  // Patterns for private keys / secrets that MUST NEVER appear in client Dart files
  const secretPatterns = [
    /sk_live_[0-9a-zA-Z]{24,}/,             // Stripe live secret key
    /sk_test_[0-9a-zA-Z]{24,}/,             // Stripe test secret key
    /AIzaSy[0-9A-Za-z-_]{33}/,              // Live Google API private key
    /AMADEUS_CLIENT_SECRET\s*=\s*['"][^'"]+['"]/, // Hardcoded Amadeus secret
    /DUFFEL_ACCESS_TOKEN\s*=\s*['"]duffel_live_[^'"]+['"]/, // Duffel live token
    /STRIPE_SECRET_KEY\s*=\s*['"][^'"]+['"]/
  ];

  await t.test('scans all Flutter client dart files for secret patterns', () => {
    const violations = [];

    for (const filePath of dartFiles) {
      const content = fs.readFileSync(filePath, 'utf8');
      for (const pattern of secretPatterns) {
        if (pattern.test(content)) {
          violations.push({
            file: path.relative(process.cwd(), filePath),
            pattern: pattern.toString()
          });
        }
      }
    }

    assert.equal(
      violations.length,
      0,
      `Found ${violations.length} secret violation(s) in client source:\n` +
      JSON.stringify(violations, null, 2)
    );
  });
});

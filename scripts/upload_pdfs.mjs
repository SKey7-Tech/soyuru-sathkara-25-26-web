/**
 * Uploads the website's PDFs into the Supabase Storage 'resources' bucket,
 * at exactly the storage_path values seeded by supabase/seed/001_seed_content.sql.
 *
 * Deliberately has ZERO dependencies — it uses the Storage REST API through
 * Node's built-in fetch instead of @supabase/supabase-js, so there is nothing
 * to npm install and nothing added to the website's bundle.
 *
 * Requires Node 18+.
 *
 * Usage (PowerShell, from the repo root):
 *   $env:SUPABASE_URL = "https://atvpbxxzpnhjtsuuzmfu.supabase.co"
 *   $env:SUPABASE_SERVICE_ROLE_KEY = "<service_role key>"
 *   node scripts/upload_pdfs.mjs
 *
 * ⚠ The service_role key bypasses RLS entirely. Never put it in the Flutter
 *   app, never commit it, never ship it to a browser. It belongs in your
 *   shell for the duration of this script and nowhere else.
 */

import { readFile } from 'node:fs/promises';
import { statSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const BUCKET = 'resources';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

/**
 * localPath  -> where the file lives in this repo
 * storagePath -> must match papers.storage_path in the seed script
 * seededBytes -> the size_bytes value in the seed script, verified before upload
 */
const FILES = [
  { localPath: 'public/files/papers/Easy-Level.pdf',        storagePath: 'papers/Easy-Level.pdf',        seededBytes: 6680967 },
  { localPath: 'public/files/papers/Easy-paper-tamil.pdf',  storagePath: 'papers/Easy-paper-tamil.pdf',  seededBytes: 753803 },
  { localPath: 'public/files/papers/Medium-Level.pdf',      storagePath: 'papers/Medium-Level.pdf',      seededBytes: 8593020 },
  { localPath: 'public/files/papers/Medium_paper_tamil.pdf', storagePath: 'papers/Medium_paper_tamil.pdf', seededBytes: 458626 },
  { localPath: 'public/files/papers/Hard-Level.pdf',        storagePath: 'papers/Hard-Level.pdf',        seededBytes: 8433517 },
  { localPath: 'public/files/short-notes/Short-Note.pdf',   storagePath: 'short-notes/Short-Note.pdf',   seededBytes: 8173217 },
];

function die(msg) {
  console.error(`\n✖ ${msg}\n`);
  process.exit(1);
}

if (!SUPABASE_URL) die('SUPABASE_URL is not set.');
if (!SERVICE_KEY) die('SUPABASE_SERVICE_ROLE_KEY is not set.');
if (SERVICE_KEY.length < 40) die('SUPABASE_SERVICE_ROLE_KEY looks too short — did you paste the anon key by mistake?');

// Fail before uploading anything if the repo and the seed script disagree.
// A size mismatch means someone replaced a PDF without updating the seed,
// and the app would then show a wrong "8.2 MB" label next to the download.
const mismatches = [];
for (const f of FILES) {
  const abs = join(ROOT, f.localPath);
  let actual;
  try {
    actual = statSync(abs).size;
  } catch {
    mismatches.push(`${f.localPath} — file not found`);
    continue;
  }
  if (actual !== f.seededBytes) {
    mismatches.push(`${f.localPath} — on disk ${actual} B, seed says ${f.seededBytes} B`);
  }
}
if (mismatches.length) {
  die(
    `Refusing to upload. Fix these first, then update size_bytes in\n` +
    `  supabase/seed/001_seed_content.sql\n\n  ` +
    mismatches.join('\n  ')
  );
}

console.log(`Uploading ${FILES.length} PDFs to ${SUPABASE_URL} → bucket "${BUCKET}"\n`);

let failed = 0;
for (const f of FILES) {
  const body = await readFile(join(ROOT, f.localPath));
  const url = `${SUPABASE_URL}/storage/v1/object/${BUCKET}/${f.storagePath}`;

  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${SERVICE_KEY}`,
      'Content-Type': 'application/pdf',
      // Makes the script re-runnable: overwrite instead of erroring with
      // "Duplicate" the second time you run it.
      'x-upsert': 'true',
      'cache-control': 'public, max-age=31536000, immutable',
    },
    body,
  });

  const mb = (body.byteLength / 1048576).toFixed(2);
  if (res.ok) {
    console.log(`  ✓ ${f.storagePath.padEnd(34)} ${mb.padStart(6)} MB`);
  } else {
    failed++;
    console.error(`  ✖ ${f.storagePath.padEnd(34)} ${res.status} ${await res.text()}`);
  }
}

if (failed) {
  die(`${failed} upload(s) failed. If you see "Bucket not found", run supabase/migrations/004_storage.sql first.`);
}

console.log(`\n✓ Done. Verify one in a browser — public bucket, so this URL should just work:`);
console.log(`  ${SUPABASE_URL}/storage/v1/object/public/${BUCKET}/${FILES[0].storagePath}\n`);

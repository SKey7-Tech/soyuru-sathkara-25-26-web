/**
 * Environment lookup for the Supabase clients.
 *
 * Fails with an explanation rather than a confusing error deep inside the SDK
 * when a variable is missing — the same philosophy as Env.isConfigured in the
 * Flutter app (mobile/lib/core/env.dart).
 */

function required(name: string, value: string | undefined): string {
  if (!value) {
    throw new Error(
      `${name} is not set. Add it to web/.env.local — see docs/setup.md. ` +
        `Restart the dev server after editing .env.local; Next.js does not pick ` +
        `up env changes on hot reload.`
    );
  }
  return value;
}

/** Browser-exposed. Safe to ship — RLS is what protects the data. */
export const supabaseUrl = () =>
  required('NEXT_PUBLIC_SUPABASE_URL', process.env.NEXT_PUBLIC_SUPABASE_URL);

/** Browser-exposed publishable (anon) key. Safe to ship. */
export const supabaseAnonKey = () =>
  required(
    'NEXT_PUBLIC_SUPABASE_ANON_KEY',
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
  );

/**
 * Server-only. Bypasses RLS completely.
 *
 * Never expose this to the browser: no NEXT_PUBLIC_ prefix, and never import
 * admin.ts from a "use client" file.
 */
export const supabaseServiceRoleKey = () =>
  required(
    'SUPABASE_SERVICE_ROLE_KEY',
    process.env.SUPABASE_SERVICE_ROLE_KEY
  );

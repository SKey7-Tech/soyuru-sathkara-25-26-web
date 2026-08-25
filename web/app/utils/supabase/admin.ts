import { createClient as createSupabaseClient } from '@supabase/supabase-js'

import { supabaseServiceRoleKey, supabaseUrl } from './env'

/**
 * SERVER-ONLY. Bypasses RLS completely.
 *
 * Never import this from a "use client" file. Next.js only inlines
 * NEXT_PUBLIC_* variables into the browser bundle, so the key itself cannot
 * leak that way — SUPABASE_SERVICE_ROLE_KEY simply reads as undefined in the
 * browser. The guard below turns that into an obvious error instead of a
 * puzzling "supabaseKey is required" from deep inside the SDK.
 *
 * Used by the admin panel's pages and server actions, which is how content
 * reaches the database — the content tables deliberately have no
 * insert/update/delete RLS policy, so nothing else can write to them.
 *
 * No session is persisted: this client is not a user, it is a privileged
 * process, and it must never pick up or refresh a browser session.
 */
export function createAdminClient() {
  if (typeof window !== 'undefined') {
    throw new Error(
      'createAdminClient() was called in the browser. It uses the service_role ' +
        'key and must only run in Server Components, Server Actions or Route ' +
        'Handlers. Use createClient() from ./client instead.'
    )
  }

  return createSupabaseClient(supabaseUrl(), supabaseServiceRoleKey(), {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
      detectSessionInUrl: false,
    },
  })
}

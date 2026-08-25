import { createBrowserClient } from '@supabase/ssr'

import { supabaseAnonKey, supabaseUrl } from './env'

/**
 * Supabase client for Client Components (the /resources/* pages).
 *
 * Uses the anon key, so every query is subject to the RLS policies in
 * supabase/migrations/002_rls_policies.sql. Content tables are readable while
 * signed out by design — students browse before they ever have an account.
 */
export function createClient() {
  return createBrowserClient(supabaseUrl(), supabaseAnonKey())
}

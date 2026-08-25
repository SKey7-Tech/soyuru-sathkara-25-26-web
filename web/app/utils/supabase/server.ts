import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

import { supabaseAnonKey, supabaseUrl } from './env'

/**
 * Supabase client for Server Components, Server Actions and Route Handlers.
 *
 * Cookie-bound, so it acts as the signed-in user and RLS applies normally.
 * This is the client to use for anything that should respect a user's
 * permissions — including the admin check, which relies on the
 * "admins read own" policy (auth.uid() = id).
 *
 * For the content writes that must bypass RLS, use createAdminClient() from
 * ./admin instead.
 */
export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient(supabaseUrl(), supabaseAnonKey(), {
    cookies: {
      getAll() {
        return cookieStore.getAll()
      },
      setAll(cookiesToSet) {
        try {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options)
          )
        } catch {
          // Called from a Server Component, where cookies are read-only.
          // Safe to ignore: the proxy/middleware refreshes the session, so the
          // browser still receives the updated cookie.
        }
      },
    },
  })
}

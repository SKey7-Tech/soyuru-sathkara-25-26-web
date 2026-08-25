import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

import { supabaseAnonKey, supabaseUrl } from './env'

/**
 * Refreshes the Supabase auth cookie on every matched request, and gates
 * /admin behind a signed-in session.
 *
 * Two rules from the @supabase/ssr contract that are easy to break:
 *
 *   1. Do not put code between createServerClient() and getUser(). A slow or
 *      throwing call in between can leave the user randomly logged out,
 *      because the session refresh never completes.
 *   2. Return `response` as-is, or copy its cookies onto any new response you
 *      build. Cookies set during the refresh live on that object; dropping it
 *      silently signs the user out on the next request.
 */
export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({ request })

  const supabase = createServerClient(supabaseUrl(), supabaseAnonKey(), {
    cookies: {
      getAll() {
        return request.cookies.getAll()
      },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value }) =>
          request.cookies.set(name, value)
        )
        response = NextResponse.next({ request })
        cookiesToSet.forEach(({ name, value, options }) =>
          response.cookies.set(name, value, options)
        )
      },
    },
  })

  // IMPORTANT: nothing between here and getUser().
  const {
    data: { user },
  } = await supabase.auth.getUser()

  const { pathname } = request.nextUrl
  const isAdminRoute = pathname.startsWith('/admin')
  const isLoginRoute = pathname.startsWith('/admin/login')

  // Gate the admin panel. Its pages and server actions run under the
  // service_role key, which bypasses RLS entirely, so an unauthenticated
  // request reaching them can upload and delete content.
  //
  // This is the first of two checks. It only proves *someone* is signed in;
  // whether that account is actually an admin is verified against the `admins`
  // table in app/admin/layout.tsx, which is the check that matters.
  if (isAdminRoute && !isLoginRoute && !user) {
    const redirectUrl = request.nextUrl.clone()
    redirectUrl.pathname = '/admin/login'
    redirectUrl.searchParams.set('redirectedFrom', pathname)

    const redirect = NextResponse.redirect(redirectUrl)
    // Carry the refreshed auth cookies across — see rule 2 above.
    response.cookies.getAll().forEach((cookie) => redirect.cookies.set(cookie))
    return redirect
  }

  // Already signed in and sitting on the login page: send them to the panel.
  if (isLoginRoute && user) {
    const redirectUrl = request.nextUrl.clone()
    redirectUrl.pathname = '/admin'
    redirectUrl.search = ''

    const redirect = NextResponse.redirect(redirectUrl)
    response.cookies.getAll().forEach((cookie) => redirect.cookies.set(cookie))
    return redirect
  }

  return response
}

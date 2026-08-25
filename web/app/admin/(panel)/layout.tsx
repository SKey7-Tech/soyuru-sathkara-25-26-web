import { ReactNode } from "react";
import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/app/utils/supabase/server";

/**
 * Guards every page in the (panel) route group.
 *
 * The login page deliberately sits OUTSIDE this group — putting it inside
 * would make an unauthenticated visit redirect to a page that redirects
 * again, forever.
 *
 * This is the second of two checks. The proxy (app/utils/supabase/middleware.ts)
 * already turns anonymous visitors away; this one answers the question that
 * actually matters — is this signed-in account an *admin*?
 *
 * It uses the cookie-bound client, not the service_role one, so the "admins
 * read own" RLS policy (auth.uid() = id) does the work: a non-admin's query
 * returns no row no matter what they send.
 */
async function requireAdmin() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/admin/login");

  const { data: admin } = await supabase
    .from("admins")
    .select("id")
    .eq("id", user.id)
    .maybeSingle();

  // Signed in, but not on the admin list. Not a login problem, so bouncing
  // them to the login form would just loop them; send them to the site.
  if (!admin) redirect("/?error=not-an-admin");

  return user;
}

export default async function AdminLayout({ children }: { children: ReactNode }) {
  await requireAdmin();

  return (
    <div className="min-h-screen bg-slate-50 flex font-sans text-slate-900">
      {/* Sidebar */}
      <aside className="w-64 bg-white border-r border-slate-200 p-6 flex flex-col gap-6 shadow-sm">
        <div className="font-bold text-2xl tracking-tight bg-gradient-to-br from-blue-600 to-indigo-600 bg-clip-text text-transparent">
          Admin Panel
        </div>
        
        <nav className="flex flex-col gap-2 flex-grow">
          <Link href="/admin" className="px-4 py-2 rounded-lg hover:bg-slate-100 transition-colors text-slate-600 hover:text-slate-900 font-medium">
            Dashboard
          </Link>
          <Link href="/admin/papers" className="px-4 py-2 rounded-lg hover:bg-slate-100 transition-colors text-slate-600 hover:text-slate-900 font-medium">
            Papers & PDFs
          </Link>
          <Link href="/admin/videos" className="px-4 py-2 rounded-lg hover:bg-slate-100 transition-colors text-slate-600 hover:text-slate-900 font-medium">
            YouTube Videos
          </Link>
        </nav>

        <div className="mt-auto">
          <Link href="/" className="px-4 py-2 block text-center rounded-lg bg-slate-100 hover:bg-slate-200 transition-colors text-sm text-slate-600 font-medium">
            Back to Site
          </Link>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 p-8 overflow-y-auto">
        <div className="max-w-6xl mx-auto">
          {children}
        </div>
      </main>
    </div>
  );
}

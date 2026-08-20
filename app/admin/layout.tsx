import { ReactNode } from "react";
import Link from "next/link";

export default function AdminLayout({ children }: { children: ReactNode }) {
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

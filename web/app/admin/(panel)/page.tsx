export default function AdminDashboard() {
  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold text-slate-900">Dashboard Overview</h1>
      <p className="text-slate-600">Welcome to the Soyuru Sathkara admin panel. Select an option from the sidebar to manage content.</p>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm transition-shadow hover:shadow-md">
          <h2 className="text-xl font-semibold mb-2 text-slate-800">Papers & PDFs</h2>
          <p className="text-slate-600 mb-4">Upload and manage theory notes, short notes, and model papers.</p>
          <a href="/admin/papers" className="text-blue-600 hover:text-blue-700 font-medium flex items-center gap-1">Manage Papers <span aria-hidden="true">→</span></a>
        </div>
        
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm transition-shadow hover:shadow-md">
          <h2 className="text-xl font-semibold mb-2 text-slate-800">YouTube Videos</h2>
          <p className="text-slate-600 mb-4">Manage video discussion links for specific papers and units.</p>
          <a href="/admin/videos" className="text-blue-600 hover:text-blue-700 font-medium flex items-center gap-1">Manage Videos <span aria-hidden="true">→</span></a>
        </div>
      </div>
    </div>
  );
}

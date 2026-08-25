import { createAdminClient } from '@/app/utils/supabase/admin'
import { uploadPaper } from '../actions'

export default async function PapersAdminPage() {
  const supabase = createAdminClient()
  
  // Fetch subjects to populate the dropdown
  const { data: subjects } = await supabase.from('subjects').select('*').order('order_index')
  
  // Fetch existing papers
  const { data: papers } = await supabase.from('papers').select('*, subjects(name_en)').order('created_at', { ascending: false })

  return (
    <div className="space-y-8">
      <h1 className="text-2xl font-bold text-slate-900">Manage Papers & PDFs</h1>

      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <h2 className="text-xl font-semibold mb-4 text-slate-800">Upload New File</h2>
        <form action={uploadPaper} className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-slate-700">Title (English)</label>
            <input name="title" required className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all" />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-slate-700">Title (Sinhala)</label>
            <input name="title_si" required className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all" />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-slate-700">Title (Tamil)</label>
            <input name="title_ta" required className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all" />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-slate-700">Subject</label>
            <select name="subject_id" required className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all">
              {subjects?.map(sub => <option key={sub.id} value={sub.id}>{sub.name_en}</option>)}
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-slate-700">Year</label>
            <input name="year" type="number" defaultValue={new Date().getFullYear()} required className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all" />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-slate-700">Type</label>
            <select name="paper_type" required className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all">
              <option value="model">Model Paper</option>
              <option value="past">Past Paper</option>
              <option value="term">Term Test</option>
              <option value="notes">Theory / Short Notes</option>
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-slate-700">Medium</label>
            <select name="medium" required className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all">
              <option value="si">Sinhala</option>
              <option value="en">English</option>
              <option value="ta">Tamil</option>
            </select>
          </div>
          <div className="flex flex-col gap-1 md:col-span-2">
            <label className="text-sm font-medium text-slate-700">PDF File</label>
            <input name="file" type="file" accept="application/pdf" required className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all" />
          </div>
          <div className="md:col-span-2 mt-4">
            <button type="submit" className="bg-blue-600 hover:bg-blue-700 text-white font-medium px-6 py-2.5 rounded-lg shadow-sm hover:shadow transition-all focus:outline-none focus:ring-2 focus:ring-blue-500/50">
              Upload File
            </button>
          </div>
        </form>
      </div>

      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <h2 className="text-xl font-semibold mb-4 text-slate-800">Existing Records</h2>
        <div className="overflow-x-auto rounded-xl border border-slate-200">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="text-xs uppercase bg-slate-50 text-slate-500 border-b border-slate-200">
              <tr>
                <th className="px-4 py-3 font-semibold">Title</th>
                <th className="px-4 py-3 font-semibold">Subject</th>
                <th className="px-4 py-3 font-semibold">Type</th>
                <th className="px-4 py-3 font-semibold">Medium</th>
                <th className="px-4 py-3 font-semibold">File path</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {papers?.map(paper => (
                <tr key={paper.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-medium text-slate-900">{paper.title}</td>
                  <td className="px-4 py-3">{(paper.subjects as any)?.name_en}</td>
                  <td className="px-4 py-3">{paper.paper_type}</td>
                  <td className="px-4 py-3 uppercase">{paper.medium}</td>
                  <td className="px-4 py-3 text-xs text-slate-400 font-mono">{paper.storage_path}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

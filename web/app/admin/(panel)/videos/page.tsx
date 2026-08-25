import { createAdminClient } from '@/app/utils/supabase/admin'
import { uploadVideo, deleteVideo } from '../actions'
import DeleteVideoButton from './DeleteVideoButton'

export default async function VideosAdminPage() {
  const supabase = createAdminClient()
  
  // Fetch units and papers to populate dropdowns
  const { data: units } = await supabase.from('units').select('id, title_en, title_si').order('order_index')
  const { data: papers } = await supabase.from('papers').select('id, title, medium')
  
  // Fetch existing videos
  const { data: videos } = await supabase.from('videos').select('*, units(title_en), papers(title)').order('created_at', { ascending: false }).limit(50)

  return (
    <div className="space-y-8">
      <h1 className="text-2xl font-bold text-slate-900">Manage YouTube Videos</h1>

      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <h2 className="text-xl font-semibold mb-4 text-slate-800">Add New Video</h2>
        <form action={uploadVideo} className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-slate-700">YouTube Video ID (11 chars)</label>
            <input name="youtube_video_id" required placeholder="e.g. dQw4w9WgXcQ" maxLength={11} minLength={11} className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 font-mono placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all" />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-slate-700">Title</label>
            <input name="title" required placeholder="Discussion Part 1" className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all" />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-slate-700">Unit (Series)</label>
            <select name="unit_id" required className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all">
              {units?.map(unit => <option key={unit.id} value={unit.id}>{unit.title_en} / {unit.title_si}</option>)}
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-slate-700">Related Paper (Optional)</label>
            <select name="paper_id" className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all">
              <option value="">-- None --</option>
              {papers?.map(paper => <option key={paper.id} value={paper.id}>{paper.title} ({paper.medium})</option>)}
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-slate-700">Order Index</label>
            <input name="order_index" type="number" defaultValue={0} required className="bg-white border border-slate-300 rounded-lg px-3 py-2 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all" />
          </div>
          
          <div className="md:col-span-2 mt-4">
            <button type="submit" className="bg-blue-600 hover:bg-blue-700 text-white font-medium px-6 py-2.5 rounded-lg shadow-sm hover:shadow transition-all focus:outline-none focus:ring-2 focus:ring-blue-500/50">
              Add Video
            </button>
          </div>
        </form>
      </div>

      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <h2 className="text-xl font-semibold mb-4 text-slate-800">Recent Videos (Top 50)</h2>
        <div className="overflow-x-auto rounded-xl border border-slate-200">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="text-xs uppercase bg-slate-50 text-slate-500 border-b border-slate-200">
              <tr>
                <th className="px-4 py-3 font-semibold">Title</th>
                <th className="px-4 py-3 font-semibold">YouTube ID</th>
                <th className="px-4 py-3 font-semibold">Unit</th>
                <th className="px-4 py-3 font-semibold">Paper</th>
                <th className="px-4 py-3 font-semibold">Order</th>
                <th className="px-4 py-3 font-semibold text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {videos?.map(video => (
                <tr key={video.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-medium text-slate-900">{video.title}</td>
                  <td className="px-4 py-3 font-mono text-xs text-slate-500">{video.youtube_video_id}</td>
                  <td className="px-4 py-3">{(video.units as any)?.title_en}</td>
                  <td className="px-4 py-3">{(video.papers as any)?.title || '-'}</td>
                  <td className="px-4 py-3">{video.order_index}</td>
                  <td className="px-4 py-3 text-right">
                    <DeleteVideoButton id={video.id} deleteAction={deleteVideo} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

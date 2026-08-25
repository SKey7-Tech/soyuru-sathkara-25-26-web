'use server'

import { revalidatePath } from 'next/cache'
import { createAdminClient } from '@/app/utils/supabase/admin'

export async function uploadPaper(formData: FormData) {
  const supabase = createAdminClient()
  
  const title = formData.get('title') as string
  const title_si = formData.get('title_si') as string
  const title_ta = formData.get('title_ta') as string
  const subject_id = formData.get('subject_id') as string
  const year = parseInt(formData.get('year') as string)
  const paper_type = formData.get('paper_type') as string
  const medium = formData.get('medium') as string
  
  const file = formData.get('file') as File
  if (!file) {
    throw new Error('File is required')
  }

  // Generate unique filename to avoid collisions
  const filename = `${Date.now()}-${file.name}`
  const folder = paper_type === 'notes' ? 'theory' : 'papers'
  const storage_path = `${folder}/${filename}`

  // Upload to Supabase Storage
  const { error: uploadError } = await supabase.storage
    .from('resources')
    .upload(storage_path, file)

  if (uploadError) {
    console.error("Storage error:", uploadError)
    throw new Error('Failed to upload file')
  }

  // Insert database record
  const { error: dbError } = await supabase.from('papers').insert({
    subject_id,
    year,
    paper_type,
    medium,
    title,
    title_si,
    title_ta,
    storage_path,
    size_bytes: file.size,
    has_answers: false
  })

  if (dbError) {
    console.error("DB error:", dbError)
    throw new Error('Failed to insert record')
  }

  revalidatePath('/resources/[slug]', 'page')
  revalidatePath('/admin/papers')
}

export async function uploadVideo(formData: FormData) {
  const supabase = createAdminClient()
  
  const unit_id = formData.get('unit_id') as string
  const paper_id = formData.get('paper_id') as string || null
  const youtube_video_id = formData.get('youtube_video_id') as string
  const title = formData.get('title') as string
  const order_index = parseInt(formData.get('order_index') as string) || 0

  const thumbnail_url = `https://i.ytimg.com/vi/${youtube_video_id}/hqdefault.jpg`

  const { error } = await supabase.from('videos').insert({
    unit_id,
    paper_id,
    youtube_video_id,
    title,
    thumbnail_url,
    order_index
  })

  if (error) {
    console.error("DB error:", error)
    throw new Error('Failed to insert video')
  }

  revalidatePath('/resources/[slug]', 'page')
  revalidatePath('/admin/videos')
}

export async function deleteVideo(formData: FormData) {
  const supabase = createAdminClient()
  
  const id = formData.get('id') as string
  if (!id) throw new Error('Video ID is required')

  const { error } = await supabase.from('videos').delete().eq('id', id)

  if (error) {
    console.error("DB error:", error)
    throw new Error('Failed to delete video')
  }

  revalidatePath('/resources/[slug]', 'page')
  revalidatePath('/admin/videos')
}

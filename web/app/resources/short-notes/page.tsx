"use client";

import { StickyNote, FileText, BookOpen } from "lucide-react";
import Card from "@/app/components/Card";
import Link from "next/link";
import { useLanguage } from "../../contexts/LanguageContext";
import { translations } from "../../translations";
import { useEffect, useState } from "react";
import { createClient } from "@/app/utils/supabase/client";

type Paper = {
  id: string;
  title: string;
  title_si: string;
  title_ta: string;
  storage_path: string;
  videos: { title: string; youtube_video_id: string }[];
};

export default function ShortNotesPage() {
  const { language } = useLanguage();
  const t = translations[language];
  const icon = <StickyNote className="w-10 h-10 text-white" />;
  const supabase = createClient();
  const [shortNotes, setShortNotes] = useState<Paper[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchShortNotes() {
      // Assuming short notes are also stored in `papers` with paper_type = 'notes' (and possibly a specific title keyword, but for now we'll fetch notes)
      const { data, error } = await supabase
        .from('papers')
        .select(`
          id, title, title_si, title_ta, storage_path,
          videos(title, youtube_video_id)
        `)
        .eq('paper_type', 'notes')
        .order('created_at', { ascending: false });

      if (data) {
        setShortNotes(data as Paper[]);
      }
      setLoading(false);
    }
    fetchShortNotes();
  }, [supabase]);

  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">{t.shortNotes.title}</h1>
          <p className="text-lg text-gray-600 mb-6">{t.shortNotes.description}</p>
          
          {/* Navigation to other resource pages */}
          <div className="flex flex-wrap gap-4 mb-8">
            <Link 
              href="/resources/papers"
              className="group flex items-center gap-2 px-6 py-3 bg-white border-2 border-purple-200 rounded-lg hover:border-purple-500 hover:bg-purple-50 transition-all duration-300"
            >
              <FileText className="w-5 h-5 text-purple-600 group-hover:scale-110 transition-transform" />
              <span className="font-medium text-gray-700 group-hover:text-purple-600">{t.papers.linkTitle}</span>
            </Link>
            <Link 
              href="/resources/theory"
              className="group flex items-center gap-2 px-6 py-3 bg-white border-2 border-blue-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-all duration-300"
            >
              <BookOpen className="w-5 h-5 text-blue-600 group-hover:scale-110 transition-transform" />
              <span className="font-medium text-gray-700 group-hover:text-blue-600">{t.theory.linkTitle}</span>
            </Link>
          </div>
        </div>

        {/* Short Notes Grid */}
        {loading ? (
          <div className="flex justify-center items-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
          </div>
        ) : shortNotes.length === 0 ? (
          <div className="text-center py-12 text-gray-500">No short notes found.</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {shortNotes.map((note) => {
              const { data: publicUrlData } = supabase.storage.from('resources').getPublicUrl(note.storage_path);
              const downloadUrl = publicUrlData.publicUrl;
              
              const title = language === 'si' ? note.title_si || note.title : 
                            language === 'ta' ? note.title_ta || note.title : note.title;

              return (
                <Card
                  key={note.id}
                  title={title}
                  descriptionKey={t.shortNotes.description}
                  icon={icon}
                  downloadUrl={downloadUrl}
                  downloadFileName={note.storage_path.split('/').pop() || 'short-note.pdf'}
                  videos={note.videos?.map(v => ({ label: v.title, url: `https://www.youtube.com/watch?v=${v.youtube_video_id}` })) || []}
                  className="h-full"
                  category="shortNotes"
                />
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

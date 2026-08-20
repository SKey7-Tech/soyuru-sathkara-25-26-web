"use client";

import { BookOpen, FileText, StickyNote } from "lucide-react";
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

export default function TheoryPage() {
  const { language } = useLanguage();
  const t = translations[language];
  const icon = <BookOpen className="w-10 h-10 text-white" />;
  const supabase = createClient();
  const [theoryNotes, setTheoryNotes] = useState<Paper[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchTheory() {
      // Assuming theory notes are also stored in `papers` with paper_type = 'notes'
      // Or we can filter by path if needed, but let's assume paper_type = 'notes'
      const { data, error } = await supabase
        .from('papers')
        .select(`
          id, title, title_si, title_ta, storage_path,
          videos(title, youtube_video_id)
        `)
        .eq('paper_type', 'notes')
        .order('created_at', { ascending: false });

      if (data) {
        setTheoryNotes(data as Paper[]);
      }
      setLoading(false);
    }
    fetchTheory();
  }, [supabase]);

  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">{t.theory.title}</h1>
          <p className="text-lg text-gray-600 mb-6">{t.theory.description}</p>
          
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
              href="/resources/short-notes"
              className="group flex items-center gap-2 px-6 py-3 bg-white border-2 border-green-200 rounded-lg hover:border-green-500 hover:bg-green-50 transition-all duration-300"
            >
              <StickyNote className="w-5 h-5 text-green-600 group-hover:scale-110 transition-transform" />
              <span className="font-medium text-gray-700 group-hover:text-green-600">{t.shortNotes.linkTitle}</span>
            </Link>
          </div>
        </div>

        {/* Theory Grid */}
        {loading ? (
          <div className="flex justify-center items-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
          </div>
        ) : theoryNotes.length === 0 ? (
          <div className="text-center py-12 text-gray-500">No theory notes found.</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {theoryNotes.map((item) => {
              const { data: publicUrlData } = supabase.storage.from('resources').getPublicUrl(item.storage_path);
              const downloadUrl = publicUrlData.publicUrl;
              
              const title = language === 'si' ? item.title_si || item.title : 
                            language === 'ta' ? item.title_ta || item.title : item.title;

              return (
                <Card
                  key={item.id}
                  title={title}
                  descriptionKey={t.theory.description}
                  icon={icon}
                  downloadUrl={downloadUrl}
                  downloadFileName={item.storage_path.split('/').pop() || 'theory.pdf'}
                  videos={item.videos?.map(v => ({ label: v.title, url: `https://www.youtube.com/watch?v=${v.youtube_video_id}` })) || []}
                  className="h-full"
                  category="theory"
                />
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

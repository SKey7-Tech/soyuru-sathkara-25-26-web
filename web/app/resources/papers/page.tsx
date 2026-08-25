"use client";

import { FileText, BookOpen, StickyNote } from "lucide-react";
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

export default function PapersPage() {
  const { language } = useLanguage();
  const t = translations[language];
  const icon = <FileText className="w-10 h-10 text-white" />;
  const supabase = createClient();
  const [papers, setPapers] = useState<Paper[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchPapers() {
      // paper_type in ('past', 'model', 'term')
      const { data, error } = await supabase
        .from('papers')
        .select(`
          id, title, title_si, title_ta, storage_path,
          videos(title, youtube_video_id)
        `)
        .in('paper_type', ['model', 'past', 'term'])
        .order('created_at', { ascending: false });

      if (data) {
        setPapers(data as Paper[]);
      }
      setLoading(false);
    }
    fetchPapers();
  }, [supabase]);

  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">{t.papers.title}</h1>
          <p className="text-lg text-gray-600 mb-6">{t.papers.description}</p>
          
          {/* Navigation to other resource pages */}
          <div className="flex flex-wrap gap-4 mb-8">
            <Link 
              href="/resources/theory"
              className="group flex items-center gap-2 px-6 py-3 bg-white border-2 border-blue-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-all duration-300"
            >
              <BookOpen className="w-5 h-5 text-blue-600 group-hover:scale-110 transition-transform" />
              <span className="font-medium text-gray-700 group-hover:text-blue-600">{t.theory.linkTitle}</span>
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

        {/* Papers Grid */}
        {loading ? (
          <div className="flex justify-center items-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
          </div>
        ) : papers.length === 0 ? (
          <div className="text-center py-12 text-gray-500">No papers found.</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {papers.map((paper) => {
              // Extract the public URL for the storage path
              const { data: publicUrlData } = supabase.storage.from('resources').getPublicUrl(paper.storage_path);
              const downloadUrl = publicUrlData.publicUrl;
              
              // Select correct language title
              const title = language === 'si' ? paper.title_si || paper.title : 
                            language === 'ta' ? paper.title_ta || paper.title : paper.title;

              return (
                <Card
                  key={paper.id}
                  title={title}
                  descriptionKey={t.papers.description}
                  icon={icon}
                  downloadUrl={downloadUrl}
                  downloadFileName={paper.storage_path.split('/').pop() || 'paper.pdf'}
                  videos={paper.videos?.map(v => ({ label: v.title, url: `https://www.youtube.com/watch?v=${v.youtube_video_id}` })) || []}
                  className="h-full"
                  category="papers"
                />
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

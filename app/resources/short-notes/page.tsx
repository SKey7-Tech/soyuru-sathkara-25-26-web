"use client";

import { StickyNote, FileText, BookOpen } from "lucide-react";
import { shortNotes } from "@/app/data/shortNotes";
import Card from "@/app/components/Card";
import Link from "next/link";
import { useLanguage } from "../../contexts/LanguageContext";
import { translations } from "../../translations";

export default function ShortNotesPage() {
  const { language } = useLanguage();
  const t = translations[language];
  const icon = <StickyNote className="w-10 h-10 text-white" />;

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
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {shortNotes.map((note) => (
            <Card
              key={note.id}
              titleKey={note.titleKey}
              descriptionKey={note.descriptionKey}
              icon={icon}
              downloadUrl={note.filePath}
              downloadFileName={`${note.id}.pdf`}
              videos={note.videos}
              className="h-full"
            />
          ))}
        </div>
      </div>
    </div>
  );
}

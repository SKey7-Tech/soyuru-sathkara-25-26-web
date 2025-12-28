"use client";

import { FileText, BookOpen, StickyNote } from "lucide-react";
import { papers } from "@/app/data/papers";
import Card from "@/app/components/Card";
import Link from "next/link";
import { useLanguage } from "../../contexts/LanguageContext";
import { translations } from "../../translations";

export default function PapersPage() {
  const { language } = useLanguage();
  const t = translations[language];
  const icon = <FileText className="w-10 h-10 text-white" />;

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
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {papers.map((paper) => (
            <Card
              key={paper.id}
              titleKey={paper.titleKey}
              descriptionKey={paper.descriptionKey}
              icon={icon}
              downloadUrl={paper.filePath}
              downloadFileName={`${paper.id}.pdf`}
              videos={paper.videos}
              className="h-full"
            />
          ))}
        </div>
      </div>
    </div>
  );
}

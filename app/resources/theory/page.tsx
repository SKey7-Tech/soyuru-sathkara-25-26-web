"use client";

import { BookOpen, FileText, StickyNote } from "lucide-react";
import { theory } from "@/app/data/theory";
import Card from "@/app/components/Card";
import Link from "next/link";
import { useLanguage } from "../../contexts/LanguageContext";
import { translations } from "../../translations";

export default function TheoryPage() {
  const { language } = useLanguage();
  const t = translations[language];
  const icon = <BookOpen className="w-10 h-10 text-white" />;

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
        {/* <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {theory.map((item) => (
            <Card
              key={item.id}
              titleKey={item.titleKey}
              descriptionKey={item.descriptionKey}
              icon={icon}
              downloadUrl={item.filePath}
              downloadFileName={`${item.id}.pdf`}
              videos={item.videos}
              className="h-full"
            />
          ))}
        </div> */}
      </div>
    </div>
  );
}

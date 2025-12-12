"use client";

import { FileText } from "lucide-react";
import { pdfs } from "@/app/data/pdfs";
import Card from "@/app/components/Card";

export default function ResourcesPage() {
  const icon = <FileText className="w-10 h-10 text-white" />;

  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">Downloadable Resources</h1>
        <p className="text-lg text-gray-600 mb-12">Access important documents and resources</p>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {pdfs.map((pdf) => (
            <Card
              key={pdf.id}
              titleKey={pdf.titleKey}
              descriptionKey={pdf.descriptionKey}
              icon={icon}
              downloadUrl={pdf.filePath}
              downloadFileName={`${pdf.id}.pdf`}
              videos={pdf.videos}
              className="h-full"
            />
          ))}
        </div>
      </div>
    </div>
  );
}

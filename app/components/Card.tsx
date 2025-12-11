"use client";

import React, { ReactNode } from "react";
import Link from "next/link";
import { motion } from "framer-motion";
import { Download, FileText } from "lucide-react";
import { useLanguage } from "../contexts/LanguageContext";
import { translations } from "../translations";

type CardProps = {
  title?: string;
  titleKey?: string;
  description?: string;
  descriptionKey?: string;
  icon?: ReactNode;
  href?: string;
  downloadUrl?: string;
  downloadFileName?: string;
  onClick?: () => void;
  className?: string;
};

export default function Card({
  title,
  titleKey,
  description,
  descriptionKey,
  icon = <FileText className="w-10 h-10 text-white" />,
  href,
  downloadUrl,
  downloadFileName,
  onClick,
  className = "",
}: CardProps) {
  const { language } = useLanguage();
  const t = translations[language].pdfs as any;

  // Resolve title: use titleKey first, then fallback to title prop
  const resolvedTitle = titleKey && t?.items?.[titleKey]?.title ? t.items[titleKey].title : title;
  
  // Resolve description: use descriptionKey first, then fallback to description prop
  const resolvedDescription = descriptionKey && t?.items?.[descriptionKey]?.description ? t.items[descriptionKey].description : description;

  const handleDownload = async () => {
    if (!downloadUrl) return;
    try {
      const res = await fetch(downloadUrl);
      if (!res.ok) {
        alert(`Download failed: File not found (${res.status})`);
        console.error(`Download error: ${res.status} ${res.statusText}`);
        return;
      }
      const blob = await res.blob();
      
      // Check if blob is valid
      if (blob.size === 0) {
        alert("Download failed: File is empty");
        return;
      }

      const url = window.URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      
      // Ensure proper file extension
      const fileName = downloadFileName || "download.pdf";
      const fileExtension = fileName.includes(".") ? "" : ".pdf";
      link.download = fileName + fileExtension;
      
      link.style.display = "none";
      document.body.appendChild(link);
      link.click();
      
      // Cleanup
      setTimeout(() => {
        document.body.removeChild(link);
        window.URL.revokeObjectURL(url);
      }, 100);
    } catch (err) {
      console.error("Download error:", err);
      alert(`Download failed: ${err instanceof Error ? err.message : "Unknown error"}`);
    }
  };

  const cardContent = (
    <motion.div
      whileHover={{ y: -12, scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      transition={{ type: "spring", stiffness: 300, damping: 20 }}
      className="group relative bg-linear-to-br from-white to-blue-50/50 rounded-3xl p-8 border-2 border-blue-200 hover:border-[#3b82f6] shadow-lg hover:shadow-2xl transition-all duration-300 overflow-hidden h-full"
    >
      {/* Animated background gradient */}
      <motion.div
        className="absolute inset-0 bg-linear-to-br from-[#3b82f6]/0 to-[#2563eb]/0 group-hover:from-[#3b82f6]/5 group-hover:to-[#2563eb]/10 transition-all duration-300"
        initial={false}
      />

      <div className="relative z-10 flex flex-col h-full">
        {/* Icon Container */}
        <motion.div
          whileHover={{ rotate: 360, scale: 1.1 }}
          transition={{ duration: 0.6 }}
          className="w-20 h-20 bg-gradient-to-br from-[#3b82f6] to-[#2563eb] rounded-2xl flex items-center justify-center mb-6 shadow-xl group-hover:shadow-2xl transition-shadow duration-300"
        >
          {icon}
        </motion.div>

        {/* Title and Description */}
        <div className="grow">
          {resolvedTitle && (
            <h3 className="text-2xl font-semibold text-[#1d1e22] mb-3 group-hover:text-[#3b82f6] transition-colors">
              {resolvedTitle}
            </h3>
          )}
          {resolvedDescription && (
            <p className="text-[#393f4d] leading-relaxed text-base">
              {resolvedDescription}
            </p>
          )}
        </div>

        {/* Download Button */}
        {downloadUrl && (
          <motion.button
            onClick={(e) => {
              e.stopPropagation();
              handleDownload();
            }}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="mt-6 inline-flex items-center gap-2 px-6 py-3 bg-linear-to-br from-[#3b82f6] to-[#2563eb] text-white rounded-xl hover:shadow-lg transition-all duration-300 font-medium"
          >
            <Download className="w-5 h-5" />
            {t.button}
          </motion.button>
        )}
      </div>

      {/* Corner accent */}
      <div className="absolute top-0 right-0 w-24 h-24 bg-linear-to-br from-[#3b82f6]/10 to-transparent rounded-bl-full opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
    </motion.div>
  );

  if (href) {
    return (
      <Link href={href} className="block">
        {cardContent}
      </Link>
    );
  }

  return (
    <div onClick={onClick} role={onClick ? "button" : undefined} tabIndex={onClick ? 0 : undefined}>
      {cardContent}
    </div>
  );
}

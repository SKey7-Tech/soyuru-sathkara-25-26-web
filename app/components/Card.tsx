"use client";

import React, { ReactNode, useState, useEffect } from "react";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import { Download, FileText, Video, ChevronDown } from "lucide-react";
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
  videos?: {label: string; url: string}[];
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
  videos,
  onClick,
  className = "",
}: CardProps) {
  const { language } = useLanguage();
  const t = translations[language].pdfs as any;

  // State to manage video modal visibility
  const [isExpanded, setIsExpanded] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const [isHovering, setIsHovering] = useState(false);

  // Detect if device is mobile
  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 768);
    };
    
    checkMobile();
    window.addEventListener('resize', checkMobile);
    
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

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

  const onCardClick = (e: React.MouseEvent) => {
    if(onClick) onClick();
    // Only expand on click for mobile
    if (isMobile && videos && videos.length > 0) {
      setIsExpanded(!isExpanded);
    }
  };

  const handleMouseEnter = () => {
    // Only expand on hover for desktop
    if (!isMobile && videos && videos.length > 0) {
      setIsHovering(true);
      setIsExpanded(true);
    }
  };

  const handleMouseLeave = () => {
    // Only collapse on hover leave for desktop
    if (!isMobile) {
      setIsHovering(false);
      setIsExpanded(false);
    }
  };

  const cardContent = (
    <motion.div
      layout
      onClick={onCardClick}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      whileHover={{ y: -12, scale:1.02 }}
      whileTap={{ scale: 0.98 }}
      transition={{ type: "spring", stiffness: 300, damping: 20 }}
      className="group relative bg-linear-to-br from-white to-blue-50/50 rounded-3xl p-8 border-2 border-blue-200 hover:border-[#3b82f6] shadow-lg hover:shadow-2xl transition-all duration-300 overflow-hidden "
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

        {/* Mobile "See Videos/Notes" Button */}
        {isMobile && videos && videos.length > 0 && !isExpanded && (
          <motion.button
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            onClick={(e) => {
              e.stopPropagation();
              setIsExpanded(true);
            }}
            className="mt-4 w-full inline-flex items-center justify-center gap-2 px-6 py-3 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-xl shadow-md hover:shadow-lg transition-all duration-300 font-medium"
          >
            <Video className="w-5 h-5" />
            <span>See Videos/Notes</span>
            <motion.div
              animate={{ y: [0, 3, 0] }}
              transition={{ duration: 1.5, repeat: Infinity }}
            >
              <ChevronDown className="w-5 h-5" />
            </motion.div>
          </motion.button>
        )}

        {/* Video Modal */}
        <AnimatePresence>
          {isExpanded && videos && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                exit={{ opacity: 0, height: 0 }}
                className="overflow-hidden"
            >
              <div className="pt-2 space-y-2 border-t border-gray-100 mt-2">
                  <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">
                    {t.videosHeading || "Related Video Lessons"}
                  </p>
                  {videos.map((video, index) => (
                    <Link
                      key={index}
                      href={video.url}
                      target="_blank"
                      onClick={(e) => e.stopPropagation()}
                      className="block"
                    >
                      <motion.div
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.1 }}
                      className="flex items-center gap-3 p-3 rounded-lg bg-gray-700 text-gray-100 border border-gray-800 hover:bg-black hover:border-gray-600 transition-all"
                    >
                      {/* Red Icon to pop against dark background */}
                      <div className="p-1.5 bg-blue-600 rounded-md">
                        <Video className="w-4 h-4 text-white" />
                      </div>
                      <span className="font-medium text-sm truncate">{t.videosLabel[video.label] || video.label}</span>
                    </motion.div>
                    </Link>
                  ))}
                </div>
            </motion.div>
          )}
        </AnimatePresence>
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

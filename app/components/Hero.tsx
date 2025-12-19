'use client';

import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { motion } from "framer-motion";
import { useLanguage } from "../contexts/LanguageContext";
import { translations } from "../translations";
import { ImageWithFallback } from "./figma/ImageWithFallback";

export function Hero() {
  const { language } = useLanguage();
  const t = translations[language].hero;

  return (
    <section id="home" className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Background Image with Overlay */}
      <div className="absolute inset-0 z-0">
        <ImageWithFallback
          src="/hero/ssHero.jpg"
          alt="Students learning in classroom"
          fetchPriority="high"
          className="w-full h-full object-cover"
          width={1920}
          height={1080}
        />
        <div className="absolute inset-0 bg-gradient-to-br from-[#1d1e22]/95 via-[#393f4d]/90 to-[#1d1e22]/95"></div>
      </div>

      {/* Content */}
      <div className="relative z-10 max-w-5xl mx-auto px-6 text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
        >
          <motion.div
            animate={{ y: [0, -5, 0] }}
            transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
            className="inline-block bg-white/10 backdrop-blur-sm text-white px-4 py-2 rounded-full mb-6"
          >
            <span className="flex items-center gap-2">
              <span className="w-2 h-2 bg-[#3b82f6] rounded-full animate-pulse"></span>
              {t.badge}
            </span>
          </motion.div>
        </motion.div>

        <motion.h1
          className="text-white text-5xl md:text-7xl mb-4"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
        >
          {t.title}
        </motion.h1>

        <motion.p
          className="text-white/90 text-2xl md:text-3xl mb-6"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.3 }}
        >
          {t.subtitle}
        </motion.p>

        <motion.p
          className="text-white/80 text-xl mb-12 max-w-3xl mx-auto"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.4 }}
        >
          {t.description}
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.5 }}
        >
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">

            <Link href="/resources">
              <motion.div
                whileHover={{ scale: 1.05, boxShadow: "0 20px 40px rgba(59, 130, 246, 0.3)" }}
                whileTap={{ scale: 0.95 }}
                className="bg-white text-[#1d1e22] px-8 py-4 rounded-lg hover:bg-white/90 transition-all shadow-lg flex items-center gap-2 group"
              >
                {t.exploreBtn}
                <motion.div
                  animate={{ x: [0, 5, 0] }}
                  transition={{ duration: 1.5, repeat: Infinity }}
                >
                  <ArrowRight className="w-5 h-5" />
                </motion.div>
              </motion.div>
            </Link>
            <motion.a
              href="#about"

              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="bg-[#3b82f6] text-white px-8 py-4 rounded-lg hover:bg-[#2563eb] transition-colors border border-[#3b82f6] inline-block"
            >
              {t.learnMoreBtn}
            </motion.a>
          </div>
        </motion.div>
      </div>

      {/* Scroll Indicator */}
      <motion.div
        className="absolute bottom-8 left-1/2 transform -translate-x-1/2 z-10"
        animate={{ y: [0, 10, 0] }}
        transition={{ duration: 2, repeat: Infinity }}
      >
      </motion.div>
    </section>
  );
}
/* explore button t.cta 83 */
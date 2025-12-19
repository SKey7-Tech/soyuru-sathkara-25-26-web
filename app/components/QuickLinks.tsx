'use client';

import { FileText, BookOpen, Image, Mail, Info, GraduationCap } from "lucide-react";
import { motion } from "framer-motion";
import { useLanguage } from "../contexts/LanguageContext";
import { translations } from "../translations";

export function QuickLinks() {
  const { language } = useLanguage();
  const t = translations[language].quickLinks;

  // Icon mapping for primary resources
  const primaryIcons = [FileText, BookOpen, GraduationCap];
  
  // Icon mapping for secondary links
  const secondaryIcons = [Image, Info, Mail];

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.15
      }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 30 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6
      }
    }
  };

  return (
    <section className="py-24 bg-gradient-to-b from-white to-blue-50/30">
      <div className="max-w-7xl mx-auto px-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <span className="text-[#3b82f6] tracking-wide uppercase mb-2 block">{t.tag}</span>
          <h2 className="text-4xl md:text-5xl text-[#1d1e22] mb-4">{t.title}</h2>
          <p className="text-[#393f4d] text-xl max-w-3xl mx-auto">
            {t.subtitle}
          </p>
        </motion.div>

        {/* Primary Resources - Highlighted */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          className="grid md:grid-cols-3 gap-8 mb-12"
        >
          {t.primaryResources.map((link, index) => {
            const Icon = primaryIcons[index];
            return (
              <motion.a
                key={index}
                href={link.href}
                variants={itemVariants}
                whileHover={{ y: -12, scale: 1.03 }}
                whileTap={{ scale: 0.98 }}
                transition={{ type: "spring", stiffness: 300, damping: 20 }}
                className="group relative bg-gradient-to-br from-white to-blue-50/50 rounded-3xl p-8 border-2 border-blue-200 hover:border-[#3b82f6] shadow-lg hover:shadow-2xl transition-all duration-300 cursor-pointer overflow-hidden"
              >
                {/* Animated background gradient */}
                <motion.div
                  className="absolute inset-0 bg-gradient-to-br from-[#3b82f6]/0 to-[#2563eb]/0 group-hover:from-[#3b82f6]/5 group-hover:to-[#2563eb]/10 transition-all duration-300"
                  initial={false}
                />
                
                <div className="relative z-10">
                  <motion.div
                    whileHover={{ rotate: 360, scale: 1.1 }}
                    transition={{ duration: 0.6 }}
                    className="w-20 h-20 bg-gradient-to-br from-[#3b82f6] to-[#2563eb] rounded-2xl flex items-center justify-center mb-6 shadow-xl group-hover:shadow-2xl transition-shadow duration-300"
                  >
                    <Icon className="w-10 h-10 text-white" />
                  </motion.div>
                  <h3 className="text-2xl text-[#1d1e22] mb-3 group-hover:text-[#3b82f6] transition-colors">
                    {link.title}
                  </h3>
                  <p className="text-[#393f4d] leading-relaxed">
                    {link.description}
                  </p>
                </div>

                {/* Corner accent */}
                <div className="absolute top-0 right-0 w-24 h-24 bg-gradient-to-br from-[#3b82f6]/10 to-transparent rounded-bl-full opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              </motion.a>
            );
          })}
        </motion.div>

        {/* Secondary Links - Smaller cards */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          className="grid md:grid-cols-3 gap-6"
        >
          {t.secondaryLinks.map((link, index) => {
            const Icon = secondaryIcons[index];
            return (
              <motion.a
                key={index}
                href={link.href}
                variants={itemVariants}
                whileHover={{ y: -8, scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                transition={{ type: "spring", stiffness: 300 }}
                className="group bg-white rounded-xl p-6 border border-gray-200 hover:border-[#3b82f6] hover:shadow-lg transition-all duration-300 cursor-pointer"
              >
                <motion.div
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.6 }}
                  className="w-12 h-12 bg-gradient-to-br from-[#3b82f6]/10 to-[#3b82f6]/20 rounded-lg flex items-center justify-center mb-4 group-hover:from-[#3b82f6] group-hover:to-[#2563eb] transition-all duration-300"
                >
                  <Icon className="w-6 h-6 text-[#3b82f6] group-hover:text-white transition-colors duration-300" />
                </motion.div>
                <h3 className="text-lg text-[#1d1e22] mb-2 group-hover:text-[#3b82f6] transition-colors">
                  {link.title}
                </h3>
                <p className="text-sm text-[#393f4d] leading-relaxed">
                  {link.description}
                </p>
              </motion.a>
            );
          })}
        </motion.div>
      </div>
    </section>
  );
}
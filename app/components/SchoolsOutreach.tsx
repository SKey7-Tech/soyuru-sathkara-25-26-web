'use client';

import { School, Users, BookOpen, ArrowRight } from "lucide-react";
import { motion } from "framer-motion";
import { useState, useEffect } from "react";
import { useLanguage } from "../contexts/LanguageContext";
import { translations } from "../translations";
import { ImageWithFallback } from "./figma/ImageWithFallback";

export function SchoolsOutreach() {
  const { language } = useLanguage();
  const t = translations[language].schoolsOutreach;
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  const backgroundImages = [
    "/schoolOutreach/so1.jpg",
    "/schoolOutreach/so2.jpg",
    "/schoolOutreach/so3.jpg",
    "/schoolOutreach/so4.jpg",
    "/schoolOutreach/so5.jpg"
  ];

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentImageIndex((prevIndex) => (prevIndex + 1) % backgroundImages.length);
    }, 4000);

    return () => clearInterval(interval);
  }, []);

  // Benefits with icons - kept in component
  const benefits = {
    en: [
      { icon: BookOpen, text: "Free access to all learning materials" },
      { icon: Users, text: "Expert guidance and support" },
      { icon: School, text: "Community building programs" }
    ],
    si: [
      { icon: BookOpen, text: "සියලුම ඉගෙනුම් ද්‍රව්‍ය වෙත නොමිලේ ප්‍රවේශය" },
      { icon: Users, text: "ප්‍රවීණ මාර්ගෝපදේශනය සහ සහාය" },
      { icon: School, text: "ප්‍රජා ගොඩනැගීමේ වැඩසටහන්" }
    ],
    ta: [
      { icon: BookOpen, text: "அனைத்து கற்றல் பொருட்களுக்கும் இலவச அணுகல்" },
      { icon: Users, text: "நிபுணர் வழிகாட்டுதல் மற்றும் ஆதரவு" },
      { icon: School, text: "சமூக கட்டமைப்பு திட்டங்கள்" }
    ]
  };

  return (
    <section className="relative py-32 overflow-hidden">
      {/* Background Slideshow */}
      <div className="absolute inset-0">
        {backgroundImages.map((image, index) => (
          <motion.div
            key={index}
            className="absolute inset-0"
            initial={{ opacity: 0 }}
            animate={{ 
              opacity: currentImageIndex === index ? 1 : 0,
              scale: currentImageIndex === index ? 1.1 : 1
            }}
            transition={{ duration: 1.5 }}
          >
            <ImageWithFallback
              src={image}
              alt={`School outreach background ${index + 1}`}
              fill
              sizes="100vw"
              className="object-cover"
            />
          </motion.div>
        ))}
        <div className="absolute inset-0 bg-gradient-to-r from-[#1d1e22]/95 via-[#393f4d]/90 to-[#1d1e22]/95"></div>
      </div>

      {/* Content */}
      <div className="relative z-10 max-w-6xl mx-auto px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
          className="text-center mb-12"
        >
          <span className="text-[#3b82f6] tracking-wide uppercase mb-4 block text-lg">{t.tag}</span>
          <h2 className="text-white text-4xl md:text-6xl mb-6">{t.title}</h2>
          <p className="text-white/90 text-2xl mb-8 max-w-3xl mx-auto">
            {t.subtitle}
          </p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          viewport={{ once: true }}
          className="bg-white/10 backdrop-blur-lg rounded-3xl p-10 md:p-12 border border-white/20"
        >
          <p className="text-white/90 text-lg leading-relaxed mb-10 text-center max-w-3xl mx-auto">
            {t.description}
          </p>

          {/* Benefits */}
          <div className="grid md:grid-cols-3 gap-8 mb-10">
            {benefits[language].map((benefit, index) => {
              const Icon = benefit.icon;
              return (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.6, delay: 0.3 + index * 0.1 }}
                  viewport={{ once: true }}
                  className="flex items-center gap-4 text-white"
                >
                  <div className="w-12 h-12 bg-[#3b82f6] rounded-lg flex items-center justify-center flex-shrink-0">
                    <Icon className="w-6 h-6" />
                  </div>
                  <p className="text-lg">{benefit.text}</p>
                </motion.div>
              );
            })}
          </div>

          {/* CTA Button */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6, delay: 0.6 }}
            viewport={{ once: true }}
            className="text-center"
          >
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="bg-white text-[#1d1e22] px-10 py-5 rounded-xl text-lg hover:bg-[#3b82f6] hover:text-white transition-all shadow-2xl flex items-center gap-3 mx-auto group"
            >
              {t.button}
              <motion.div
                animate={{ x: [0, 5, 0] }}
                transition={{ duration: 1.5, repeat: Infinity }}
              >
                <ArrowRight className="w-5 h-5" />
              </motion.div>
            </motion.button>
          </motion.div>
        </motion.div>

        {/* Progress Indicators */}
        <div className="flex justify-center gap-2 mt-8">
          {backgroundImages.map((_, index) => (
            <motion.div
              key={index}
              className={`h-1 rounded-full transition-all duration-500 ${
                currentImageIndex === index ? 'w-8 bg-[#3b82f6]' : 'w-4 bg-white/30'
              }`}
            />
          ))}
        </div>
      </div>
    </section>
  );
}

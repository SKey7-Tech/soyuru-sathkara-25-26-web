'use client';

import { motion } from "framer-motion";
import { ImageWithFallback } from "./figma/ImageWithFallback";
import { useLanguage } from "../contexts/LanguageContext";
import { translations } from "../translations";
import Image from "next/image";
import { containerVariants, itemVariants } from "../utils/animations";

export function Gallery() {
  const { language } = useLanguage();
  const t = translations[language].gallery;

  const images = [
    {
      url: "/gallery/ss2.jpg",
      alt: "Tute program"
    },
    {
      url: "/gallery/ss3.jpg",
      alt: "Students learning"
    },
    {
      url: "/gallery/ss4.jpg",
      alt: "School visit"
    },
    {
      url: "/gallery/ss8.jpg",
      alt: "soyuru sathkara 2025"
    },
    {
      url: "/gallery/ss6.jpg",
      alt: "Rural school"
    },
    {
      url: "/gallery/ss7.jpg",
      alt: "Books and education"
    }
  ];

  return (
    <section id="gallery" className="py-24 bg-gradient-to-b from-white to-blue-50/30">
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

        <motion.div
          variants={containerVariants.default}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          className="grid md:grid-cols-2 lg:grid-cols-3 gap-6"
        >
          {images.map((image, index) => (
            <motion.div
              key={index}
              variants={itemVariants.fadeInScale}
              whileHover={{ scale: 1.05, zIndex: 10 }}
              transition={{ type: "spring", stiffness: 300 }}
              className="relative rounded-2xl overflow-hidden shadow-lg aspect-[4/3] group cursor-pointer"
            >
              <ImageWithFallback
                src={image.url}
                alt={image.alt}
                className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
              />
              <motion.div
                initial={{ opacity: 0 }}
                whileHover={{ opacity: 1 }}
                className="absolute inset-0 bg-gradient-to-t from-[#1d1e22]/80 via-transparent to-transparent flex items-end p-6"
              >
                <p className="text-white">{image.alt}</p>
              </motion.div>
            </motion.div>
          ))}
        </motion.div>

      </div>
    </section>
  );
}
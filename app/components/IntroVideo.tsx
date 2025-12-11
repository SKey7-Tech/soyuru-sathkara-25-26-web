'use client';

import { Play } from "lucide-react";
import { motion } from "framer-motion";
import { useState } from "react";
import { useLanguage } from "../contexts/LanguageContext";
import { translations } from "../translations";

export function IntroVideo() {
  const { language } = useLanguage();
  const t = translations[language].introVideo;
  const [isPlaying, setIsPlaying] = useState(false);


  return (
    <section className="py-24 bg-[#acb8c3] relative overflow-hidden">
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
          initial={{ opacity: 0, scale: 0.95 }}
          whileInView={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.8 }}
          viewport={{ once: true }}
          className="max-w-4xl mx-auto"
        >
          <div className="relative rounded-3xl overflow-hidden shadow-2xl aspect-video bg-gradient-to-br from-[#393f4d] to-[#1d1e22]">
            {!isPlaying ? (
              <>
                {/* Video Thumbnail */}
                <div 
                  className="absolute inset-0 bg-cover bg-center"
                  style={{
                    backgroundImage: 'url(https://scontent.fcmb2-2.fna.fbcdn.net/v/t39.30808-6/469118298_1083640933800137_4831837192517632709_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeGhXxiisL36sRgaFnzVfqs_MVYYZYKFh8sxVhhlgoWHyz2P0Wyitj4_oT79TRP6MpdfOe7szwycbqkecOPUB8_6&_nc_ohc=9MJ9K-HGaIIQ7kNvwFlulyz&_nc_oc=AdnXaLJLRmSbRIbSjGO0lIMtHURBUaw69TkvAwnUA9lVjpmZuWAxZfwRUjSdNAQGzeM&_nc_zt=23&_nc_ht=scontent.fcmb2-2.fna&_nc_gid=B8_3DpQu-NVuxbh88oLj9g&oh=00_AflsHew6haVh3RX9-EaSMVQgALlWeMKtnZne-Is1X7Z60g&oe=69400904)'
                  }}
                >
                  <div className="absolute inset-0 bg-gradient-to-t from-[#1d1e22]/80 via-[#1d1e22]/40 to-transparent"></div>
                </div>

                {/* Play Button */}
                <motion.button
                  onClick={() => setIsPlaying(true)}
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.95 }}
                  className="absolute inset-0 flex items-center justify-center group cursor-pointer"
                >
                  <motion.div
                    animate={{
                      scale: [1, 1.1, 1],
                    }}
                    transition={{
                      duration: 2,
                      repeat: Infinity,
                      ease: "easeInOut"
                    }}
                    className="w-24 h-24 bg-white rounded-full flex items-center justify-center shadow-2xl group-hover:bg-[#3b82f6] transition-colors duration-300"
                  >
                    <Play className="w-10 h-10 text-[#1d1e22] ml-2 group-hover:text-white transition-colors duration-300" fill="currentColor" />
                  </motion.div>
                </motion.button>

                {/* Play Button Text */}
                <div className="absolute bottom-8 left-0 right-0 text-center">
                  <motion.p
                    animate={{ opacity: [0.7, 1, 0.7] }}
                    transition={{ duration: 2, repeat: Infinity }}
                    className="text-white text-lg"
                  >
                    {t.playButton}
                  </motion.p>
                </div>
              </>
            ) : (
              /* Video Player - Replace with your actual video URL */
              <iframe
                className="w-full h-full"
                  src="https://www.youtube.com/embed/xNQjYPs6uJU?autoplay=1"
                  title="Soyuru Sathkara Introduction"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
              ></iframe>
            )}
          </div>
        </motion.div>
      </div>
    </section>
  );
}

'use client';

import { School, Users, BookOpen, ArrowRight } from "lucide-react";
import { motion } from "framer-motion";
import { useState, useEffect } from "react";
import { useLanguage } from "../contexts/LanguageContext";
import { translations } from "../translations";

export function SchoolsOutreach() {
  const { language } = useLanguage();
  const t = translations[language].schoolsOutreach;
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  const backgroundImages = [
    "https://scontent.fcmb2-2.fna.fbcdn.net/v/t39.30808-6/476836393_1139484798215750_1112829780596392764_n.jpg?_nc_cat=104&ccb=1-7&_nc_sid=f727a1&_nc_eui2=AeEPjGBYKKS116U2TLKq7y6zvQ4iCyhUQmS9DiILKFRCZD1UyJjEAueyEL0dmzxIw9P_vsgZxE86IzZUeHVTzuf6&_nc_ohc=E7z8Jx8A5qMQ7kNvwEm9YOo&_nc_oc=Adnp2PTXuFn1c01pnVA2BbCvW5ZEQi5v0srFkkpn8obFrd94krNhzTema3tmFUtre8M&_nc_zt=23&_nc_ht=scontent.fcmb2-2.fna&_nc_gid=VNhJPyaWYwnd3xTjiMFaDw&oh=00_AfnhjgICWOpSSgCj6s4mscF0foZEWPY7fwGLcZu8VWQt7A&oe=69401F2E",
    "https://scontent.fcmb2-2.fna.fbcdn.net/v/t39.30808-6/477439081_1139484788215751_2716449978005112982_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=f727a1&_nc_eui2=AeFuiv_oDP6oMRcdbU2UlGqF5EmhCVdY_CfkSaEJV1j8J3TYkCR7mOGGa5eD0J1U99jTVc7Bmy-5g_3p85O22Rke&_nc_ohc=Mp-PdFlh1EcQ7kNvwEXONvm&_nc_oc=AdllfOf0rLxsPkQucD4rxylcsIjLsd39oCwZiO2wuhgayB1plqXyE2TQFnPfMzVRSuY&_nc_zt=23&_nc_ht=scontent.fcmb2-2.fna&_nc_gid=gFDKOjRY73as3YNwM_e0NQ&oh=00_Afnt6baIA7A9Uhmtlrbe-ezONm--ecBugbg0if-e0_et-g&oe=6940255B",
    "https://scontent.fcmb2-2.fna.fbcdn.net/v/t39.30808-6/484511193_1171510201679876_5419784680363484887_n.jpg?stp=cp6_dst-jpg_tt6&_nc_cat=108&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeGDyFE_5zYJ9d-l_l-_4RMd1cc8oFFYTubVxzygUVhO5syw-R2W34aDPAqPX2QfPjaW5oiIWelzJgmxbSwcvwIY&_nc_ohc=67DdC7ekd9AQ7kNvwEULfjF&_nc_oc=AdmqzyvuFyCjcPPIZ5DN6loQgoJzktMWe7i-IAFM37pu59IYaHrkp6YXCkiVvyDXVUY&_nc_zt=23&_nc_ht=scontent.fcmb2-2.fna&_nc_gid=_0IsErpbM2Iie9gVx2fQgA&oh=00_AfmzRFlHfapKrpaL99pxD8gPTXEO-OgQ0ZLkN09-SvUW-g&oe=693FEFAC",
    "https://scontent.fcmb2-2.fna.fbcdn.net/v/t39.30808-6/485370289_1171520125012217_6537229849069334208_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeEOm4dIWuavRAvdlCge1ZSwQOHQov2fwftA4dCi_Z_B-1gYvmj69Cc5l-jzWeKRmoF5HST547N9hQJ9Av8ofgrv&_nc_ohc=JknZ7jEYLzQQ7kNvwFaSx3n&_nc_oc=Adkzq4rotJN0o4Yf7QmKOTgTciladw-9gtCZ_o_8zg_t3nDD_hggMMVinqCitIaV-Mo&_nc_zt=23&_nc_ht=scontent.fcmb2-2.fna&_nc_gid=BiPKumrknFP64WMwIHgiwA&oh=00_Afk-3DB99onJbfrove7uTGChfWOUDBjp_mlUlYIQGIP2rQ&oe=69402667",
    "https://scontent.fcmb2-2.fna.fbcdn.net/v/t39.30808-6/485161605_1171699988327564_6316482697652813926_n.jpg?stp=cp6_dst-jpg_tt6&_nc_cat=102&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeE-MxBVvrMzI_uwg5ATdc_IWvlf6696yC5a-V_rr3rILtmTsntCG6ox2CQOdci_STqhoncv5PEiu63rKI4I8xOH&_nc_ohc=UeGfvZ3k98cQ7kNvwFpvjHH&_nc_oc=Admb5ZfgX7qnuFC5dDmwgLqNZ6_usAujx0XWM5TCGQpDM-218gfRqrVBtsWl5Z_cZAQ&_nc_zt=23&_nc_ht=scontent.fcmb2-2.fna&_nc_gid=etHEncdmE9iAL9SG2SxdvQ&oh=00_AfnGkTes-FCkHbhZWQtrn_k63VZuHbeJChe55rexpEATpw&oe=69401FE3"
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
            className="absolute inset-0 bg-cover bg-center"
            style={{ backgroundImage: `url(${image})` }}
            initial={{ opacity: 0 }}
            animate={{ 
              opacity: currentImageIndex === index ? 1 : 0,
              scale: currentImageIndex === index ? 1.1 : 1
            }}
            transition={{ duration: 1.5 }}
          />
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

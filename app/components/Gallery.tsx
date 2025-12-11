'use client';

import { motion } from "framer-motion";
import { ImageWithFallback } from "./figma/ImageWithFallback";
import { useLanguage } from "../contexts/LanguageContext";
import { translations } from "../translations";
import Image from "next/image";

export function Gallery() {
  const { language } = useLanguage();
  const t = translations[language].gallery;

  const images = [
    {
      url: "https://scontent.fcmb2-2.fna.fbcdn.net/v/t39.30808-6/482352701_1171708911660005_5945599259017844598_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeFTE6rfPh7N5qETByHys-b29h1UGXLmu0n2HVQZcua7SZLw3MST1DhC-jA71qXenloaL2LDCHsqtv5Gyfefp9qY&_nc_ohc=sSdyS5WFrTgQ7kNvwGMk19n&_nc_oc=AdkH3FjF6u4My1Nr38O70DzLpIcS2WZBJrx5yRRmQ4zEFvlnIAJhrAoUQtJherseamk&_nc_zt=23&_nc_ht=scontent.fcmb2-2.fna&_nc_gid=KZzpCZi8TDdsG2t7I6Aneg&oh=00_AfnDwD9pW6XKuYjcgSOnDBvvnhf1GEx_kzg7FZ4A14UiSg&oe=693FF64F",
      alt: "Teaching session"
    },
    {
      url: "https://scontent.fcmb2-2.fna.fbcdn.net/v/t39.30808-6/578274292_1384477473716480_6855652877648569986_n.jpg?_nc_cat=109&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeFb5if1g3A2XpFvOQEl_ed2pbB68G2VV-ilsHrwbZVX6OCX5_idGQrv22M5WamGu_4a1YU9Vs-ReBcVlwAF8R_t&_nc_ohc=kbDRkFyZy60Q7kNvwFuRWqp&_nc_oc=Admsfvxq-Bmz2IPw5SuhKb6WkOzGCuXwuBOlDHPi3xETQiLRN69j5wIHnyeVeofvc9k&_nc_zt=23&_nc_ht=scontent.fcmb2-2.fna&_nc_gid=iTio_B8qT0F16sACCmbLOA&oh=00_Afnlsd4YOZ4K4e541oxjO5I7weNZFfrHZI39UQZQz6LtgQ&oe=69400ADF",
      alt: "Students learning"
    },
    {
      url: "https://scontent.fcmb2-2.fna.fbcdn.net/v/t39.30808-6/485014761_1171510108346552_4792997300783869151_n.jpg?stp=cp6_dst-jpg_tt6&_nc_cat=109&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeE1Pw_GCfv_7GdrTYOt8LsFw2agizAj5fTDZqCLMCPl9HAUmv56BjGkpFJu3Taw4M7uGmco5E_m-ZE-9Vh-6W7f&_nc_ohc=n_2Cf3NOnSkQ7kNvwEJh4b1&_nc_oc=AdkOiP9VaxfPec6EqKfK6Qf2zRDuexT4Rhcx1QOfBoPgUELu0TETWo7_5j7-UdDQRks&_nc_zt=23&_nc_ht=scontent.fcmb2-2.fna&_nc_gid=E0Razn67Rh1XnmmMgAELgA&oh=00_AfmrYBNUncGumA_HRwwcELeLDFNg70_4nKgdpzVbUGifvg&oe=6940144C",
      alt: "School visit"
    },
    {
      url: "https://scontent.fcmb2-2.fna.fbcdn.net/v/t39.30808-6/485746287_1171711351659761_2635739756535955095_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeHDDm5EbDzl_Y2Jo1JSQwRm9Pt0wiW876z0-3TCJbzvrOmMR582EQUUTp_dT_QjHStkL4uS_qverjWzeZ7Ubfdc&_nc_ohc=7m7Jexcu_awQ7kNvwGnJM1W&_nc_oc=AdkDXyvskOTX6PCjQsY7wlMhGtfiFfvb2xAr1tCbiO1fG10qge77U_Jpt9sDHXYo5SM&_nc_zt=23&_nc_ht=scontent.fcmb2-2.fna&_nc_gid=HU-i5ESbVSAUb67BAiKxIQ&oh=00_AfkJ_nTDtC2f-HZHgDaWYw9xNC3cV60o0LpuQw2TvKetjA&oe=693FF12F",
      alt: "Students studying"
    },
    {
      url: "https://scontent.fcmb2-2.fna.fbcdn.net/v/t39.30808-6/484828123_1171520501678846_6901979404290067093_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeH__q61DAMwa6L0srTkL1j5-NR3XEZGgcT41HdcRkaBxJCQuxhwljEBoPm4X7OcgcTn7lQHnvTqxTKlbGCBXvXX&_nc_ohc=19Xh_-wB-6YQ7kNvwGrIWHk&_nc_oc=Adnm6bJW2b3dA0tFM3TLEWV4oMbVGKh5o8Xm2mrsgMElRkyXG5cdiw77vCK4JiSK3vw&_nc_zt=23&_nc_ht=scontent.fcmb2-2.fna&_nc_gid=_cJ3Hiu5KwjYO-Veni-cYQ&oh=00_AfkbhDEzuM2EK6XoxHkWzIgwWAm2j_7RwuxViDTF4BBhDQ&oe=693FFFCF",
      alt: "Rural school"
    },
    {
      url: "https://scontent.fcmb2-2.fna.fbcdn.net/v/t39.30808-6/485052090_1171512785012951_6998057282669561_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeEiFrR8X_uKjHW4ViznjTpegW6qXAKKKLSBbqpcAoootMu1hnGBFnQj1t0uim5tNX_mRAFj_sFiD86T8Wl52Zz6&_nc_ohc=mbf5O5Yx-A8Q7kNvwFAXWIl&_nc_oc=Admh_ytWRYBcqXcSZMY-NAONCMR8WJzPkwmtC6nFRGLxCaAm1sfmZE1naBfZIPWkFPo&_nc_zt=23&_nc_ht=scontent.fcmb2-2.fna&_nc_gid=8cWXJ5PFFvi48o5HBUSLuQ&oh=00_AfmLfUwMP5AcGArI2HEbDKv6ac9po3-2QYcxZttMlepJaA&oe=693FF566",
      alt: "Books and education"
    }
  ];

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, scale: 0.8 },
    visible: {
      opacity: 1,
      scale: 1,
      transition: {
        duration: 0.5
      }
    }
  };

  return (
    <section id="gallery" className="py-24 bg-[#acb8c3] relative overflow-hidden">
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
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          className="grid md:grid-cols-2 lg:grid-cols-3 gap-6"
        >
          {images.map((image, index) => (
            <motion.div
              key={index}
              variants={itemVariants}
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
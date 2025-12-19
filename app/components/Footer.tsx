"use client";

import { BookOpen, Mail, Phone, MapPin, Facebook, Twitter, Instagram, Youtube } from "lucide-react";
import { useLanguage } from "../contexts/LanguageContext";
import { translations } from "../translations";

export function Footer() {
  const { language } = useLanguage();
  const t = translations[language].footer;

  return (
    <footer id="contact" className="bg-gradient-to-br from-[#1d1e22] via-[#393f4d] to-[#1d1e22] text-white">
      <div className="max-w-7xl mx-auto px-6 py-16">
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-12 mb-12">
          {/* Brand */}
          <div>
            <div className="flex items-center gap-3 mb-6">
              <div className="bg-white/10 backdrop-blur-sm p-2 rounded-lg">
                <BookOpen className="w-8 h-8 text-white" />
              </div>
              <span className="text-2xl">{t.brand.name}</span>
            </div>
            <p className="text-white/80 mb-6">
              {t.brand.description}
            </p>
            <div className="flex gap-4">
              <a href="https://www.facebook.com/efsu.soyura" className="w-10 h-10 bg-white/10 rounded-lg flex items-center justify-center hover:bg-white/20 transition-colors">
                <Facebook className="w-5 h-5" />
              </a>
              {/* <a href="#" className="w-10 h-10 bg-white/10 rounded-lg flex items-center justify-center hover:bg-white/20 transition-colors">
                <Twitter className="w-5 h-5" />
              </a> */}
              {/* <a href="#" className="w-10 h-10 bg-white/10 rounded-lg flex items-center justify-center hover:bg-white/20 transition-colors">
                <Instagram className="w-5 h-5" />
              </a> */}
              <a href="https://www.youtube.com/@SoyuruSathkaraya" className="w-10 h-10 bg-white/10 rounded-lg flex items-center justify-center hover:bg-white/20 transition-colors">
                <Youtube className="w-5 h-5" />
              </a>
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="text-xl mb-6">{t.quickLinks.title}</h3>
            <ul className="space-y-3">
              <li><a href="#about" className="text-white/80 hover:text-white transition-colors">{t.quickLinks.about}</a></li>
              <li><a href="#" className="text-white/80 hover:text-white transition-colors">{t.quickLinks.resources}</a></li>
              <li><a href="#gallery" className="text-white/80 hover:text-white transition-colors">{t.quickLinks.gallery}</a></li>
              <li><a href="#" className="text-white/80 hover:text-white transition-colors">Papers</a></li>
              <li><a href="#" className="text-white/80 hover:text-white transition-colors">Short Notes</a></li>
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h3 className="text-xl mb-6">{t.resources.title}</h3>
            <ul className="space-y-3">
              <li><a href="#" className="text-white/80 hover:text-white transition-colors">{t.resources.videos}</a></li>
              <li><a href="#" className="text-white/80 hover:text-white transition-colors">{t.resources.notes}</a></li>
              <li><a href="#" className="text-white/80 hover:text-white transition-colors">{t.resources.shortNotes}</a></li>
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h3 className="text-xl mb-6">{t.contact.title}</h3>
            <ul className="space-y-4">
              <li className="flex items-start gap-3">
                <Mail className="w-5 h-5 text-[#3b82f6] flex-shrink-0 mt-1" />
                <span className="text-white/80">soyuru-sathkara@efsu-uom.lk</span>
              </li>
              <li className="flex items-start gap-3">
                <MapPin className="w-5 h-5 text-[#3b82f6] flex-shrink-0 mt-1" />
                <span className="text-white/80">Colombo, Sri Lanka</span>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="border-t border-white/10 pt-8">
          <div className="flex flex-col md:flex-row justify-between items-center gap-4">
            <p className="text-white/60">
              {t.bottom.copyright}
            </p>
            <div className="flex gap-6">
              <a href="#" className="text-white/60 hover:text-white transition-colors">{t.bottom.privacy}</a>
              <a href="#" className="text-white/60 hover:text-white transition-colors">{t.bottom.terms}</a>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}
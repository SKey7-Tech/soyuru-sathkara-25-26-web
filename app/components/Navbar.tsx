"use client";

import { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X, BookOpen, FileText, Image, Mail, Home } from "lucide-react";
import { useLanguage } from "../contexts/LanguageContext";
import { translations } from "../translations";

export function Navbar() {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isHeroSection, setIsHeroSection] = useState(true);
  const [isDarkSection, setIsDarkSection] = useState(false);
  const { language, setLanguage } = useLanguage();
  const mobileMenuRef = useRef<HTMLDivElement>(null);

  const t = translations[language];

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
      
      // Check if we're in the hero section
      const heroSection = document.getElementById('home');
      if (heroSection) {
        const heroBottom = heroSection.offsetTop + heroSection.offsetHeight;
        setIsHeroSection(window.scrollY < heroBottom - 100);
      }

      // Check if we're in schoolsoutreach or footer section
      const schoolsOutreachSection = document.querySelector('section')?.nextElementSibling?.nextElementSibling?.nextElementSibling?.nextElementSibling;
      const footerSection = document.querySelector('footer');
      
      let inDarkSection = false;
      
      if (schoolsOutreachSection) {
        const rect = schoolsOutreachSection.getBoundingClientRect();
        if (rect.top <= 100 && rect.bottom > 0) {
          inDarkSection = true;
        }
      }
      
      if (footerSection) {
        const rect = footerSection.getBoundingClientRect();
        if (rect.top <= 100) {
          inDarkSection = true;
        }
      }
      
      setIsDarkSection(inDarkSection);
    };

    handleScroll(); // Initial check
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  // Close mobile menu when scrolling
  useEffect(() => {
    const handleScroll = () => {
      if (isMobileMenuOpen) {
        setIsMobileMenuOpen(false);
      }
    };

    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, [isMobileMenuOpen]);

  // Focus trap for mobile menu
  useEffect(() => {
    if (!isMobileMenuOpen || !mobileMenuRef.current) return;

    const menuElement = mobileMenuRef.current;
    const focusableElements = menuElement.querySelectorAll(
      'a[href], button, [tabindex]:not([tabindex="-1"])'
    );
    const firstElement = focusableElements[0] as HTMLElement;
    const lastElement = focusableElements[focusableElements.length - 1] as HTMLElement;

    // Focus first element when menu opens
    firstElement?.focus();

    const handleTabKey = (e: KeyboardEvent) => {
      if (e.key !== 'Tab') return;

      if (e.shiftKey) {
        // Shift + Tab
        if (document.activeElement === firstElement) {
          e.preventDefault();
          lastElement?.focus();
        }
      } else {
        // Tab
        if (document.activeElement === lastElement) {
          e.preventDefault();
          firstElement?.focus();
        }
      }
    };

    const handleEscapeKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        setIsMobileMenuOpen(false);
      }
    };

    menuElement.addEventListener('keydown', handleTabKey as any);
    document.addEventListener('keydown', handleEscapeKey);

    return () => {
      menuElement.removeEventListener('keydown', handleTabKey as any);
      document.removeEventListener('keydown', handleEscapeKey);
    };
  }, [isMobileMenuOpen]);

  const navLinks = [
    { 
      name: language === "en" ? "Home" : language === "si" ? "මුල් පිටුව" : "முகப்பு",
      href: "#home",
      icon: Home
    },
    {
      name: language === "en" ? "Papers" : language === "si" ? "ප්‍රශ්න පත්‍ර" : "தாள்கள்",
      href: "#papers",
      icon: BookOpen
    },
    {
      name: language === "en" ? "Short Notes" : language === "si" ? "කෙටි සටහන්" : "குறுகிய குறிப்புகள்",
      href: "#shortnotes",
      icon: FileText
    },
    {
      name: language === "en" ? "Theory Notes" : language === "si" ? "න්‍යාය සටහන්" : "கோட்பாடு குறிப்புகள்",
      href: "#theorynotes",
      icon: FileText
    },
    {
      name: language === "en" ? "Gallery" : language === "si" ? "ගැලරිය" : "கேலரி",
      href: "#gallery",
      icon: Image
    },
    {
      name: language === "en" ? "Contact" : language === "si" ? "අමතන්න" : "தொடர்பு",
      href: "#contact",
      icon: Mail
    }
  ];

  const languages = [
    { code: "en" as const, name: "EN", fullName: "English" },
    { code: "si" as const, name: "සිං", fullName: "සිංහල" },
    { code: "ta" as const, name: "த", fullName: "தமிழ்" }
  ];

  return (
    <>
      <motion.nav
        initial={{ y: -100 }}
        animate={{ y: 0 }}
        transition={{ type: "spring", stiffness: 100, damping: 20 }}
        style={{
          backgroundColor: (isHeroSection || isDarkSection)
            ? (isScrolled ? 'rgba(57, 63, 77, 0.95)' : 'rgba(57, 63, 77, 0.9)')
            : (isScrolled ? 'rgba(249, 250, 251, 0.95)' : 'rgba(249, 250, 251, 0.9)')
        }}
        className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 ${
          isScrolled ? "backdrop-blur-md shadow-lg" : "backdrop-blur-sm"
        } ${(isHeroSection || isDarkSection) ? "" : "border-b border-gray-200"}`}
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16 md:h-20">
            {/* Logo */}
            <motion.a
              href="#home"
              className="flex items-center gap-2 md:gap-3 group focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2 rounded-lg"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <motion.div
                className="w-10 h-10 md:w-12 md:h-12 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-lg"
                whileHover={{ rotate: 360 }}
                transition={{ duration: 0.6 }}
              >
                <BookOpen className="w-5 h-5 md:w-6 md:h-6 text-white" />
              </motion.div>
              <div className="flex flex-col">
                <span className={`transition-colors ${(isHeroSection || isDarkSection) ? "text-white" : "text-blue-600"}`}>
                  {t.hero.title}
                </span>
                <span className={`text-xs hidden sm:block transition-colors ${(isHeroSection || isDarkSection) ? "text-gray-300" : "text-gray-500"}`}>
                  {language === "en" ? "Education Beyond Boundaries" : language === "si" ? "සීමාවන් ඉක්මවා අධ්‍යාපනය" : "எல்லைகளைக் கடந்த கல்வி"}
                </span>
              </div>
            </motion.a>

            {/* Desktop Navigation */}
            <div className="hidden lg:flex items-center gap-1">
              {navLinks.map((link, index) => (
                <motion.a
                  key={link.href}
                  href={link.href}
                  className={`px-4 py-2 rounded-lg transition-all relative group focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 ${
                    (isHeroSection || isDarkSection)
                      ? "text-white hover:text-blue-300 hover:bg-white/10 focus-visible:bg-white/10" 
                      : "text-gray-700 hover:text-blue-600 hover:bg-blue-50 focus-visible:bg-blue-50"
                  }`}
                  initial={{ opacity: 0, y: -20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <span className="flex items-center gap-2">
                    <link.icon className="w-4 h-4" />
                    {link.name}
                  </span>
                  <motion.div
                    className={`absolute bottom-0 left-0 right-0 h-0.5 ${(isHeroSection || isDarkSection) ? "bg-blue-300" : "bg-blue-600"}`}
                    initial={{ scaleX: 0 }}
                    whileHover={{ scaleX: 1 }}
                    transition={{ duration: 0.3 }}
                  />
                </motion.a>
              ))}
            </div>

            {/* Language Switcher & Mobile Menu Button */}
            <div className="flex items-center gap-2 md:gap-4">
              {/* Language Switcher */}
              <div className={`flex items-center gap-1 rounded-lg p-1 ${
                (isHeroSection || isDarkSection) ? "bg-white/10" : "bg-blue-50"
              }`}>
                {languages.map((lang) => (
                  <motion.button
                    key={lang.code}
                    onClick={() => setLanguage(lang.code)}
                    className={`px-2 md:px-3 py-1.5 rounded-md text-sm transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 ${
                      language === lang.code
                        ? "bg-blue-600 text-white shadow-md"
                        : (isHeroSection || isDarkSection)
                        ? "text-gray-200 hover:text-white hover:bg-white/10"
                        : "text-gray-600 hover:text-blue-600 hover:bg-blue-100"
                    }`}
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    title={lang.fullName}
                  >
                    {lang.name}
                  </motion.button>
                ))}
              </div>

              {/* Mobile Menu Button */}
              <motion.button
                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                aria-label={isMobileMenuOpen ? "Close menu" : "Open menu"}
                aria-expanded={isMobileMenuOpen}
                className={`lg:hidden p-2 rounded-lg transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 ${
                  (isHeroSection || isDarkSection)
                    ? "bg-white/10 text-white hover:bg-white/20"
                    : "bg-blue-50 text-blue-600 hover:bg-blue-100"
                }`}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                {isMobileMenuOpen ? (
                  <X className="w-6 h-6" />
                ) : (
                  <Menu className="w-6 h-6" />
                )}
              </motion.button>
            </div>
          </div>
        </div>
      </motion.nav>

      {/* Mobile Menu */}
      <AnimatePresence>
        {isMobileMenuOpen && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsMobileMenuOpen(false)}
              className="fixed inset-0 bg-black/50 backdrop-blur-sm z-40 lg:hidden"
            />

            {/* Menu Content */}
            <motion.div
              ref={mobileMenuRef}
              role="dialog"
              aria-modal="true"
              aria-label="Mobile navigation menu"
              initial={{ x: "100%" }}
              animate={{ x: 0 }}
              exit={{ x: "100%" }}
              transition={{ type: "spring", damping: 25, stiffness: 200 }}
              className="fixed top-16 md:top-20 right-0 bottom-0 w-full max-w-sm bg-white shadow-2xl z-40 lg:hidden overflow-y-auto"
            >
              <div className="p-6 space-y-2">
                {navLinks.map((link, index) => (
                  <motion.a
                    key={link.href}
                    href={link.href}
                    onClick={() => setIsMobileMenuOpen(false)}
                    className="flex items-center gap-3 px-4 py-3 rounded-xl text-gray-700 hover:text-blue-600 hover:bg-blue-50 transition-all group focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-inset"
                    initial={{ opacity: 0, x: 50 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.05 }}
                    whileTap={{ scale: 0.98 }}
                  >
                    <div className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center group-hover:bg-blue-100 transition-colors">
                      <link.icon className="w-5 h-5 text-blue-600" />
                    </div>
                    <span>{link.name}</span>
                  </motion.a>
                ))}
              </div>

              {/* Mobile Menu Footer */}
              <div className="p-6 border-t border-gray-100">
                <p className="text-sm text-gray-500 text-center">
                  {t.footer.brand.description}
                </p>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Spacer to prevent content from going under navbar */}
      <div className="h-16 md:h-20" />
    </>
  );
}
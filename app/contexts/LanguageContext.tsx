"use client";

import { createContext, useContext, useState, useEffect, ReactNode } from "react";

type Language = "en" | "si" | "ta";

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

const LANGUAGE_STORAGE_KEY = "soyuru-sathkara-language";

export function LanguageProvider({ children }: { children: ReactNode }) {
  // Initialize with default, will be updated from localStorage on client
  const [language, setLanguageState] = useState<Language>("en");
  const [isInitialized, setIsInitialized] = useState(false);

  // Load saved language preference on mount (client-side only)
  useEffect(() => {
    try {
      const savedLanguage = localStorage.getItem(LANGUAGE_STORAGE_KEY) as Language | null;
      if (savedLanguage && (savedLanguage === "en" || savedLanguage === "si" || savedLanguage === "ta")) {
        setLanguageState(savedLanguage);
      }
    } catch (error) {
      // localStorage not available (e.g., private browsing), use default
      console.warn("Failed to load language preference:", error);
    } finally {
      setIsInitialized(true);
    }
  }, []);

  // Custom setter that persists to localStorage
  const setLanguage = (lang: Language) => {
    setLanguageState(lang);
    try {
      localStorage.setItem(LANGUAGE_STORAGE_KEY, lang);
    } catch (error) {
      // localStorage not available, just update state
      console.warn("Failed to save language preference:", error);
    }
  };

  return (
    <LanguageContext.Provider value={{ language, setLanguage }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error("useLanguage must be used within a LanguageProvider");
  }
  return context;
}

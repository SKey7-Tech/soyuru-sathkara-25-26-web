import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { LanguageProvider } from "./contexts/LanguageContext";
import { Navbar } from "./components/Navbar";
import { Footer } from "./components/Footer";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  metadataBase: new URL("https://ss.efsu-uom.lk"),
  title: "Soyuru Sathkara - Education Beyond Boundaries",
  description: "Comprehensive learning resources for G.C.E. A/L students",
  keywords: ["GCE A/L", "Sri Lanka", "education", "learning resources", "papers", "video lectures", "theory notes", "uom", "University of Moratuwa"],
  authors: [{ name: "Soyuru Sathkara", url: "https://ss.efsu-uom.lk" }],
  publisher: "Soyuru Sathkara",
  alternates: {
    canonical: "https://ss.efsu-uom.lk",
    languages: {
      "en": "/",
      "si": "/si",
      "ta": "/ta",
    },
  },
  openGraph: {
    title: "Soyuru Sathkara - Education Beyond Boundaries",
    description: "Comprehensive learning resources for G.C.E. A/L students",
    url: "https://ss.efsu-uom.lk",
    siteName: "Soyuru Sathkara",
    // images: [
    //   {
    //     url: 'og-image.png',
    //     width: 1200,
    //     height: 630,
    //     alt: 'Soyuru Sathkara',
    //     type: 'image/png',
    //   }
    // ]
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Soyuru Sathkara - Education Beyond Boundaries",
    description: "Comprehensive learning resources for G.C.E. A/L students",
    // images: ['og-image.png'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  verification: {
    // google: "your-google-verification-code",
  }
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        <LanguageProvider>
          <Navbar />
          {children}
          <Footer />
        </LanguageProvider>
      </body>
    </html>
  );
}

import { Suspense } from "react";
import { Hero } from "./components/Hero";
import { QuickLinks } from "./components/QuickLinks";
import { Gallery } from "./components/Gallery";
import { IntroVideo } from "./components/IntroVideo";
// import { SchoolsOutreach } from "./components/SchoolsOutreach";
import { ErrorBoundary } from "./components/ErrorBoundary";
import { QuickLinksSkeleton, GallerySkeleton, IntroVideoSkeleton, SchoolsOutreachSkeleton } from "./components/LoadingSkeletons";

export default function Home() {
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "EducationalOrganization",
    "name": "Soyuru Sathkara",
    "alternateName": "සොයුරු සත්කාර",
    "description": "Comprehensive G.C.E. A/L learning resources including video lectures, theory notes, short notes, and past papers for Sri Lankan students. Empowering students with quality education beyond boundaries.",
    "url": "https://soyurusathkara.com",
    "address": {
      "@type": "PostalAddress",
      "addressCountry": "LK",
      "addressRegion": "Sri Lanka"
    },
    "sameAs": [
      "https://www.facebook.com/efsu.soyura/",
      "https://www.youtube.com/@SoyuruSathkaraya"
    ],
    "areaServed": {
      "@type": "Country",
      "name": "Sri Lanka"
    },
    "availableLanguage": [
      {
        "@type": "Language",
        "name": "English",
        "alternateName": "en"
      },
      {
        "@type": "Language",
        "name": "Sinhala",
        "alternateName": "si"
      },
      {
        "@type": "Language",
        "name": "Tamil",
        "alternateName": "ta"
      }
    ],
    "educationalCredentialAwarded": "G.C.E. Advanced Level Preparation",
    "offers": {
      "@type": "Offer",
      "price": "0",
      "priceCurrency": "LKR",
      "availability": "https://schema.org/InStock",
      "description": "Free access to all learning materials, video lessons, past papers, theory notes, and short notes"
    },
    "hasOfferCatalog": {
      "@type": "OfferCatalog",
      "name": "Educational Resources",
      "itemListElement": [
        {
          "@type": "Offer",
          "itemOffered": {
            "@type": "Course",
            "name": "Past Papers",
            "description": "Download previous G.C.E. A/L exam papers and practice"
          }
        },
        {
          "@type": "Offer",
          "itemOffered": {
            "@type": "Course",
            "name": "Short Notes",
            "description": "Quick revision summaries for all subjects"
          }
        },
        {
          "@type": "Offer",
          "itemOffered": {
            "@type": "Course",
            "name": "Theory Notes",
            "description": "In-depth theory explanations and concepts"
          }
        },
        {
          "@type": "Offer",
          "itemOffered": {
            "@type": "VideoObject",
            "name": "Video Lessons",
            "description": "Comprehensive video lectures for all subjects"
          }
        }
      ]
    },
    "knowsAbout": [
      "G.C.E. Advanced Level",
      "Sri Lankan Education",
      "Online Learning",
      "Educational Resources",
      "Video Lessons",
      "Study Materials"
    ]
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }}
      />
      <main className="min-h-screen bg-white">
        <ErrorBoundary componentName="Hero">
          <Hero />
        </ErrorBoundary>
        
        <ErrorBoundary componentName="Quick Links">
          <Suspense fallback={<QuickLinksSkeleton />}>
            <section id="quick-links" aria-label="Quick Links">
              <QuickLinks />
            </section>
          </Suspense>
        </ErrorBoundary>
        
        <ErrorBoundary componentName="Introduction Video">
          <Suspense fallback={<IntroVideoSkeleton />}>
            <section id="intro-video" aria-label="Introduction Video">
              <IntroVideo />
            </section>
          </Suspense>
        </ErrorBoundary>
        
        <ErrorBoundary componentName="Gallery">
          <Suspense fallback={<GallerySkeleton />}>
            <section id="gallery" aria-label="Photo Gallery">
              <Gallery />
            </section>
          </Suspense>
        </ErrorBoundary>
        
        {/* <ErrorBoundary componentName="Schools Outreach">
          <Suspense fallback={<SchoolsOutreachSkeleton />}>
            <section id="schools-outreach" aria-label="Schools Outreach Program">
              <SchoolsOutreach />
            </section>
          </Suspense>
        </ErrorBoundary> */}
      </main>
    </>
  );
};


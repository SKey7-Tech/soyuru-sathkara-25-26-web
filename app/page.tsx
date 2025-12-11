import { Hero } from "./components/Hero";
import { QuickLinks } from "./components/QuickLinks";
import { Gallery } from "./components/Gallery";
import { IntroVideo } from "./components/IntroVideo";
import { SchoolsOutreach } from "./components/SchoolsOutreach";

export default function Home() {
  return (
    <main className="min-h-screen bg-white">
      <Hero />
      <QuickLinks />
      <IntroVideo />
      <Gallery />
      <SchoolsOutreach />
    </main>
  );
}

# Website (Next.js)

Next.js 16 App Router, React 19, Tailwind CSS 4, Framer Motion, lucide-react.
TypeScript `strict`, path alias `@/*` → repo root.

## Routes

| Route | File | Rendering | Notes |
| --- | --- | --- | --- |
| `/` | [app/page.tsx](../web/app/page.tsx) | Server | Landing page; emits `EducationalOrganization` JSON-LD |
| `/resources/papers` | [app/resources/papers/page.tsx](../web/app/resources/papers/page.tsx) | Client | Queries `papers` where `paper_type in ('model','past','term')` |
| `/resources/short-notes` | [app/resources/short-notes/page.tsx](../web/app/resources/short-notes/page.tsx) | Client | Queries `papers` where `paper_type = 'notes'` |
| `/resources/theory` | [app/resources/theory/page.tsx](../web/app/resources/theory/page.tsx) | Client | Queries `papers` where `paper_type = 'notes'` |
| `/admin/*` | [app/admin/](../web/app/admin/) | Server | See [admin-panel.md](admin-panel.md) |
| `/sitemap.xml` | [app/sitemap.ts](../web/app/sitemap.ts) | Generated | Add new SEO-relevant routes here |

`web/app/resources/page-old.tsx` is a retired pre-Supabase version kept for
reference. It is not routable (`page-old` is not a Next.js route file name).

> The three resource pages issue the *same* query for short notes and theory —
> both filter on `paper_type = 'notes'`, so they render identical lists. See
> [known-issues.md](known-issues.md).

## Layout and providers

[`web/app/layout.tsx`](../web/app/layout.tsx) is the single root layout for the whole
site, admin included. It:

- loads Geist Sans + Geist Mono via `next/font` with `display: swap`,
- declares all site metadata (`metadataBase` `https://ss.efsu-uom.lk`, canonical,
  hreflang alternates for en/si/ta, OpenGraph, Twitter card, robots directives,
  Google site verification),
- sets the viewport theme colour per colour scheme (`#3b82f6` light,
  `#1d1e22` dark),
- preconnects to `images.unsplash.com`,
- wraps everything in `LanguageProvider`, `Navbar` and `Footer`.

The OG image is commented out — see [known-issues.md](known-issues.md).

## Internationalisation

Three languages: **en**, **si**, **ta**. There is no `next-intl` or route-based
locale; it is a React context plus three plain TypeScript dictionaries.

```
app/contexts/LanguageContext.tsx   provider + useLanguage() hook
app/translations.ts                { en, si, ta } barrel
app/i18n/en.ts  si.ts  ta.ts       the dictionaries
```

- `LanguageProvider` holds the current language in state, hydrates it from
  `localStorage` key `soyuru-sathkara-language` on mount, and writes back on
  change. Both accesses are wrapped in `try/catch` for private-browsing mode.
- Default is `en` until the effect runs, so a Sinhala user may see one English
  frame on first paint.
- `useLanguage()` throws if used outside the provider.
- Any component that reads translations must be a Client Component
  (`"use client"`).

**Rule:** every string you add needs an `en`, `si` and `ta` entry. A missing key
renders `undefined`, not a fallback.

Dictionary shape (see `web/app/i18n/en.ts`):

```
hero, quickLinks, gallery, introVideo, schoolsOutreach,
papers { title, description, linkTitle, items: { <id>: { title, description } } },
theory, shortNotes, pdfs { button, expandD, videosHeading, videosLabel }, footer, nav
```

`items` is keyed by the resource `id` from `web/app/data/*.ts`, which is how
`Card`'s `titleKey` / `descriptionKey` props resolve.

## Components

All in [`web/app/components/`](../web/app/components/).

| Component | Type | Purpose |
| --- | --- | --- |
| `Navbar` | client | Sticky nav; scroll-aware styling over hero/dark/footer sections, mobile menu with focus trap and Escape handling, language switcher, cross-page hash navigation via `sessionStorage.scrollTarget` |
| `Footer` | client | Site links, Facebook + YouTube, trilingual labels |
| `Hero` | client | Landing hero with CTA buttons into the three resource pages |
| `QuickLinks` | client | Primary resource cards + secondary links (About/Contact point at `efsu-uom.lk`) |
| `Gallery` | client | Photo grid from `web/public/gallery/` |
| `IntroVideo` | client | Embedded introduction video |
| `SchoolsOutreach` | client | School-partnership section — **currently commented out** of `web/app/page.tsx` |
| `Card` | client | The workhorse — see below |
| `ErrorBoundary` | client class | Catches render errors per section; logs only in development; shows a refresh prompt |
| `LoadingSkeletons` | client | `QuickLinksSkeleton`, `GallerySkeleton`, `IntroVideoSkeleton`, `SchoolsOutreachSkeleton` for `<Suspense>` fallbacks |
| `figma/ImageWithFallback` | client | Image with a fallback source |

The home page wraps each section in its own `ErrorBoundary` **and** `Suspense`,
so one failing section cannot blank the page.

### `Card`

[`web/app/components/Card.tsx`](../web/app/components/Card.tsx) renders every resource
tile. Props:

| Prop | Purpose |
| --- | --- |
| `title` / `description` | Literal text |
| `titleKey` / `descriptionKey` | Translation keys, looked up in `translations[language][category].items[key]`; fall back to the literal props |
| `category` | `'papers' \| 'shortNotes' \| 'theory' \| 'pdfs'` — which dictionary section to read |
| `icon` | Defaults to a `FileText` lucide icon |
| `href` | Wraps the whole card in a `Link` |
| `downloadUrl` / `downloadFileName` | Enables the download button |
| `videos` | `{ label, url }[]` — related YouTube discussions |
| `onClick`, `className` | Passthrough |

Behaviour:

- **Download** fetches the URL as a blob, creates an object URL, clicks a hidden
  `<a download>`, then revokes after 100 ms. It surfaces HTTP errors and
  zero-byte files through `alert()`. Fetching a blob (rather than linking
  directly) is what forces a download instead of an in-browser PDF preview.
- **Video list** expands on hover on desktop (`window.innerWidth >= 768`) and on
  tap on mobile, where an explicit "see videos" button is shown. The breakpoint
  is tracked with a `resize` listener.
- Video labels are localised through `pdfs.videosLabel[label]`, falling back to
  the raw label.

## Data layer

Two generations coexist:

**Legacy — hard-coded** ([`web/app/data/`](../web/app/data/)): `papers.ts`,
`shortNotes.ts`, `theory.ts`, `pdfs.ts`. Each exports an array of
`{ id, titleKey, descriptionKey, filePath, coverImage, videos[] }` pointing at
files in `web/public/files/`. These were the source the Supabase seed was built
from, and `web/app/i18n/en.ts` still imports `papers` and `theory`.

**Current — Supabase**: the `/resources/*` pages create a browser client
(`createClient()` from `web/app/utils/supabase/client`), query `papers` with a
nested `videos(title, youtube_video_id)` join, resolve the download URL with
`supabase.storage.from('resources').getPublicUrl(storage_path)`, and pick the
title by language with a fallback to `title`:

```ts
const title = language === 'si' ? paper.title_si || paper.title
            : language === 'ta' ? paper.title_ta || paper.title
            : paper.title;
```

Each page renders a spinner while loading and a "No papers found." empty state.

## Animations

[`web/app/utils/animations.ts`](../web/app/utils/animations.ts) centralises Framer Motion
variants so motion stays consistent:

| Export | Contents |
| --- | --- |
| `containerVariants` | `default` / `slow` / `fast` — stagger 0.1 / 0.15 / 0.05 s |
| `itemVariants` | `fadeInUp` and friends |
| `pageVariants` | Page-level transitions |
| `hoverVariants` | Shared hover treatments |
| `transitionPresets` | Reusable spring/tween configs |

## Middleware

[`web/middleware.ts`](../web/middleware.ts) delegates to `updateSession` in
[`web/app/utils/supabase/middleware.ts`](../web/app/utils/supabase/middleware.ts),
which refreshes the Supabase auth cookie on every request **and gates `/admin`**.
The matcher skips `_next/static`, `_next/image`, `favicon.ico` and image
extensions.

Two rules from the `@supabase/ssr` contract that are easy to break, both noted
in the file:

1. Put no code between `createServerClient()` and `getUser()` — a slow or
   throwing call in between can log users out at random, because the refresh
   never completes.
2. Return the response object, or copy its cookies onto any redirect you build.
   The refreshed cookies live on it; dropping them signs the user out on the
   next request.

Next 16 deprecates the `middleware` file convention in favour of `proxy`
(`npx @next/codemod@canary middleware-to-proxy .`). It still works, and the
build only warns — see [roadmap.md](roadmap.md).

## Build configuration

[`web/next.config.ts`](../web/next.config.ts):

- **Images** — AVIF + WebP output, explicit `deviceSizes` / `imageSizes`, remote
  pattern allowing `images.unsplash.com`.
- **Security headers** — `X-Frame-Options: SAMEORIGIN`,
  `X-Content-Type-Options: nosniff`, `Referrer-Policy: origin-when-cross-origin`,
  `X-DNS-Prefetch-Control: on`; `poweredByHeader: false`.
- **Caching** — one-year immutable `Cache-Control` for image extensions.
- **Performance** — `compress: true`, `reactStrictMode: true`,
  `optimizePackageImports` for `framer-motion` and `lucide-react`,
  `optimizeCss: true`.
- **Compiler** — strips `console.*` in production except `error` and `warn`.

## SEO checklist

Currently handled: metadata and OG/Twitter tags in `layout.tsx`, JSON-LD
`EducationalOrganization` on the home page, `web/app/sitemap.ts`,
`web/public/robots.txt`, hreflang alternates, Google verification token.

Still open: create and wire an OG image, add remaining routes to the sitemap,
and confirm the domain is consistent everywhere (`layout.tsx`, `sitemap.ts`,
`robots.txt`, and the JSON-LD block, which still says `soyurusathkara.com`).

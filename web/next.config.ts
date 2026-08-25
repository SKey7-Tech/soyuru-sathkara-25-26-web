import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Image optimization
  images: {
    formats: ['image/avif', 'image/webp'],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
      },
    ],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
  },

  // Enable compression
  compress: true,

  // Remove X-Powered-By header for security
  poweredByHeader: false,

  // // Optimize production builds
  // swcMinify: true,

  // Performance optimizations
  reactStrictMode: true,

  // Enable experimental features for better performance
  experimental: {
    optimizePackageImports: ['framer-motion', 'lucide-react'],

    // optimizeCss is OFF on purpose. It inlines critical CSS via `critters`,
    // which is not a Next.js dependency and is not installed — with it on,
    // every render throws "Cannot find module 'critters'", including the
    // error page itself, so a real error shows up as an unrelated 500.
    //
    // To re-enable: `npm i -D critters` (or its maintained successor,
    // `beasties`) and set optimizeCss: true. Measure first — Turbopack
    // already handles CSS well and the win is usually small.
  },

  // Optimize compiler
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production' ? {
      exclude: ['error', 'warn'],
    } : false,
  },

  // Configure headers for better caching and security
  async headers() {
    return [
      {
        source: '/:all*(svg|jpg|jpeg|png|gif|ico|webp|avif)',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on',
          },
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin',
          },
        ],
      },
    ];
  },
};

export default nextConfig;

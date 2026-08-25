'use client';

import { motion } from "framer-motion";

export function QuickLinksSkeleton() {
  return (
    <section className="py-24 bg-gradient-to-b from-white to-blue-50/30">
      <div className="max-w-7xl mx-auto px-6">
        {/* Header Skeleton */}
        <div className="text-center mb-16">
          <div className="h-4 w-32 bg-gray-200 rounded mx-auto mb-4 animate-pulse" />
          <div className="h-10 w-64 bg-gray-200 rounded mx-auto mb-4 animate-pulse" />
          <div className="h-6 w-96 bg-gray-200 rounded mx-auto animate-pulse" />
        </div>

        {/* Primary Cards Skeleton */}
        <div className="grid md:grid-cols-3 gap-8 mb-12">
          {[1, 2, 3].map((i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.1 }}
              className="bg-white rounded-3xl p-8 border-2 border-gray-200 shadow-lg"
            >
              <div className="w-20 h-20 bg-gray-200 rounded-2xl mb-6 animate-pulse" />
              <div className="h-7 w-32 bg-gray-200 rounded mb-3 animate-pulse" />
              <div className="h-4 w-full bg-gray-200 rounded mb-2 animate-pulse" />
              <div className="h-4 w-3/4 bg-gray-200 rounded animate-pulse" />
            </motion.div>
          ))}
        </div>

        {/* Secondary Cards Skeleton */}
        <div className="grid md:grid-cols-3 gap-6">
          {[1, 2, 3].map((i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.1 + 0.3 }}
              className="bg-white rounded-xl p-6 border border-gray-200"
            >
              <div className="w-12 h-12 bg-gray-200 rounded-lg mb-4 animate-pulse" />
              <div className="h-6 w-24 bg-gray-200 rounded mb-2 animate-pulse" />
              <div className="h-4 w-full bg-gray-200 rounded animate-pulse" />
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}

export function GallerySkeleton() {
  return (
    <section className="py-24 bg-gradient-to-b from-white to-blue-50/30">
      <div className="max-w-7xl mx-auto px-6">
        {/* Header Skeleton */}
        <div className="text-center mb-16">
          <div className="h-4 w-24 bg-gray-200 rounded mx-auto mb-4 animate-pulse" />
          <div className="h-10 w-80 bg-gray-200 rounded mx-auto mb-4 animate-pulse" />
          <div className="h-6 w-96 bg-gray-200 rounded mx-auto animate-pulse" />
        </div>

        {/* Image Grid Skeleton */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: i * 0.1 }}
              className="relative rounded-2xl overflow-hidden shadow-lg aspect-[4/3] bg-gray-200 animate-pulse"
            />
          ))}
        </div>
      </div>
    </section>
  );
}

export function IntroVideoSkeleton() {
  return (
    <section className="py-24 bg-gradient-to-b from-white to-blue-50/30">
      <div className="max-w-7xl mx-auto px-6">
        {/* Header Skeleton */}
        <div className="text-center mb-16">
          <div className="h-4 w-32 bg-gray-200 rounded mx-auto mb-4 animate-pulse" />
          <div className="h-10 w-72 bg-gray-200 rounded mx-auto mb-4 animate-pulse" />
          <div className="h-6 w-96 bg-gray-200 rounded mx-auto animate-pulse" />
        </div>

        {/* Video Player Skeleton */}
        <div className="max-w-4xl mx-auto">
          <div className="relative rounded-3xl overflow-hidden shadow-2xl aspect-video bg-gradient-to-br from-gray-200 to-gray-300 animate-pulse flex items-center justify-center">
            <div className="w-24 h-24 bg-white/30 rounded-full flex items-center justify-center">
              <div className="w-16 h-16 bg-white/50 rounded-full" />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export function SchoolsOutreachSkeleton() {
  return (
    <section className="relative py-32 overflow-hidden">
      {/* Background Skeleton */}
      <div className="absolute inset-0 bg-gradient-to-r from-gray-800 to-gray-700 animate-pulse" />

      {/* Content Skeleton */}
      <div className="relative z-10 max-w-6xl mx-auto px-6">
        <div className="text-center mb-12">
          <div className="h-4 w-32 bg-white/20 rounded mx-auto mb-4 animate-pulse" />
          <div className="h-12 w-96 bg-white/20 rounded mx-auto mb-6 animate-pulse" />
          <div className="h-8 w-80 bg-white/20 rounded mx-auto animate-pulse" />
        </div>

        <div className="bg-white/10 backdrop-blur-lg rounded-3xl p-10 md:p-12 border border-white/20">
          <div className="h-6 w-full bg-white/20 rounded mb-4 animate-pulse" />
          <div className="h-6 w-3/4 bg-white/20 rounded mb-10 animate-pulse mx-auto" />

          <div className="grid md:grid-cols-3 gap-8 mb-10">
            {[1, 2, 3].map((i) => (
              <div key={i} className="flex items-center gap-4">
                <div className="w-12 h-12 bg-white/20 rounded-lg animate-pulse" />
                <div className="h-5 w-32 bg-white/20 rounded animate-pulse" />
              </div>
            ))}
          </div>

          <div className="flex justify-center">
            <div className="h-14 w-48 bg-white/20 rounded-xl animate-pulse" />
          </div>
        </div>
      </div>
    </section>
  );
}

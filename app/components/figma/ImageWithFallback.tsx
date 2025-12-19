'use client';

import React, { useState } from 'react'
import Image from 'next/image'

const ERROR_IMG_SRC =
  'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODgiIGhlaWdodD0iODgiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3Ryb2tlPSIjMDAwIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBvcGFjaXR5PSIuMyIgZmlsbD0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIzLjciPjxyZWN0IHg9IjE2IiB5PSIxNiIgd2lkdGg9IjU2IiBoZWlnaHQ9IjU2IiByeD0iNiIvPjxwYXRoIGQ9Im0xNiA1OCAxNi0xOCAzMiAzMiIvPjxjaXJjbGUgY3g9IjUzIiBjeT0iMzUiIHI9IjciLz48L3N2Zz4KCg=='

interface ImageWithFallbackProps {
  src: string;
  alt: string;
  width?: number;
  height?: number;
  className?: string;
  style?: React.CSSProperties;
  loading?: 'lazy' | 'eager';
  fetchPriority?: 'high' | 'low' | 'auto';
  fill?: boolean;
  sizes?: string;
  quality?: number;
}

export function ImageWithFallback({
  src,
  alt,
  width,
  height,
  className = '',
  style,
  loading = 'lazy',
  fetchPriority = 'auto',
  fill = false,
  sizes,
  quality = 90,
}: ImageWithFallbackProps) {
  const [didError, setDidError] = useState(false)
  const isPriority = fetchPriority === 'high';

  const handleError = () => {
    setDidError(true)
  }

  return didError ? (
    <div
      className={`inline-block bg-gray-100 text-center align-middle ${className}`}
      style={style}
    >
      <div className="flex items-center justify-center w-full h-full">
        <img src={ERROR_IMG_SRC} alt="Error loading image" data-original-url={src} />
      </div>
    </div>
  ) : fill ? (
    <Image
      src={src}
      alt={alt}
      fill
      className={className}
      style={style}
      {...(!isPriority && { loading })}
      {...(isPriority && { priority: true })}
      sizes={sizes || '100vw'}
      quality={quality}
      onError={handleError}
    />
  ) : (
    <Image
      src={src}
      alt={alt}
      width={width || 1920}
      height={height || 1080}
      className={className}
      style={style}
      {...(!isPriority && { loading })}
      {...(isPriority && { priority: true })}
      quality={quality}
      onError={handleError}
    />
  )
}

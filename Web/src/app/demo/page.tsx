'use client'

import { ViewportHeightFix } from '@/components/ViewportHeightFix'

export default function DemoPage() {
  return (
    <>
      <ViewportHeightFix />
      <div className="h-screen-safe bg-blue-600 overflow-y-auto">
        <div className="max-w-2xl mx-auto p-4 md:p-6 pt-8 md:pt-12">
          <div className="text-center mb-6">
            <div className="flex justify-center mb-4">
              <svg
                width="80"
                height="80"
                viewBox="0 0 100 100"
                className="animate-pulse"
              >
                <defs>
                  <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stopColor="#60A5FA" />
                    <stop offset="100%" stopColor="#3B82F6" />
                  </linearGradient>
                </defs>
                <circle
                  cx="50"
                  cy="50"
                  r="45"
                  fill="url(#gradient)"
                  stroke="white"
                  strokeWidth="2"
                />
                <path
                  d="M30 35 L70 35 L65 45 L35 45 Z"
                  fill="white"
                  opacity="0.9"
                />
                <path
                  d="M25 55 L75 55 L70 65 L30 65 Z"
                  fill="white"
                  opacity="0.7"
                />
                <circle cx="50" cy="75" r="3" fill="white" />
              </svg>
            </div>
            <h1 className="text-2xl md:text-4xl font-bold text-white mb-2">Request a Demo</h1>
            <p className="text-sm md:text-xl text-blue-100 mb-6">
              Fill out the form below and we'll get back to you within 24 hours.
            </p>
          </div>
          <div className="w-full bg-white rounded-lg p-4 md:p-6">
            <iframe
              src="https://tally.so/r/n98ZrQ?hideTitle=1&transparentBackground=1"
              width="100%"
              height="700"
              style={{ border: 0 }}
              title="FreshWall Demo Request"
              scrolling="no"
            />
          </div>
        </div>
      </div>
    </>
  )
}
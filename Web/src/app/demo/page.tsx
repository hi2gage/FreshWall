'use client'

import { useEffect } from 'react'
import Link from 'next/link'
import Image from 'next/image'

export default function DemoPage() {
  useEffect(() => {
    // Load Tally embed script
    const script = document.createElement('script')
    script.src = 'https://tally.so/widgets/embed.js'
    script.async = true
    document.head.appendChild(script)

    return () => {
      // Cleanup
      const existingScript = document.querySelector('script[src="https://tally.so/widgets/embed.js"]')
      if (existingScript) {
        document.head.removeChild(existingScript)
      }
    }
  }, [])

  return (
    <div className="min-h-screen bg-neutral-tone">
      {/* Header with Logo and Back Link */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
          <Link href="/" className="flex items-center">
            <Image
              src="/logo/primary-horizontal-logo-light.svg"
              alt="FreshWall"
              width={150}
              height={68}
              className="hover:opacity-80 transition-opacity"
              priority
            />
          </Link>
          <Link
            href="/"
            className="text-body-sm text-charcoal-navy hover:text-freshwall-orange transition-colors font-medium"
          >
            ← Back to Home
          </Link>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8 md:py-12 pb-16">
        <div className="text-center mb-8">
          <h1 className="text-h1 font-montserrat font-bold text-copy-black mb-4">
            Book Your Demo
          </h1>
          <p className="text-body-lg text-gray-600 max-w-2xl mx-auto">
            See how FreshWall can simplify your graffiti removal business in just 15 minutes.
          </p>
        </div>

        {/* Tally Form Container */}
        <div className="bg-white rounded-xl shadow-lg p-6 md:p-8">
          <iframe
            data-tally-src="https://tally.so/r/n98ZrQ?transparentBackground=1&hideTitle=1"
            width="100%"
            height="1200"
            frameBorder="0"
            marginHeight={0}
            marginWidth={0}
            title="Demo Request"
            className="border-0"
            style={{ overflow: 'hidden' }}
            suppressHydrationWarning
          />
        </div>
      </div>
    </div>
  )
}
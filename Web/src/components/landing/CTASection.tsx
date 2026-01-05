'use client'

import { Section } from '@/components/ui/Section'
import { Button } from '@/components/ui/Button'
import Image from 'next/image'
import { useRouter } from 'next/navigation'
import { logDemoClick } from '@/lib/analytics'

export const CTASection = () => {
  const router = useRouter()

  const handleDemoClick = () => {
    void logDemoClick('cta')
    router.push('/demo?source=cta')
  }

  return (
    <Section background="navy" className="py-16 md:py-24">
      {/* Title - Centered above both columns */}
      <h2 className="font-montserrat text-3xl md:text-4xl lg:text-5xl font-bold mb-12 text-white text-center">
        Take the first step
        <br />
        toward a smoother business
      </h2>

      <div className="grid md:grid-cols-2 gap-12 items-center">
        {/* Left Column - Text Content */}
        <div className="text-white">
          <div className="space-y-6 mb-8">
            <p className="font-montserrat text-xl md:text-2xl font-semibold">
              In just 15 minutes
            </p>
            <p className="font-inter text-lg text-gray-300">
              we&apos;ll show you how FreshWall can simplify your business, reduce stress, and help you get paid faster.
            </p>
          </div>

          <div className="space-y-4">
            <Button
              variant="primary"
              size="lg"
              colorScheme="dark"
              onClick={handleDemoClick}
            >
              Book a Demo
            </Button>
            <p className="font-inter text-sm text-gray-400">
              No commitment.
            </p>
          </div>
        </div>

        {/* Right Column - Illustration */}
        <div className="flex justify-center md:justify-end">
          <div className="w-full max-w-md">
            <Image
              src="/person-message-icon.svg"
              alt="Book a Demo"
              width={400}
              height={400}
              className="w-full h-auto"
            />
          </div>
        </div>
      </div>
    </Section>
  )
}

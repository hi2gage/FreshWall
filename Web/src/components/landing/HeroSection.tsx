'use client'

import { Section } from '@/components/ui/Section'
import { Button } from '@/components/ui/Button'
import Image from 'next/image'
import { useRouter } from 'next/navigation'
import { logDemoClick } from '@/lib/analytics'

export const HeroSection = () => {
  const router = useRouter()

  const handleDemoClick = () => {
    void logDemoClick('hero')
    router.push('/demo?source=hero')
  }

  return (
    <Section background="navy" className="pt-24 md:pt-32 pb-16 md:pb-24">
      <div className="text-center">
        <div className="grid md:grid-cols-2 gap-12 items-center">
          {/* Left Column - Text Content */}
          <div className="text-white text-left">
            {/* Headline */}
            <h1 className="font-montserrat text-4xl md:text-5xl lg:text-6xl font-bold mb-6 leading-tight">
              Simplify Your
              <br />
              Graffiti Removal Business
            </h1>

            {/* Subheadline */}
            <p className="font-inter text-lg md:text-xl mb-8 text-gray-300">
              From job logging to invoicing, FreshWall keeps your graffiti removal workflow clean, fast, and organized. Spend less time on admin and more time getting the job done.
            </p>

            {/* CTA Button */}
            <Button
              variant="primary"
              size="lg"
              colorScheme="dark"
              onClick={handleDemoClick}
            >
              Book a 15-Minute Demo
            </Button>
          </div>

          {/* Right Column - Phone Mockup */}
          <div className="flex justify-center md:justify-end">
            <div className="relative w-full max-w-md">
              <Image
                src="/phone-mockup.png"
                alt="FreshWall Mobile App"
                width={500}
                height={1000}
                className="w-full h-auto rounded-[2.5rem] shadow-2xl"
                priority
              />
            </div>
          </div>
        </div>
      </div>
    </Section>
  )
}

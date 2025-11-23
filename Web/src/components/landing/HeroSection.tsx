'use client'

import { Section } from '@/components/ui/Section'
import { Button } from '@/components/ui/Button'
import { Logo } from '@/components/ui/Logo'
import Image from 'next/image'

export const HeroSection = () => {
  return (
    <Section background="navy" className="py-16 md:py-24">
      <div className="text-center">
        {/* Logo - Icon and Text */}
        <div className="flex flex-col items-center mb-16">
          <Image
            src="/freshwall-icon.svg"
            alt="FreshWall Icon"
            width={80}
            height={88}
            className="mb-4"
            priority
          />
          <h2 className="font-montserrat text-5xl md:text-6xl font-bold text-white">
            Fresh Wall
          </h2>
        </div>

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
              onClick={() => {
                // TODO: Link to demo booking
                window.location.href = '/demo'
              }}
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

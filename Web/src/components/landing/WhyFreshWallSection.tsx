'use client'

import { Section } from '@/components/ui/Section'
import Image from 'next/image'

export const WhyFreshWallSection = () => {
  const benefits = [
    'Less paperwork.',
    'Faster payments.',
    'More time doing what you do best.',
  ]

  return (
    <Section background="gray" className="py-16 md:py-20">
      {/* Title - Above everything */}
      <h2 className="font-montserrat text-3xl md:text-4xl lg:text-5xl font-bold text-freshwall-orange mb-8 md:mb-12">
        Why FreshWall?
      </h2>

      <div className="grid md:grid-cols-2 gap-8 lg:gap-12 items-center">
        {/* Left Column - Phone Image */}
        <div className="flex justify-center md:justify-end">
          <div className="relative w-full max-w-lg">
            <Image
              src="/phone-mockup-dual.png"
              alt="FreshWall Mobile App"
              width={600}
              height={700}
              className="w-full h-auto"
            />
          </div>
        </div>

        {/* Right Column - Text Content */}
        <div>
          {/* Benefits List */}
          <div className="space-y-4 mb-8 max-w-md">
            {benefits.map((benefit, index) => (
              <div
                key={index}
                className="bg-white rounded-xl px-6 py-5"
                style={{
                  boxShadow: '-4px -5px 9px rgba(255, 255, 255, 1), 0px 4px 9px rgba(217, 217, 217, 1)'
                }}
              >
                <p className="font-montserrat text-xl md:text-2xl font-semibold text-copy-black">
                  {benefit}
                </p>
              </div>
            ))}
          </div>

          {/* Description */}
          <div className="space-y-4 text-copy-black max-w-md">
            <p className="font-inter text-lg">
              FreshWall takes hours of admin work off your plate every week.
            </p>
            <p className="font-inter text-lg">
              You&apos;ll see fewer missed jobs, smoother billing, and happier clients all while keeping your business running like a pro.
            </p>
          </div>
        </div>
      </div>
    </Section>
  )
}

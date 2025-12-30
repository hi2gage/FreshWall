'use client'

import { Section } from '@/components/ui/Section'
import { FeatureCard } from '@/components/ui/FeatureCard'
import Image from 'next/image'

export const FeaturesSection = () => {
  return (
    <Section background="gray" className="py-16 md:py-20">
      <div className="text-center mb-12">
        <h2 className="font-montserrat text-3xl md:text-4xl lg:text-5xl font-bold mb-4">
          <span className="text-freshwall-orange">FreshWall Keeps</span>
          <br />
          <span className="text-copy-black">Everything in One Place</span>
        </h2>
        <div className="font-montserrat text-lg md:text-xl text-copy-black max-w-3xl mx-auto space-y-1">
          <p>FreshWall is built specifically for graffiti removal professionals.</p>
          <p >It&apos;s not another generic job tracker.</p>
          <p>It&apos;s your entire business command center.</p>
        </div>
      </div>

      {/* Feature Cards */}
      <div className="grid md:grid-cols-3 gap-8 md:gap-12 mt-16">
        <FeatureCard
          icon={
            <Image
              src="/phone-icon.svg"
              alt="Capture On-Site"
              width={150}
              height={150}
              className="w-32 h-32 md:w-36 md:h-36"
            />
          }
          title="Capture On-Site"
          description="Crews capture photos and job details on-site right from the mobile app."
        />

        <FeatureCard
          icon={
            <Image
              src="/gear-icon.svg"
              alt="Track Automatically"
              width={150}
              height={150}
              className="w-32 h-32 md:w-36 md:h-36"
            />
          }
          title="Track Automatically"
          description="Automatically organize job data, timestamps, and materials so everything stays on track."
        />

        <FeatureCard
          icon={
            <Image
              src="/invoice-icon.svg"
              alt="Bill Faster"
              width={150}
              height={150}
              className="w-32 h-32 md:w-36 md:h-36"
            />
          }
          title="Bill Faster"
          description="Generate and send invoices with a click and track payments automatically."
        />
      </div>
    </Section>
  )
}

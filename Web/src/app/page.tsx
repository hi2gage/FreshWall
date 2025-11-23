'use client'

import {
  HeroSection,
  ProblemSection,
  FeaturesSection,
  WhyFreshWallSection,
  CTASection,
} from '@/components/landing'

export default function Home() {
  return (
    <main className="min-h-screen bg-white">
      <HeroSection />
      <ProblemSection />
      <FeaturesSection />
      <WhyFreshWallSection />
      <CTASection />
    </main>
  )
}
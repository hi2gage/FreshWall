'use client'

import { Header } from '@/components/ui'
import {
  HeroSection,
  ProblemSection,
  FeaturesSection,
  WhyFreshWallSection,
  CTASection,
} from '@/components/landing'

export default function Home() {
  return (
    <>
      <Header background="navy" />
      <main className="min-h-screen bg-white">
        <HeroSection />
        <ProblemSection />
        <FeaturesSection />
        <WhyFreshWallSection />
        <CTASection />
      </main>
    </>
  )
}
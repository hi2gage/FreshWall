'use client'

import { ViewportHeightFix } from '@/components/ViewportHeightFix'

// Mobile Components
import { HeroMobile } from '@/components/mobile/HeroMobile'
import { Step1Mobile } from '@/components/mobile/Step1Mobile'
import { Step2Mobile } from '@/components/mobile/Step2Mobile'
import { Step3Mobile } from '@/components/mobile/Step3Mobile'
import { AboutMobile } from '@/components/mobile/AboutMobile'
import { PricingMobile } from '@/components/mobile/PricingMobile'
import { ContactMobile } from '@/components/mobile/ContactMobile'

// Desktop Components
import { HeroDesktop } from '@/components/desktop/HeroDesktop'
import { ServicesDesktop } from '@/components/desktop/ServicesDesktop'
import { AboutDesktop } from '@/components/desktop/AboutDesktop'
import { PricingDesktop } from '@/components/desktop/PricingDesktop'
import { ContactDesktop } from '@/components/desktop/ContactDesktop'

export default function Home() {
  return (
    <>
      {/* <ViewportHeightFix /> */}

      {/* Mobile Layout */}
      <main className="block lg:hidden h-screen-safe overflow-y-auto snap-y snap-mandatory">
        <section className="h-screen-safe snap-start flex items-center" style={{scrollSnapStop: 'always'}}>
          <HeroMobile />
        </section>
        <section className="h-screen-safe snap-start flex items-center" style={{scrollSnapStop: 'always'}}>
          <Step1Mobile />
        </section>
        <section className="h-screen-safe snap-start flex items-center" style={{scrollSnapStop: 'always'}}>
          <Step2Mobile />
        </section>
        <section className="h-screen-safe snap-start flex items-center" style={{scrollSnapStop: 'always'}}>
          <Step3Mobile />
        </section>
        <section className="min-h-screen-safe snap-start">
          <AboutMobile />
        </section>
        <section className="min-h-screen-safe snap-start flex items-center">
          <PricingMobile />
        </section>
        <section className="min-h-screen-safe snap-start">
          <ContactMobile />
        </section>
      </main>

      {/* Desktop Layout */}
      <main className="hidden lg:block h-screen-safe overflow-y-auto snap-y snap-mandatory">
        <section className="min-h-screen-safe snap-start flex items-center">
          <HeroDesktop />
        </section>
        <section className="min-h-screen-safe snap-start flex items-center">
          <ServicesDesktop />
        </section>
        <section className="min-h-screen-safe snap-start">
          <AboutDesktop />
        </section>
        <section className="min-h-screen-safe snap-start flex items-center">
          <PricingDesktop />
        </section>
        <section className="min-h-screen-safe snap-start">
          <ContactDesktop />
        </section>
      </main>
    </>
  )
}
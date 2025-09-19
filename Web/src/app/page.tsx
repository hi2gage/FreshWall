'use client'

import { ViewportHeightFix } from '@/components/ViewportHeightFix'
import { useIsMobile } from '@/hooks/useIsMobile'

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
  const isMobile = useIsMobile()


  if (isMobile) {
    return (
      <>
        <ViewportHeightFix />
        <main className="h-screen-safe overflow-y-auto snap-y snap-mandatory">
          <section className="min-h-screen-safe snap-start flex items-center">
            <HeroMobile />
          </section>
          <section className="min-h-screen-safe snap-start flex items-center">
            <Step1Mobile />
          </section>
          <section className="min-h-screen-safe snap-start flex items-center">
            <Step2Mobile />
          </section>
          <section className="min-h-screen-safe snap-start flex items-center">
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
      </>
    )
  }

  return (
    <>
      <ViewportHeightFix />
      <main className="h-screen-safe overflow-y-auto snap-y snap-mandatory">
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
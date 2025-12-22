'use client'

import { Button, Section, FeatureCard, Logo } from '@/components/ui'
import Image from 'next/image'

export default function ComponentsPage() {
  return (
    <div className="min-h-screen bg-white py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <Logo height={60} variant="dark" priority />
        </div>
        <h1 className="font-montserrat text-h1 text-copy-black mb-2">
          FreshWall Design System
        </h1>
        <p className="font-inter text-body-lg text-gray-600 mb-12">
          Component showcase for the FreshWall brand
        </p>

        {/* Logo Showcase */}
        <section className="mb-16">
          <h2 className="font-montserrat text-h2 text-copy-black mb-6">
            Logo
          </h2>
          <div className="grid md:grid-cols-2 gap-8">
            <div className="bg-charcoal-navy p-8 rounded-lg">
              <p className="font-inter text-body-sm text-white mb-4">Light Logo (for dark backgrounds)</p>
              <Logo height={60} variant="light" />
            </div>
            <div className="bg-white border border-gray-300 p-8 rounded-lg">
              <p className="font-inter text-body-sm text-copy-black mb-4">Dark Logo (for light backgrounds)</p>
              <Logo height={60} variant="dark" />
            </div>
          </div>
        </section>

        {/* Color Palette */}
        <section className="mb-16">
          <h2 className="font-montserrat text-h2 text-copy-black mb-6">
            Color Palette
          </h2>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
            <div>
              <div className="w-full h-24 bg-charcoal-navy rounded-lg mb-2"></div>
              <p className="font-inter text-body-sm font-semibold">Charcoal Navy</p>
              <p className="font-inter text-body-sm text-gray-600">#334155</p>
            </div>
            <div>
              <div className="w-full h-24 bg-freshwall-orange rounded-lg mb-2"></div>
              <p className="font-inter text-body-sm font-semibold">FreshWall Orange</p>
              <p className="font-inter text-body-sm text-gray-600">#F37335</p>
            </div>
            <div>
              <div className="w-full h-24 bg-seafoam-teal rounded-lg mb-2"></div>
              <p className="font-inter text-body-sm font-semibold">Seafoam Teal</p>
              <p className="font-inter text-body-sm text-gray-600">#73C5B6</p>
            </div>
            <div>
              <div className="w-full h-24 bg-bright-highlight rounded-lg mb-2 border border-gray-300"></div>
              <p className="font-inter text-body-sm font-semibold">Bright Highlight</p>
              <p className="font-inter text-body-sm text-gray-600">#D1D5DB</p>
            </div>
            <div>
              <div className="w-full h-24 bg-neutral-tone rounded-lg mb-2 border border-gray-300"></div>
              <p className="font-inter text-body-sm font-semibold">Neutral Tone</p>
              <p className="font-inter text-body-sm text-gray-600">#E5E7EB</p>
            </div>
            <div>
              <div className="w-full h-24 bg-copy-black rounded-lg mb-2"></div>
              <p className="font-inter text-body-sm font-semibold">Copy Black</p>
              <p className="font-inter text-body-sm text-gray-600">#1F2937</p>
            </div>
          </div>
        </section>

        {/* Typography */}
        <section className="mb-16">
          <h2 className="font-montserrat text-h2 text-copy-black mb-6">
            Typography
          </h2>
          <div className="space-y-6 bg-neutral-tone p-8 rounded-lg">
            <div>
              <p className="font-inter text-body-sm text-gray-600 mb-2">Display (Montserrat Bold)</p>
              <p className="font-montserrat text-display text-copy-black">
                Simplify Your Graffiti Removal Business
              </p>
            </div>
            <div>
              <p className="font-inter text-body-sm text-gray-600 mb-2">Heading 1 (Montserrat Bold)</p>
              <h1 className="font-montserrat text-h1 text-copy-black">
                Fresh Wall
              </h1>
            </div>
            <div>
              <p className="font-inter text-body-sm text-gray-600 mb-2">Heading 2 (Montserrat SemiBold)</p>
              <h2 className="font-montserrat text-h2 text-copy-black">
                Why FreshWall?
              </h2>
            </div>
            <div>
              <p className="font-inter text-body-sm text-gray-600 mb-2">Heading 3 (Montserrat SemiBold)</p>
              <h3 className="font-montserrat text-h3 text-copy-black">
                Capture On-Site
              </h3>
            </div>
            <div>
              <p className="font-inter text-body-sm text-gray-600 mb-2">Body Large (Inter)</p>
              <p className="font-inter text-body-lg text-copy-black">
                From job logging to invoicing, FreshWall keeps your graffiti removal workflow clean, fast, and organized.
              </p>
            </div>
            <div>
              <p className="font-inter text-body-sm text-gray-600 mb-2">Body (Inter)</p>
              <p className="font-inter text-body text-copy-black">
                Crews capture photos and job details on-site right from the mobile app.
              </p>
            </div>
            <div>
              <p className="font-inter text-body-sm text-gray-600 mb-2">Body Small (Inter)</p>
              <p className="font-inter text-body-sm text-copy-black">
                No commitment required.
              </p>
            </div>
          </div>
        </section>

        {/* Buttons */}
        <section className="mb-16">
          <h2 className="font-montserrat text-h2 text-copy-black mb-6">
            Buttons
          </h2>

          <div className="grid md:grid-cols-2 gap-8">
          {/* Light Background */}
          <div className="bg-white border border-gray-200 rounded-lg p-8">
            <h3 className="font-montserrat text-h3 text-copy-black mb-6">Light Background</h3>
            <div className="space-y-8">
              {/* Primary Buttons */}
              <div>
                <p className="font-inter text-body-sm text-gray-500 mb-2">Primary - Current (Orange → Darker Orange)</p>
                <div className="flex flex-wrap gap-4 mb-4">
                  <Button variant="primary" size="md">Book a 15-Minute Demo</Button>
                </div>

                <p className="font-inter text-body-sm text-gray-500 mb-2">Primary - Option A (Orange → Teal)</p>
                <div className="flex flex-wrap gap-4 mb-4">
                  <Button variant="primary" size="md" className="hover:bg-seafoam-teal">Book a 15-Minute Demo</Button>
                </div>

                <p className="font-inter text-body-sm text-gray-500 mb-2">Primary - Option B (Orange → Navy)</p>
                <div className="flex flex-wrap gap-4">
                  <Button variant="primary" size="md" className="hover:bg-charcoal-navy">Book a 15-Minute Demo</Button>
                </div>
              </div>

              {/* Secondary Buttons */}
              <div>
                <p className="font-inter text-body-sm text-gray-500 mb-2">Secondary - Current (Navy border → Navy fill)</p>
                <div className="flex flex-wrap gap-4 mb-4">
                  <Button variant="secondary" size="md">Existing Customers</Button>
                </div>

                <p className="font-inter text-body-sm text-gray-500 mb-2">Secondary - Option A (Navy border → Teal fill)</p>
                <div className="flex flex-wrap gap-4 mb-4">
                  <Button variant="secondary" size="md" className="hover:bg-seafoam-teal hover:border-seafoam-teal hover:text-charcoal-navy">Existing Customers</Button>
                </div>

                <p className="font-inter text-body-sm text-gray-500 mb-2">Secondary - Option B (Navy border → Orange fill)</p>
                <div className="flex flex-wrap gap-4">
                  <Button variant="secondary" size="md" className="hover:bg-freshwall-orange hover:border-freshwall-orange hover:text-white">Existing Customers</Button>
                </div>
              </div>
            </div>
          </div>

          {/* Dark Background */}
          <div className="bg-charcoal-navy rounded-lg p-8 h-fit">
            <h3 className="font-montserrat text-h3 text-white mb-6">Dark Background</h3>
            <div className="space-y-8">
              {/* Primary Buttons on Dark */}
              <div>
                <p className="font-inter text-body-sm text-gray-400 mb-2">Primary - Current (Orange → Darker Orange)</p>
                <div className="flex flex-wrap gap-4 mb-4">
                  <Button variant="primary" size="md">Book a 15-Minute Demo</Button>
                </div>

                <p className="font-inter text-body-sm text-gray-400 mb-2">Primary - Option A (Orange → Teal)</p>
                <div className="flex flex-wrap gap-4 mb-4">
                  <Button variant="primary" size="md" className="hover:bg-seafoam-teal hover:text-charcoal-navy">Book a 15-Minute Demo</Button>
                </div>

                <p className="font-inter text-body-sm text-gray-400 mb-2">Primary - Option B (Orange → White)</p>
                <div className="flex flex-wrap gap-4">
                  <Button variant="primary" size="md" className="hover:bg-white hover:text-charcoal-navy">Book a 15-Minute Demo</Button>
                </div>
              </div>

              {/* Secondary Buttons on Dark */}
              <div>
                <p className="font-inter text-body-sm text-gray-400 mb-2">Secondary - Option A (White border → White fill, dark text)</p>
                <div className="flex flex-wrap gap-4 mb-4">
                  <Button variant="secondary" size="md" className="border-white text-white hover:bg-white hover:!text-charcoal-navy">Existing Customers</Button>
                </div>

                <p className="font-inter text-body-sm text-gray-400 mb-2">Secondary - Option B (White border → Teal fill) ✓ Current Header</p>
                <div className="flex flex-wrap gap-4 mb-4">
                  <Button variant="secondary" size="md" className="border-white text-white hover:bg-seafoam-teal hover:border-seafoam-teal hover:text-charcoal-navy">Existing Customers</Button>
                </div>

                <p className="font-inter text-body-sm text-gray-400 mb-2">Secondary - Option C (White border → Orange fill)</p>
                <div className="flex flex-wrap gap-4 mb-4">
                  <Button variant="secondary" size="md" className="border-white text-white hover:bg-freshwall-orange hover:border-freshwall-orange">Existing Customers</Button>
                </div>

                <p className="font-inter text-body-sm text-gray-400 mb-2">Secondary - Option D (Teal border → Teal fill)</p>
                <div className="flex flex-wrap gap-4">
                  <Button variant="secondary" size="md" className="border-seafoam-teal text-seafoam-teal hover:bg-seafoam-teal hover:text-charcoal-navy">Existing Customers</Button>
                </div>
              </div>
            </div>
          </div>
          </div>
        </section>

        {/* Feature Cards */}
        <section className="mb-16">
          <h2 className="font-montserrat text-h2 text-copy-black mb-6">
            Feature Cards
          </h2>
          <div className="grid md:grid-cols-3 gap-8">
            <FeatureCard
              icon={
                <Image
                  src="/phone-icon.svg"
                  alt="Capture On-Site"
                  width={100}
                  height={100}
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
                  width={100}
                  height={100}
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
                  width={100}
                  height={100}
                  className="w-32 h-32 md:w-36 md:h-36"
                />
              }
              title="Bill Faster"
              description="Generate and send invoices with a click and track payments automatically."
            />
          </div>
        </section>

        {/* Section Backgrounds */}
        <section className="mb-16">
          <h2 className="font-montserrat text-h2 text-copy-black mb-6">
            Section Backgrounds
          </h2>
          <div className="space-y-4">
            <Section background="white" className="py-8">
              <p className="font-inter text-body text-copy-black">White Background Section</p>
            </Section>
            <Section background="gray" className="py-8">
              <p className="font-inter text-body text-copy-black">Gray Background Section</p>
            </Section>
            <Section background="navy" className="py-8">
              <p className="font-inter text-body text-white">Navy Background Section</p>
            </Section>
          </div>
        </section>
      </div>
    </div>
  )
}

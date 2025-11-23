'use client'

import { Button, Section, FeatureCard, Logo } from '@/components/ui'

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
          <div className="space-y-8">
            <div>
              <p className="font-inter text-body text-gray-600 mb-4">Primary Button</p>
              <div className="flex flex-wrap gap-4">
                <Button variant="primary" size="sm">Book a Demo</Button>
                <Button variant="primary" size="md">Book a 15-Minute Demo</Button>
                <Button variant="primary" size="lg">Get Started</Button>
              </div>
            </div>
            <div>
              <p className="font-inter text-body text-gray-600 mb-4">Secondary Button</p>
              <div className="flex flex-wrap gap-4">
                <Button variant="secondary" size="sm">Learn More</Button>
                <Button variant="secondary" size="md">Contact Us</Button>
                <Button variant="secondary" size="lg">View Pricing</Button>
              </div>
            </div>
            <div>
              <p className="font-inter text-body text-gray-600 mb-4">Text Button</p>
              <div className="flex flex-wrap gap-4">
                <Button variant="text" size="sm">Read more</Button>
                <Button variant="text" size="md">Learn about features</Button>
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
                <svg className="w-16 h-16 text-charcoal-navy" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
                </svg>
              }
              title="Capture On-Site"
              description="Crews capture photos and job details on-site right from the mobile app."
            />
            <FeatureCard
              icon={
                <svg className="w-16 h-16 text-charcoal-navy" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              }
              title="Track Automatically"
              description="Automatically organize job data, timestamps, and materials so everything stays on track."
            />
            <FeatureCard
              icon={
                <svg className="w-16 h-16 text-charcoal-navy" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
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

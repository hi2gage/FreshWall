'use client'

import { Section } from '@/components/ui/Section'

export const ProblemSection = () => {
  const problems = [
    'Lost job notes',
    'Missed invoices',
    'Slow processing time',
  ]

  return (
    <Section background="gray" className="py-16 md:py-20">
      <div className="max-w-6xl mx-auto">
        <div className="grid md:grid-cols-2 gap-12 items-center">
          {/* Left Column - Text Content */}
          <div>
            {/* Heading */}
            <h2 className="font-montserrat text-3xl md:text-4xl lg:text-5xl font-bold text-copy-black mb-6">
              Graffiti removal
              <br />
              shouldn&apos;t feel messy
            </h2>

            {/* Subheading */}
            <div className="font-inter text-lg md:text-xl text-copy-black space-y-1">
              <p className="text-freshwall-orange font-semibold">Every day you&apos;re managing a dozen moving parts</p>
              <p>and it&apos;s too easy for things to slip through the cracks.</p>
            </div>
          </div>

          {/* Right Column - Problem List */}
          <div
            className="bg-white rounded-xl px-8 py-6 space-y-5 w-fit md:ml-auto"
            style={{
              boxShadow: '-4px -5px 9px rgba(255, 255, 255, 1), 0px 4px 9px rgba(217, 217, 217, 1)'
            }}
          >
            {problems.map((problem, index) => (
              <div key={index} className="flex items-center gap-4">
                {/* X Icon */}
                <svg
                  className="w-6 h-6 text-freshwall-orange flex-shrink-0"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2.5}
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
                {/* Problem Text */}
                <p className="font-inter text-lg md:text-xl text-copy-black">
                  {problem}
                </p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </Section>
  )
}

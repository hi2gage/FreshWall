import React from 'react'

export interface SectionProps {
  children: React.ReactNode
  className?: string
  containerClassName?: string
  background?: 'white' | 'gray' | 'navy'
  id?: string
}

export const Section: React.FC<SectionProps> = ({
  children,
  className = '',
  containerClassName = '',
  background = 'white',
  id,
}) => {
  const backgroundStyles = {
    white: 'bg-white',
    gray: 'bg-neutral-tone',
    navy: 'bg-charcoal-navy',
  }

  return (
    <section id={id} className={`${backgroundStyles[background]} ${className}`}>
      <div className={`max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 ${containerClassName}`}>
        {children}
      </div>
    </section>
  )
}

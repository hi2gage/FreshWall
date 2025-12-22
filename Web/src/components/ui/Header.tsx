'use client'

import { useState, useEffect } from 'react'
import { Logo } from './Logo'
import { Button } from './Button'

export interface HeaderProps {
  background?: 'transparent' | 'white' | 'navy'
}

export const Header: React.FC<HeaderProps> = ({ background = 'navy' }) => {
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const handleScroll = () => {
      // Show logo after scrolling past hero section (approximately 500px)
      setScrolled(window.scrollY > 400)
    }

    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  const bgStyles = {
    transparent: 'bg-charcoal-navy/95 backdrop-blur-sm',
    white: 'bg-white shadow-sm',
    navy: 'bg-charcoal-navy',
  }

  const logoVariant = background === 'white' ? 'dark' : 'light'

  return (
    <header className={`${bgStyles[background]} fixed top-0 left-0 right-0 z-50 transition-all`}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16 md:h-20">
          {/* Logo */}
          <div className="flex-shrink-0">
            <a href="/">
              <Logo height={52} variant={logoVariant} priority />
            </a>
          </div>

          {/* Navigation */}
          <nav className="flex items-center gap-4">
            <div className={`transition-opacity duration-300 ${scrolled ? 'opacity-100' : 'opacity-0'}`}>
              <Button
                variant="primary"
                size="md"
                colorScheme="dark"
                onClick={() => {
                  window.location.href = '/demo'
                }}
              >
                Book a Demo
              </Button>
            </div>
            <Button
              variant="secondary"
              size="md"
              colorScheme="dark"
              onClick={() => {
                window.location.href = '/login'
              }}
            >
              Existing Customers
            </Button>
          </nav>
        </div>
      </div>
    </header>
  )
}

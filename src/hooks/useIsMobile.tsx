'use client'

import { useState, useEffect } from 'react'

export function useIsMobile() {
  const [isMobile, setIsMobile] = useState(true)

  useEffect(() => {
    const checkIsMobile = () => {
      const mobile = window.innerWidth < 768
      console.log('🔍 Mobile detection:', {
        windowWidth: window.innerWidth,
        isMobile: mobile,
        userAgent: navigator.userAgent
      })
      setIsMobile(mobile)
    }

    // Check on mount
    checkIsMobile()

    // Listen for resize events
    window.addEventListener('resize', checkIsMobile)

    return () => window.removeEventListener('resize', checkIsMobile)
  }, [])

  return isMobile
}
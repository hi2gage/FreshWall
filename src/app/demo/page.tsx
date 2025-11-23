'use client'

import { useEffect } from 'react'

export default function DemoPage() {
  useEffect(() => {
    // Load Tally embed script
    const script = document.createElement('script')
    script.src = 'https://tally.so/widgets/embed.js'
    script.async = true
    document.head.appendChild(script)

    return () => {
      // Cleanup
      const existingScript = document.querySelector('script[src="https://tally.so/widgets/embed.js"]')
      if (existingScript) {
        document.head.removeChild(existingScript)
      }
    }
  }, [])

  return (
    <div className="h-screen overflow-hidden">
      <iframe
        data-tally-src="https://tally.so/r/n98ZrQ?transparentBackground=1"
        width="100%"
        height="100%"
        frameBorder="0"
        marginHeight={0}
        marginWidth={0}
        title="Demo Request"
        className="absolute top-0 right-0 bottom-0 left-0 border-0"
      />
    </div>
  )
}
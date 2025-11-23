import type { Metadata } from 'next'
import { Inter, Montserrat } from 'next/font/google'
import './globals.css'
import { ThemeProvider } from '@/contexts/ThemeContext'
import StagingBanner from '@/components/StagingBanner'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
})

const montserrat = Montserrat({
  subsets: ['latin'],
  variable: '--font-montserrat',
  display: 'swap',
})

export const metadata: Metadata = {
  title: 'FreshWall',
  description: 'Professional graffiti removal services',
  viewport: 'viewport-fit=cover, width=device-width, initial-scale=1.0',
  icons: {
    icon: [
      { url: '/favicon.svg', type: 'image/svg+xml' },
    ],
    shortcut: '/favicon.svg',
    apple: '/favicon.svg',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={`${inter.variable} ${montserrat.variable} font-sans`}>
        {/* <StagingBanner /> */}
        <ThemeProvider>
          {children}
        </ThemeProvider>
        <script async src="https://tally.so/widgets/embed.js"></script>
      </body>
    </html>
  )
}
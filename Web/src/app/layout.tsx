import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { ThemeProvider } from '@/contexts/ThemeContext'
import StagingBanner from '@/components/StagingBanner'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'FreshWall',
  description: 'Professional graffiti removal services',
  viewport: 'viewport-fit=cover, width=device-width, initial-scale=1.0',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <StagingBanner />
        <ThemeProvider>
          {children}
        </ThemeProvider>
        <script async src="https://tally.so/widgets/embed.js"></script>
      </body>
    </html>
  )
}
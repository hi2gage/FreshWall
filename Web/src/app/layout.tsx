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

const siteUrl = 'https://www.freshwall.app'
const siteName = 'FreshWall'
const siteDescription = 'Simplify your graffiti removal business. From job logging to invoicing, FreshWall keeps your graffiti removal workflow clean, fast, and organized.'

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: {
    default: 'FreshWall - Graffiti Removal Business Software',
    template: '%s | FreshWall',
  },
  description: siteDescription,
  keywords: [
    'graffiti removal',
    'graffiti removal software',
    'graffiti management',
    'property maintenance',
    'incident tracking',
    'graffiti abatement',
    'vandalism removal',
    'business software',
    'field service management',
    'work order management',
  ],
  authors: [{ name: 'FreshWall' }],
  creator: 'FreshWall',
  publisher: 'FreshWall',
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  icons: {
    icon: [
      { url: '/favicon.svg', type: 'image/svg+xml' },
    ],
    shortcut: '/favicon.svg',
    apple: '/favicon.svg',
  },
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: siteUrl,
    siteName: siteName,
    title: 'FreshWall - Graffiti Removal Business Software',
    description: siteDescription,
    images: [
      {
        url: '/dashboard-screenshot.png',
        width: 1200,
        height: 630,
        alt: 'FreshWall Dashboard - Graffiti Removal Management',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'FreshWall - Graffiti Removal Business Software',
    description: siteDescription,
    images: ['/dashboard-screenshot.png'],
  },
  alternates: {
    canonical: siteUrl,
  },
  category: 'Business Software',
}

export const viewport = {
  viewportFit: 'cover',
  width: 'device-width',
  initialScale: 1.0,
}

const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'SoftwareApplication',
  name: 'FreshWall',
  applicationCategory: 'BusinessApplication',
  operatingSystem: 'iOS, Web',
  description: siteDescription,
  url: siteUrl,
  offers: {
    '@type': 'Offer',
    price: '0',
    priceCurrency: 'USD',
    description: 'Free to start',
  },
  publisher: {
    '@type': 'Organization',
    name: 'FreshWall',
    url: siteUrl,
    logo: {
      '@type': 'ImageObject',
      url: `${siteUrl}/logo/primary-horizontal-logo-dark.svg`,
    },
  },
  aggregateRating: {
    '@type': 'AggregateRating',
    ratingValue: '5',
    ratingCount: '1',
    bestRating: '5',
    worstRating: '1',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
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
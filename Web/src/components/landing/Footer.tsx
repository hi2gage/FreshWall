'use client'

import Image from 'next/image'

export const Footer = () => {
  return (
    <footer className="bg-charcoal-navy py-12">
      <div className="container mx-auto px-4 flex flex-col items-center">
        <Image
          src="/logo/primary-horizontal-logo-whiteout.svg"
          alt="FreshWall"
          width={200}
          height={50}
          className="h-10 w-auto mb-4"
        />
        <p className="text-gray-400 text-sm">
          © 2025 FreshWall
        </p>
      </div>
    </footer>
  )
}

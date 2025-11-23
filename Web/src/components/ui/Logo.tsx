import Image from 'next/image'

export interface LogoProps {
  className?: string
  height?: number
  priority?: boolean
  variant?: 'light' | 'dark' // light for dark backgrounds, dark for light backgrounds
}

export const Logo: React.FC<LogoProps> = ({
  className = '',
  height = 48,
  priority = false,
  variant = 'light',
}) => {
  // Logo aspect ratio is approximately 272:123 (2.21:1)
  const width = Math.round(height * 2.21)

  const logoSrc = variant === 'light'
    ? '/freshwall-logo-light.svg'  // White text, for dark backgrounds
    : '/freshwall-logo-dark.svg'   // Dark text, for light backgrounds

  return (
    <Image
      src={logoSrc}
      alt="FreshWall"
      width={width}
      height={height}
      className={className}
      priority={priority}
    />
  )
}

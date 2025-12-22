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
  // Logo aspect ratio is 364:84 (4.33:1)
  const width = Math.round(height * 4.33)

  const logoSrc = variant === 'light'
    ? '/logo/primary-horizontal-logo-dark.svg'   // For dark backgrounds
    : '/logo/primary-horizontal-logo-light.svg'  // For light backgrounds

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

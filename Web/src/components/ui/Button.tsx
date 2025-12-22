import React from 'react'

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'text'
  size?: 'sm' | 'md' | 'lg'
  colorScheme?: 'light' | 'dark'
  children: React.ReactNode
}

export const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  colorScheme = 'light',
  className = '',
  children,
  ...props
}) => {
  const baseStyles = 'font-inter font-semibold rounded-lg transition-all duration-200 inline-flex items-center justify-center'

  const sizeStyles = {
    sm: 'px-4 py-2 text-sm',
    md: 'px-6 py-3 text-base',
    lg: 'px-8 py-4 text-lg',
  }

  // Light background: for use on white/light backgrounds
  // Dark background: for use on navy/dark backgrounds
  const variantStyles = {
    primary: {
      light: 'bg-freshwall-orange text-white hover:bg-charcoal-navy active:bg-opacity-80',
      dark: 'bg-freshwall-orange text-white hover:bg-white hover:text-charcoal-navy active:bg-opacity-80',
    },
    secondary: {
      light: 'border-2 border-charcoal-navy text-charcoal-navy hover:bg-charcoal-navy hover:text-white',
      dark: 'border-2 border-white text-white hover:bg-white hover:text-charcoal-navy',
    },
    text: {
      light: 'text-charcoal-navy hover:text-freshwall-orange underline',
      dark: 'text-white hover:text-freshwall-orange underline',
    },
  }

  return (
    <button
      className={`${baseStyles} ${variantStyles[variant][colorScheme]} ${sizeStyles[size]} ${className}`}
      {...props}
    >
      {children}
    </button>
  )
}

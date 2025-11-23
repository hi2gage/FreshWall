import React from 'react'

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'text'
  size?: 'sm' | 'md' | 'lg'
  children: React.ReactNode
}

export const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  className = '',
  children,
  ...props
}) => {
  const baseStyles = 'font-inter font-semibold rounded-lg transition-all duration-200 inline-flex items-center justify-center'

  const variantStyles = {
    primary: 'bg-freshwall-orange text-white hover:bg-opacity-90 active:bg-opacity-80',
    secondary: 'border-2 border-charcoal-navy text-charcoal-navy hover:bg-charcoal-navy hover:text-white',
    text: 'text-charcoal-navy hover:text-freshwall-orange underline',
  }

  const sizeStyles = {
    sm: 'px-4 py-2 text-sm',
    md: 'px-6 py-3 text-base',
    lg: 'px-8 py-4 text-lg',
  }

  return (
    <button
      className={`${baseStyles} ${variantStyles[variant]} ${sizeStyles[size]} ${className}`}
      {...props}
    >
      {children}
    </button>
  )
}

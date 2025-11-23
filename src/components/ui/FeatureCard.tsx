import React from 'react'

export interface FeatureCardProps {
  icon: React.ReactNode
  title: string
  description: string
  className?: string
}

export const FeatureCard: React.FC<FeatureCardProps> = ({
  icon,
  title,
  description,
  className = '',
}) => {
  return (
    <div className={`text-center ${className}`}>
      <div className="flex justify-center mb-6">
        {icon}
      </div>
      <h3 className="font-montserrat text-h3 text-freshwall-orange mb-4">
        {title}
      </h3>
      <p className="font-inter text-body text-copy-black">
        {description}
      </p>
    </div>
  )
}

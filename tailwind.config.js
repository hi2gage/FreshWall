/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        background: 'var(--background)',
        foreground: 'var(--foreground)',
        // FreshWall Brand Colors from Design System
        'charcoal-navy': '#334155',
        'freshwall-orange': '#F37335',
        'seafoam-teal': '#73C5B6',
        'bright-highlight': '#D1D5DB',
        'neutral-tone': '#F6F7F8',
        'copy-black': '#1F2937',
        // Override default gray with neutral colors (removes blue tint)
        gray: {
          50: '#fafafa',
          100: '#f5f5f5',
          200: '#e5e5e5',
          300: '#d4d4d4',
          400: '#a3a3a3',
          500: '#737373',
          600: '#525252',
          700: '#404040',
          800: '#262626',
          900: '#171717',
          950: '#0a0a0a',
        },
      },
      fontFamily: {
        'montserrat': ['var(--font-montserrat)', 'sans-serif'],
        'inter': ['var(--font-inter)', 'sans-serif'],
        'sans': ['var(--font-inter)', 'sans-serif'], // Default sans-serif to Inter
      },
      fontSize: {
        // Typography scale from design system
        'display': ['3.5rem', { lineHeight: '1.2', fontWeight: '700' }], // 56px
        'h1': ['3rem', { lineHeight: '1.2', fontWeight: '700' }], // 48px
        'h2': ['2.25rem', { lineHeight: '1.3', fontWeight: '600' }], // 36px
        'h3': ['1.5rem', { lineHeight: '1.4', fontWeight: '600' }], // 24px
        'body-lg': ['1.125rem', { lineHeight: '1.6', fontWeight: '400' }], // 18px
        'body': ['1rem', { lineHeight: '1.6', fontWeight: '400' }], // 16px
        'body-sm': ['0.875rem', { lineHeight: '1.5', fontWeight: '400' }], // 14px
      },
    },
  },
  plugins: [],
}
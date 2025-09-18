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
        // Brand colors - green theme for FreshWall
        brand: {
          50: '#f0fdf4',   // very light green
          100: '#dcfce7',  // light green
          200: '#bbf7d0',  // lighter green
          300: '#86efac',  // light green
          400: '#4ade80',  // medium light green
          500: '#22c55e',  // primary green
          600: '#16a34a',  // primary dark green
          700: '#15803d',  // dark green
          800: '#166534',  // darker green
          900: '#14532d',  // very dark green
        },
      },
    },
  },
  plugins: [],
}
# FreshWall Website

A modern, single-page website for FreshWall graffiti removal services built with Next.js, TypeScript, and Tailwind CSS.

## Getting Started

1. Install dependencies:
```bash
npm install
```

2. Run the development server:
```bash
npm run dev
```

3. Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Features

- 🎨 Modern, responsive design with Tailwind CSS
- ⚡ Built with Next.js 14 and TypeScript
- 🚀 Optimized for Vercel deployment
- 📱 Mobile-first responsive design
- 🎯 Single-page application with smooth scrolling sections

## Sections

- **Hero**: Eye-catching landing section with call-to-action
- **Services**: Overview of graffiti removal services
- **About**: Company information and statistics
- **Contact**: Contact information and quote request

## Deployment

### Vercel (Recommended)

1. Push your code to a Git repository
2. Import your project to Vercel
3. Deploy with zero configuration

### Manual Deployment

```bash
npm run build
npm start
```

## Project Structure

```
Web/
├── src/
│   ├── app/
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   └── page.tsx
│   └── components/
│       ├── Hero.tsx
│       ├── Services.tsx
│       ├── About.tsx
│       └── Contact.tsx
├── public/
├── package.json
├── next.config.js
├── tailwind.config.js
└── vercel.json
```

## Customization

- Update company information in the component files
- Modify colors and styling in `tailwind.config.js`
- Add your own images to the `public/` directory
- Update contact information in `Contact.tsx`

## Technologies

- [Next.js](https://nextjs.org/) - React framework
- [TypeScript](https://www.typescriptlang.org/) - Type safety
- [Tailwind CSS](https://tailwindcss.com/) - Styling
- [Vercel](https://vercel.com/) - Deployment platform
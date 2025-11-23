import { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Thank You - FreshWall',
  description: 'Thank you for requesting a demo of FreshWall. We\'ll be in touch soon!',
}

export default function ThankYouPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 flex items-center justify-center">
      <div className="container mx-auto px-6 text-center">
        <div className="max-w-2xl mx-auto">
          <div className="text-6xl mb-8">🎉</div>
          <h1 className="text-5xl font-bold text-gray-900 mb-6">
            Thank You!
          </h1>
          <p className="text-xl text-gray-700 mb-8">
            Thanks for requesting a demo of FreshWall. We've received your information and will be in touch within 24 hours to schedule your personalized demo.
          </p>
          <div className="space-y-4">
            <p className="text-lg text-gray-600">
              In the meantime, feel free to reach out directly at:
            </p>
            <a 
              href="mailto:info@freshwall.app" 
              className="text-green-600 hover:text-green-700 font-semibold text-lg"
            >
              info@freshwall.app
            </a>
          </div>
          <div className="mt-12">
            <a 
              href="/" 
              className="bg-green-700 hover:bg-green-800 text-white font-bold py-3 px-8 rounded-lg text-lg transition-colors inline-block"
            >
              Back to Home
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}
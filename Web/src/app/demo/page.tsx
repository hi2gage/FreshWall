'use client'

export default function DemoPage() {
  return (
    <div className="h-screen bg-gradient-to-br from-gray-50 to-gray-100 overflow-hidden">
      <div className="h-full max-w-2xl mx-auto p-4 md:p-6 pt-8 md:pt-12 flex flex-col">
        <div className="text-center mb-6 flex-shrink-0">
          <h1 className="text-3xl md:text-4xl font-bold text-gray-900 mb-3">Request a Demo</h1>
          <p className="text-lg md:text-xl text-gray-600 max-w-md mx-auto">
            Fill out the form below and we'll get back to you within 24 hours.
          </p>
        </div>

        <div className="bg-white rounded-xl shadow-xl border border-gray-200 overflow-hidden flex-1 min-h-0">
          <iframe
            src="https://tally.so/r/n98ZrQ?hideTitle=1&transparentBackground=1"
            width="100%"
            height="100%"
            style={{ border: 0 }}
            title="FreshWall Demo Request"
            className="rounded-lg"
          />
        </div>
      </div>
    </div>
  )
}
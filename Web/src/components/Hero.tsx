export function Hero() {
  return (
    <section className="bg-gradient-to-br from-gray-50 to-gray-100 min-h-screen flex items-center justify-center">
      <div className="container mx-auto px-6 text-center">
        <h1 className="text-5xl md:text-7xl font-bold text-gray-900 mb-6">
          Take the Graffiti Out of Your Paperwork
        </h1>
        <p className="text-xl md:text-2xl text-gray-700 mb-8 max-w-4xl mx-auto">
          FreshWall helps graffiti removal companies log jobs, capture photos, and generate invoices in minutes so your crew spends more time in the field, not buried in admin.
        </p>
        <div className="space-x-4">
          <a
            href="/demo"
            className="bg-green-700 hover:bg-green-800 text-white font-bold py-3 px-8 rounded-lg text-lg transition-colors inline-block"
          >
            Request a Demo
          </a>
        </div>
        <div className="mt-8 text-gray-600">
          <p>info@freshwall.app</p>
        </div>
      </div>
    </section>
  )
}
export function ContactDesktop() {
  return (
    <div className="w-full bg-blue-600 py-8">
      <div className="container mx-auto px-6 text-center">
        <h2 className="text-4xl font-bold text-white mb-6">Ready to save hours and get paid faster?</h2>
        <div className="space-y-4">
          <a href="/demo" className="bg-white text-blue-600 hover:bg-gray-100 font-bold py-4 px-8 rounded-lg text-xl transition-colors inline-block">
            Request a Demo
          </a>
          <p className="text-blue-100 text-lg">or email: info@freshwall.app</p>
        </div>
      </div>
    </div>
  )
}
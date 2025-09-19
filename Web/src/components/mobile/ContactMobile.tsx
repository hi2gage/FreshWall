export function ContactMobile() {
  return (
    <div className="w-full min-h-screen-safe bg-blue-600 flex items-center justify-center">
      <div className="container mx-auto px-4 text-center">
        <h2 className="text-xl font-bold text-white mb-4">Ready to save hours and get paid faster?</h2>
        <div className="space-y-3">
          <a href="/demo" className="bg-white text-blue-600 hover:bg-gray-100 font-bold py-3 px-6 rounded-lg text-base transition-colors inline-block">
            Request a Demo
          </a>
          <p className="text-blue-100 text-sm">or email: info@freshwall.app</p>
        </div>
      </div>
    </div>
  )
}
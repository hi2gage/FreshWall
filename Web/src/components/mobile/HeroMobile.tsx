export function HeroMobile() {
  return (
    <div className="w-full bg-white py-6">
      <div className="container mx-auto px-4">
        <div className="text-center space-y-6">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 mb-3 leading-tight">
              Take the Graffiti Out of Your Paperwork
            </h1>
            <p className="text-sm text-gray-700 mb-4 px-2">
              FreshWall helps graffiti removal companies log jobs, capture photos, and generate invoices in minutes.
            </p>
          </div>

          <div className="flex justify-center">
            <div className="w-48 bg-black rounded-[2.5rem] p-1.5 shadow-xl">
              <div className="relative bg-black rounded-[2rem] overflow-hidden">
                <div className="absolute top-3 left-1/2 transform -translate-x-1/2 w-14 h-3 bg-black rounded-full z-10"></div>
                <img
                  src="/dashboard-screenshot.png"
                  alt="FreshWall iPhone App Dashboard"
                  className="w-full h-auto rounded-[2rem]"
                />
              </div>
            </div>
          </div>

          <div>
            <a href="/demo" className="bg-green-600 hover:bg-green-700 text-white font-bold py-2.5 px-5 rounded-lg text-sm transition-colors inline-block">
              Request a Demo
            </a>
            <p className="text-gray-600 text-xs mt-3">info@freshwall.app</p>
          </div>
        </div>
      </div>
    </div>
  )
}
export function HeroDesktop() {
  return (
    <div className="bg-white w-full py-8">
      <div className="container mx-auto px-6">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          <div className="text-left">
            <h1 className="text-6xl font-bold text-gray-900 mb-6">
              Take the Graffiti Out of Your Paperwork
            </h1>
            <p className="text-xl text-gray-700 mb-8">
              FreshWall helps graffiti removal companies log jobs, capture photos, and generate invoices in minutes so your crew spends more time in the field, not buried in admin.
            </p>
            <div className="mb-8">
              <a href="/demo" className="bg-green-600 hover:bg-green-700 text-white font-bold py-3 px-8 rounded-lg text-lg transition-colors inline-block">
                Request a Demo
              </a>
            </div>
            <div className="text-gray-600 text-sm">
              <p>info@freshwall.app</p>
            </div>
          </div>
          <div className="flex justify-end">
            <div className="relative">
              <div className="w-72 bg-black rounded-[3rem] p-2 shadow-2xl">
                <div className="relative bg-black rounded-[2rem] overflow-hidden">
                  <img
                    src="/dashboard-screenshot.png"
                    alt="FreshWall iPhone App Dashboard"
                    className="w-full h-auto rounded-[2rem]"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
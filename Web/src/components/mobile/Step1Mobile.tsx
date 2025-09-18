export function Step1Mobile() {
  return (
    <div className="w-full bg-white py-4">
      <div className="container mx-auto px-4">
        <div className="text-center space-y-4">
          <div>
            <div className="w-12 h-12 bg-blue-600 text-white text-xl font-bold rounded-full flex items-center justify-center mx-auto mb-3">
              1
            </div>
            <h3 className="text-xl font-bold text-gray-900 mb-2">Capture on-site</h3>
            <p className="text-sm text-gray-600 px-4">Crews log jobs with photos and details in the mobile app.</p>
          </div>

          <div className="flex justify-center">
            <div className="w-48 bg-black rounded-[2.5rem] p-1.5 shadow-xl">
              <div className="relative bg-black rounded-[2rem] overflow-hidden">
                <div className="absolute top-3 left-1/2 transform -translate-x-1/2 w-14 h-3 bg-black rounded-full z-10"></div>
                <img
                  src="/add-incident.png"
                  alt="Add Incident Screen"
                  className="w-full h-auto rounded-[2rem]"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
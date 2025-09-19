export function Step3Mobile() {
  return (
    <div className="w-full h-full bg-white flex items-center">
      <div className="container mx-auto px-4 max-h-full overflow-y-auto">
        <div className="text-center space-y-6">
          <div>
            <div className="w-12 h-12 bg-blue-600 text-white text-xl font-bold rounded-full flex items-center justify-center mx-auto mb-3">
              3
            </div>
            <h3 className="text-xl font-bold text-gray-900 mb-2">Bill faster</h3>
            <p className="text-sm text-gray-600 px-4">Generate invoices and PDF reports in minutes, not days.</p>
          </div>

          <div className="flex justify-center">
            <div className="w-48 bg-black rounded-[2.5rem] p-1.5 shadow-xl">
              <div className="relative bg-black rounded-[2rem] overflow-hidden">
                <img
                  src="/incident-details.png"
                  alt="Incident Details Screen"
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
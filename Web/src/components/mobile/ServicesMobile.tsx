const steps = [
  {
    step: "1",
    title: "Capture on-site",
    description: "Crews log jobs with photos and details in the mobile app."
  },
  {
    step: "2",
    title: "Track automatically",
    description: "Job data, timestamps, and materials are organized for you."
  },
  {
    step: "3",
    title: "Bill faster",
    description: "Generate invoices and PDF reports in minutes, not days."
  }
]

export function ServicesMobile() {
  return (
    <div className="w-full bg-white py-8">
      <div className="container mx-auto px-4">
        <div className="text-center mb-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">How It Works</h2>
        </div>

        <div className="space-y-12">
          {steps.map((step, index) => (
            <div key={index} className="text-center">
              <div className="w-12 h-12 bg-blue-600 text-white text-lg font-bold rounded-full flex items-center justify-center mx-auto mb-4">
                {step.step}
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-2">{step.title}</h3>
              <p className="text-sm text-gray-600 mb-4 px-4">{step.description}</p>

              <div className="flex justify-center">
                {step.step === "1" && (
                  <div className="w-32 bg-black rounded-[2rem] p-1 shadow-lg">
                    <div className="relative bg-black rounded-[1.5rem] overflow-hidden">
                      <div className="absolute top-2 left-1/2 transform -translate-x-1/2 w-12 h-3 bg-black rounded-full z-10"></div>
                      <img
                        src="/add-incident.png"
                        alt="Add Incident Screen"
                        className="w-full h-auto rounded-[1.5rem]"
                      />
                    </div>
                  </div>
                )}
                {step.step === "2" && (
                  <div className="w-32 bg-black rounded-[2rem] p-1 shadow-lg">
                    <div className="relative bg-black rounded-[1.5rem] overflow-hidden">
                      <div className="absolute top-2 left-1/2 transform -translate-x-1/2 w-12 h-3 bg-black rounded-full z-10"></div>
                      <img
                        src="/incidents-list.png"
                        alt="Incidents List Screen"
                        className="w-full h-auto rounded-[1.5rem]"
                      />
                    </div>
                  </div>
                )}
                {step.step === "3" && (
                  <div className="w-32 bg-black rounded-[2rem] p-1 shadow-lg">
                    <div className="relative bg-black rounded-[1.5rem] overflow-hidden">
                      <div className="absolute top-2 left-1/2 transform -translate-x-1/2 w-12 h-3 bg-black rounded-full z-10"></div>
                      <img
                        src="/incident-details.png"
                        alt="Incident Details Screen"
                        className="w-full h-auto rounded-[1.5rem]"
                      />
                    </div>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
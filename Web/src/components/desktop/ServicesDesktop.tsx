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

export function ServicesDesktop() {
  return (
    <div className="w-full bg-white py-8">
      <div className="container mx-auto px-6">
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">How It Works</h2>
        </div>
        <div className="grid md:grid-cols-3 gap-8 max-w-6xl mx-auto">
          {steps.map((step, index) => (
            <div key={index} className="text-center">
              <div className="w-16 h-16 bg-blue-600 text-white text-2xl font-bold rounded-full flex items-center justify-center mx-auto mb-6">
                {step.step}
              </div>
              <h3 className="text-2xl font-semibold text-gray-900 mb-4">{step.title}</h3>
              <p className="text-lg text-gray-600 mb-6">{step.description}</p>
              <div className="flex justify-center">
                {step.step === "1" && (
                  <div className="w-48 bg-black rounded-[2.5rem] p-1.5 shadow-2xl">
                    <div className="relative bg-black rounded-[2rem] overflow-hidden">
                      <div className="absolute top-4 left-1/2 transform -translate-x-1/2 w-16 h-4 bg-black rounded-full z-10"></div>
                      <img
                        src="/add-incident.png"
                        alt="Add Incident Screen"
                        className="w-full h-auto rounded-[2rem]"
                      />
                    </div>
                  </div>
                )}
                {step.step === "2" && (
                  <div className="w-48 bg-black rounded-[2.5rem] p-1.5 shadow-2xl">
                    <div className="relative bg-black rounded-[2rem] overflow-hidden">
                      <div className="absolute top-4 left-1/2 transform -translate-x-1/2 w-16 h-4 bg-black rounded-full z-10"></div>
                      <img
                        src="/incidents-list.png"
                        alt="Incidents List Screen"
                        className="w-full h-auto rounded-[2rem]"
                      />
                    </div>
                  </div>
                )}
                {step.step === "3" && (
                  <div className="w-48 bg-black rounded-[2.5rem] p-1.5 shadow-2xl">
                    <div className="relative bg-black rounded-[2rem] overflow-hidden">
                      <div className="absolute top-4 left-1/2 transform -translate-x-1/2 w-16 h-4 bg-black rounded-full z-10"></div>
                      <img
                        src="/incident-details.png"
                        alt="Incident Details Screen"
                        className="w-full h-auto rounded-[2rem]"
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
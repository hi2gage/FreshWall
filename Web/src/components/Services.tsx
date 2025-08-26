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

export function Services() {
  return (
    <>
      {/* Why FreshWall Section */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-6">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-8">Why FreshWall?</h2>
            <div className="max-w-4xl mx-auto text-left">
              <p className="text-xl text-gray-700 mb-6">
                Graffiti removal is tough enough without chasing paperwork. Crews snap photos on their phones, managers sort through endless texts, and invoices get delayed or lost. FreshWall fixes that with one simple system:
              </p>
              <ul className="space-y-4 text-lg text-gray-700">
                <li className="flex items-start">
                  <span className="text-blue-600 mr-3">•</span>
                  Log every job instantly with photos, notes, and location.
                </li>
                <li className="flex items-start">
                  <span className="text-blue-600 mr-3">•</span>
                  Generate invoices automatically ready to send with a click.
                </li>
                <li className="flex items-start">
                  <span className="text-blue-600 mr-3">•</span>
                  Share clean reports with customers and city officials that prove the work you've done.
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section className="py-20 bg-gray-50">
        <div className="container mx-auto px-6">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">How It Works</h2>
          </div>

          <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
            {steps.map((step, index) => (
              <div key={index} className="text-center">
                <div className="w-16 h-16 bg-blue-600 text-white text-2xl font-bold rounded-full flex items-center justify-center mx-auto mb-6">
                  {step.step}
                </div>
                <h3 className="text-2xl font-semibold text-gray-900 mb-4">{step.title}</h3>
                <p className="text-lg text-gray-600">{step.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
    </>
  )
}
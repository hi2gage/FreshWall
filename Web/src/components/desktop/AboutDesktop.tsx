const benefits = [
  "Save 3–5 hours a week on admin work.",
  "Stop missing invoices and get paid faster.",
  "Keep all job records, photos, and reports in one place.",
  "Build trust with customers through professional documentation.",
  "No IT setup, no training required. Just download and go."
]

export function AboutDesktop() {
  return (
    <div className="w-full min-h-screen-safe bg-gray-50 flex items-center justify-center">
      <div className="container mx-auto px-6">
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold text-gray-900 mb-8">Benefits</h2>
        </div>
        <div className="max-w-5xl mx-auto">
          <div className="grid md:grid-cols-2 gap-8">
            <div>
              <ul className="space-y-4 text-lg text-gray-700">
                {benefits.slice(0, 3).map((benefit, index) => (
                  <li key={index} className="flex items-start">
                    <span className="text-blue-600 mr-4 text-xl">•</span>
                    <span>{benefit}</span>
                  </li>
                ))}
              </ul>
            </div>
            <div>
              <ul className="space-y-4 text-lg text-gray-700">
                {benefits.slice(3).map((benefit, index) => (
                  <li key={index + 3} className="flex items-start">
                    <span className="text-blue-600 mr-4 text-xl">•</span>
                    <span>{benefit}</span>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
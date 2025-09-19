const benefits = [
  "Save 3–5 hours a week on admin work.",
  "Stop missing invoices and get paid faster.",
  "Keep all job records, photos, and reports in one place.",
  "Build trust with customers through professional documentation.",
  "No IT setup, no training required. Just download and go."
]

export function AboutMobile() {
  return (
    <div className="w-full min-h-screen-safe bg-gray-50 flex items-center justify-center">
      <div className="container mx-auto px-4">
        <div className="text-center mb-6">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">Benefits</h2>
        </div>
        <div className="max-w-sm mx-auto">
          <ul className="space-y-3 text-sm text-gray-700">
            {benefits.map((benefit, index) => (
              <li key={index} className="flex items-start">
                <span className="text-blue-600 mr-3 text-lg flex-shrink-0">•</span>
                <span>{benefit}</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  )
}
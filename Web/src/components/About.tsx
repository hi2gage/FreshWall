const benefits = [
  "Save 3–5 hours a week on admin work.",
  "Stop missing invoices and get paid faster.",
  "Keep all job records, photos, and reports in one place.",
  "Build trust with customers through professional documentation.",
  "No IT setup, no training required. Just download and go."
]

const features = [
  "Mobile job logging with photos.",
  "Auto-generated invoices with line items.",
  "PDF reports for customers or city programs.",
  "Team roles with access control."
]

export function About() {
  return (
    <>
      {/* Benefits Section */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-6">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-8">Benefits</h2>
          </div>
          <div className="max-w-4xl mx-auto">
            <ul className="space-y-6 text-lg text-gray-700">
              {benefits.map((benefit, index) => (
                <li key={index} className="flex items-start">
                  <span className="text-brand-600 mr-4 text-2xl">•</span>
                  <span>{benefit}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-gray-50">
        <div className="container mx-auto px-6">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-8">Features</h2>
          </div>
          <div className="max-w-4xl mx-auto">
            <ul className="space-y-6 text-lg text-gray-700">
              {features.map((feature, index) => (
                <li key={index} className="flex items-start">
                  <span className="text-brand-600 mr-4 text-2xl">•</span>
                  <span>{feature}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>
    </>
  )
}
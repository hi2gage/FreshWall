const faqItems = [
  {
    question: "Will this work for a small team?",
    answer: "Yes. FreshWall is built for crews from 1 to 20 people."
  },
  {
    question: "Do my crews need training?",
    answer: "No. If they can take a photo and fill in a few fields, they're ready."
  },
  {
    question: "Can we attach photos to invoices?",
    answer: "Absolutely. Every invoice can include photo evidence of the work."
  },
  {
    question: "How quickly can we get started?",
    answer: "Right away. Sign up takes 2 minutes, then download the app and start logging jobs immediately."
  },
  {
    question: "Can we customize invoices with our company logo?",
    answer: "Yes. Add your logo, company colors, and contact information to create professional branded invoices."
  },
  {
    question: "Can we set different rates for different types of jobs?",
    answer: "Absolutely. Set custom rates for removal, cleaning, coating, or any service you offer."
  },
]

export function Pricing() {
  return (
    <>
      {/* Pricing Section */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-6 text-center">
          <h2 className="text-4xl font-bold text-gray-900 mb-16">Pricing</h2>
          
          <div className="max-w-md mx-auto bg-white rounded-2xl p-8 border-2 border-gray-300">
            <div className="mb-6">
              <h3 className="text-2xl font-bold text-gray-900 mb-2">Founding Customer Plan</h3>
              <div className="text-4xl font-bold text-green-600 mb-2">$99<span className="text-lg text-gray-600">/month</span></div>
              <div className="text-gray-600 line-through">regularly $149</div>
            </div>
            
            <ul className="space-y-3 text-left mb-8">
              <li className="flex items-center text-gray-700">
                <span className="text-green-600 mr-3">✓</span>
                Locked rate for the first 10 companies
              </li>
              <li className="flex items-center text-gray-700">
                <span className="text-green-600 mr-3">✓</span>
                Unlimited jobs with photos
              </li>
              <li className="flex items-center text-gray-700">
                <span className="text-green-600 mr-3">✓</span>
                All features included
              </li>
              <li className="flex items-center text-gray-700">
                <span className="text-green-600 mr-3">✓</span>
                Cancel anytime
              </li>
            </ul>
            
            <a
              href="/demo"
              className="w-full bg-green-700 hover:bg-green-800 text-white font-bold py-3 px-6 rounded-lg text-lg transition-colors inline-block text-center"
            >
              Request a Demo
            </a>
          </div>
          
          <div className="mt-8 max-w-2xl mx-auto">
            <h4 className="text-xl font-semibold text-gray-900 mb-4">Why so affordable?</h4>
            <p className="text-gray-700">
              We're working with early partners to refine FreshWall. In return, you get the software at a permanent discount.
            </p>
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section className="py-20 bg-gray-50">
        <div className="container mx-auto px-6 text-center">
          <div className="max-w-4xl mx-auto">
            <blockquote className="text-2xl italic text-gray-700 mb-6">
              "FreshWall saves us hours every week. Invoicing used to take a day, now it's done in minutes."
            </blockquote>
            <cite className="text-lg text-green-600 font-semibold">Montana Graffiti Removal Co.</cite>
          </div>
        </div>
      </section>

      {/* FAQ Section */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-6">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-8">FAQ</h2>
          </div>
          
          <div className="max-w-4xl mx-auto space-y-8">
            {faqItems.map((item, index) => (
              <div key={index} className="border-b border-gray-200 pb-6">
                <h3 className="text-xl font-semibold text-gray-900 mb-3">{item.question}</h3>
                <p className="text-lg text-gray-700">{item.answer}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
    </>
  )
}
export function PricingDesktop() {
  return (
    <div className="w-full bg-white py-8">
      <div className="container mx-auto px-6 text-center">
        <h2 className="text-4xl font-bold text-gray-900 mb-12">Pricing</h2>

        <div className="max-w-md mx-auto bg-gradient-to-br from-blue-50 to-indigo-100 rounded-2xl p-6 border-2 border-blue-200">
          <div className="mb-4">
            <h3 className="text-xl font-bold text-gray-900 mb-2">Founding Customer Plan</h3>
            <div className="text-3xl font-bold text-blue-600 mb-1">$99<span className="text-base text-gray-600">/month</span></div>
            <div className="text-gray-600 line-through text-sm">regularly $149</div>
          </div>

          <ul className="space-y-2 text-left mb-6 text-sm">
            <li className="flex items-center text-gray-700">
              <span className="text-blue-600 mr-2">✓</span>
              Locked rate for the first 10 companies
            </li>
            <li className="flex items-center text-gray-700">
              <span className="text-blue-600 mr-2">✓</span>
              Unlimited jobs with photos
            </li>
            <li className="flex items-center text-gray-700">
              <span className="text-blue-600 mr-2">✓</span>
              All features included
            </li>
            <li className="flex items-center text-gray-700">
              <span className="text-blue-600 mr-2">✓</span>
              Export data at anytime
            </li>
            <li className="flex items-center text-gray-700">
              <span className="text-blue-600 mr-2">✓</span>
              Cancel anytime
            </li>
          </ul>

          <a href="/demo" className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg transition-colors inline-block text-center">
            Request a Demo
          </a>
        </div>

        <div className="mt-6 max-w-2xl mx-auto">
          <h4 className="text-lg font-semibold text-gray-900 mb-2">Why so affordable?</h4>
          <p className="text-gray-700 text-sm">
            We're working with early partners to refine FreshWall. In return, you get the software at a permanent discount.
          </p>
        </div>
      </div>
    </div>
  )
}
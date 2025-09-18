export function PricingMobile() {
  return (
    <div className="w-full bg-white py-8">
      <div className="container mx-auto px-4 text-center">
        <h2 className="text-2xl font-bold text-gray-900 mb-8">Pricing</h2>

        <div className="max-w-xs mx-auto bg-gradient-to-br from-blue-50 to-indigo-100 rounded-xl p-4 border-2 border-blue-200">
          <div className="mb-3">
            <h3 className="text-lg font-bold text-gray-900 mb-1">Founding Customer Plan</h3>
            <div className="text-2xl font-bold text-blue-600 mb-1">$99<span className="text-sm text-gray-600">/month</span></div>
            <div className="text-gray-600 line-through text-xs">regularly $149</div>
          </div>

          <ul className="space-y-1.5 text-left mb-4 text-xs">
            <li className="flex items-center text-gray-700">
              <span className="text-blue-600 mr-2">✓</span>
              Locked rate for first 10 companies
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

          <a href="/demo" className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg text-sm transition-colors inline-block text-center">
            Request a Demo
          </a>
        </div>

        <div className="mt-4 max-w-sm mx-auto">
          <h4 className="text-base font-semibold text-gray-900 mb-2">Why so affordable?</h4>
          <p className="text-gray-700 text-xs">
            We're working with early partners to refine FreshWall. In return, you get the software at a permanent discount.
          </p>
        </div>
      </div>
    </div>
  )
}
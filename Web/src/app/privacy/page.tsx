import { Metadata } from 'next'
import Link from 'next/link'

export const metadata: Metadata = {
  title: 'Privacy Policy - FreshWall',
  description: 'Privacy policy for FreshWall mobile application.',
}

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-white py-12">
      <div className="max-w-4xl mx-auto px-6">
        <h1 className="text-4xl font-bold text-gray-900 mb-8">Privacy Policy</h1>

        <div className="mb-8 p-6 bg-gray-50 rounded-lg text-sm text-gray-900">
          <p className="mb-2 text-gray-900"><strong>Company:</strong> DraftRoom Studios (&quot;us&quot;, &quot;we&quot;, or &quot;our&quot;)</p>
          <p className="text-gray-900"><strong>Contact:</strong> support@draftroomstudios.com</p>
        </div>

        <p className="text-lg mb-8 leading-relaxed text-gray-900">
          DraftRoom Studios operates the FreshWall mobile application (the &quot;Service&quot;). This page informs you of our policies regarding the collection, use, and disclosure of data when you use our Service.
        </p>

        <div className="space-y-8 text-gray-900">
          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Information Collection and Use</h2>
            <p className="text-gray-800 mb-3">
              FreshWall collects limited data that is necessary to operate, maintain, and improve the Service.
            </p>
            <p className="text-gray-800">
              We are committed to minimizing data collection and using collected data only for analytics, performance monitoring, and core app functionality.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">What We Collect</h2>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Account Information</h3>
            <p className="text-gray-800 mb-4">
              When you create an account, we collect your name, email, company, and role to provide you with the Service.
            </p>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Job Data</h3>
            <p className="text-gray-800 mb-4">
              Job details, notes, photos, timestamps, and related data you enter into the app to track your work.
            </p>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Analytics & Usage Data</h3>
            <p className="text-gray-800 mb-3">
              FreshWall uses Google Analytics for Firebase to understand how the app is used and to improve reliability and features. This may include:
            </p>
            <div className="space-y-2 mb-4">
              <p className="text-gray-800">• App interactions (such as screen views and feature usage)</p>
              <p className="text-gray-800">• Sessions and usage patterns</p>
              <p className="text-gray-800">• Performance metrics (such as launch time and stability)</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Identifiers</h2>
            <p className="text-gray-800 mb-3">
              The Service may collect limited identifiers for analytics and app functionality, including:
            </p>
            <div className="space-y-2 mb-4">
              <p className="text-gray-800">• A device-level identifier (such as a Firebase App Instance ID)</p>
              <p className="text-gray-800">• An internal account or organization identifier (such as a team ID or user role)</p>
            </div>
            <p className="text-gray-800">
              These identifiers are used only to associate activity within the Service and are not used for advertising.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Location Data</h2>
            <p className="text-gray-800 mb-3">
              FreshWall does not collect precise location data.
            </p>
            <p className="text-gray-800">
              The Service may derive coarse location information (such as country or region) from anonymized IP addresses for analytics and performance monitoring purposes.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Purchases</h2>
            <p className="text-gray-800 mb-3">
              If you make an in-app purchase or subscription, FreshWall may receive purchase-related metadata (such as product identifiers and pricing).
            </p>
            <p className="text-gray-800">
              We do not collect or store payment card details or financial account information. All payments are processed directly by Apple via StoreKit.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">How We Use Data</h2>
            <p className="text-gray-800 mb-3">Data collected by FreshWall is used solely for:</p>
            <div className="space-y-2">
              <p className="text-gray-800">• <strong>Analytics</strong> – understanding feature usage and improving the Service</p>
              <p className="text-gray-800">• <strong>App Functionality</strong> – enabling features, associating activity with accounts or teams, and supporting troubleshooting</p>
              <p className="text-gray-800">• <strong>Performance & Reliability</strong> – monitoring stability, diagnosing issues, and improving scalability</p>
              <p className="text-gray-800">• <strong>Communications</strong> – responding to support requests and sending transactional emails</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">What We Do Not Do</h2>
            <p className="text-gray-800 mb-3">FreshWall does not:</p>
            <div className="space-y-2">
              <p className="text-gray-800">• Sell user data</p>
              <p className="text-gray-800">• Display third-party advertisements</p>
              <p className="text-gray-800">• Use data for marketing or advertising purposes</p>
              <p className="text-gray-800">• Request or access Apple&apos;s advertising identifier (IDFA)</p>
              <p className="text-gray-800">• Track users across apps or websites</p>
              <p className="text-gray-800">• Share data with data brokers</p>
              <p className="text-gray-800">• Combine user data with data from other companies</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Sharing of Information</h2>
            <p className="text-gray-800 mb-3">We do not sell your data. We may share data with:</p>
            <div className="space-y-2">
              <p className="text-gray-800">• <strong>Service Providers:</strong> hosting, cloud storage, and analytics tools necessary to operate the Service</p>
              <p className="text-gray-800">• <strong>Legal & Safety:</strong> when required by law, or to protect rights, safety, and property</p>
              <p className="text-gray-800">• <strong>Business Transfers:</strong> in connection with mergers, acquisitions, or asset sales</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Third-Party Services</h2>
            <p className="text-gray-800 mb-3">
              FreshWall uses third-party services solely to support analytics and app functionality:
            </p>
            <div className="space-y-2">
              <p className="text-gray-800">• Google Analytics for Firebase</p>
            </div>
            <p className="text-gray-800 mt-3">
              These services process data in accordance with their own privacy policies.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Data Retention & Security</h2>
            <p className="text-gray-800 mb-3">
              We take reasonable administrative, technical, and organizational measures to protect the data we collect. Data is retained only as long as necessary for the purposes described in this policy.
            </p>
            <p className="text-gray-800">
              We keep your data while your account is active. Job data and photos may be deleted 30 days after subscription ends, unless required by contract or law.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Your Rights</h2>
            <p className="text-gray-800 mb-3">Depending on your location, you may have rights to:</p>
            <div className="space-y-2 mb-4">
              <p className="text-gray-800">• Access, update, or delete your personal info</p>
              <p className="text-gray-800">• Request a copy of your data</p>
              <p className="text-gray-800">• Opt out of marketing emails</p>
            </div>
            <p className="text-gray-800">
              To exercise these rights, contact us at support@draftroomstudios.com.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Children&apos;s Privacy</h2>
            <p className="text-gray-800">
              FreshWall is not intended for use by children under the age of 13. We do not knowingly collect personal information from children.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">International Users</h2>
            <p className="text-gray-800">
              If you access FreshWall from outside the United States, your data will be processed in the U.S. where privacy laws may differ.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Changes to This Privacy Policy</h2>
            <p className="text-gray-800">
              We may update this Privacy Policy from time to time. Any changes will be posted on this page and the &quot;Last updated&quot; date will be updated accordingly.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Contact Us</h2>
            <p className="text-gray-800 mb-3">
              If you have any questions about this Privacy Policy or our data practices, please contact us:
            </p>
            <div className="space-y-1">
              <p className="text-gray-800">Email: <a href="mailto:support@draftroomstudios.com" className="text-freshwall-orange hover:underline">support@draftroomstudios.com</a></p>
              <p className="text-gray-800">Website: <a href="https://draftroomstudios.com" className="text-freshwall-orange hover:underline" target="_blank" rel="noopener noreferrer">https://draftroomstudios.com</a></p>
            </div>
          </section>
        </div>

        <div className="mt-12 pt-8 border-t border-gray-200">
          <Link
            href="/"
            className="font-inter font-semibold rounded-lg transition-all duration-200 inline-flex items-center justify-center px-8 py-4 text-lg bg-freshwall-orange text-white hover:bg-charcoal-navy active:bg-opacity-80"
          >
            Back to Home
          </Link>
        </div>
      </div>
    </div>
  )
}

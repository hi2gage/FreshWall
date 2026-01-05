import { Metadata } from 'next'
import Link from 'next/link'

export const metadata: Metadata = {
  title: 'Terms of Service - FreshWall',
  description: 'Terms of service for using the FreshWall mobile application.',
}

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-white py-12">
      <div className="max-w-4xl mx-auto px-6">
        <h1 className="text-4xl font-bold text-gray-900 mb-8">Terms of Service</h1>

        <div className="mb-8 p-6 bg-gray-50 rounded-lg text-sm text-gray-900">
          <p className="mb-2 text-gray-900"><strong>Company:</strong> DraftRoom Studios (&quot;us&quot;, &quot;we&quot;, or &quot;our&quot;)</p>
          <p className="mb-2 text-gray-900"><strong>Service:</strong> FreshWall mobile application for job logging, photo capture, and reporting</p>
          <p className="text-gray-900"><strong>Contact:</strong> support@draftroomstudios.com</p>
        </div>

        <p className="text-lg mb-8 leading-relaxed text-gray-900">
          By using FreshWall, you agree to these Terms. If you&apos;re using FreshWall for a company, you represent you&apos;re authorized to bind that company.
        </p>

        <div className="space-y-8 text-gray-900">
          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">1) Accounts & Access</h2>
            <div className="space-y-2">
              <p className="text-gray-800">• You must provide accurate account info and keep credentials confidential.</p>
              <p className="text-gray-800">• You&apos;re responsible for activity under your account.</p>
              <p className="text-gray-800">• We may suspend access for misuse, security risk, non-payment, or to comply with law.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">2) Billing & Payment</h2>
            <div className="space-y-2">
              <p className="text-gray-800">• Pricing is available upon request or shown on invoices.</p>
              <p className="text-gray-800">• Payments are processed through Wave. Wave&apos;s terms apply to all transactions.</p>
              <p className="text-gray-800">• Contact us to cancel or modify your subscription.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">3) Customer Data & Privacy</h2>
            <div className="space-y-2 mb-4">
              <p className="text-gray-800">• &quot;Customer Data&quot; means content you submit—job records, photos, notes, and user info.</p>
              <p className="text-gray-800">• You own your Customer Data. We process it to provide and improve the Service per our Privacy Policy.</p>
              <p className="text-gray-800">• You&apos;re responsible for getting any required consents (e.g., if photos contain people or property identifiers).</p>
            </div>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Data Retention & Export</h3>
            <div className="space-y-2">
              <p className="text-gray-800">• You can export your data during an active subscription.</p>
              <p className="text-gray-800">• We may delete Customer Data 30 days after termination, except backups kept for limited periods.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">4) Acceptable Use</h2>
            <p className="mb-3 text-gray-800">You agree not to:</p>
            <div className="space-y-2 mb-4">
              <p className="text-gray-800">• Upload illegal content or violate others&apos; privacy or IP rights.</p>
              <p className="text-gray-800">• Interfere with the Service, attempt unauthorized access, or exceed reasonable usage limits.</p>
              <p className="text-gray-800">• Use FreshWall for emergency services, life-critical systems, or real-time mission critical dispatch.</p>
            </div>
            <p className="text-gray-800">We may investigate and remove content or suspend accounts for violations.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">5) Photos & Reports</h2>
            <div className="space-y-2">
              <p className="text-gray-800">• Photos are used to generate reports and document your work.</p>
              <p className="text-gray-800">• Do not upload sensitive personal data (e.g., IDs, medical info).</p>
              <p className="text-gray-800">• You&apos;re responsible for complying with local laws and any applicable permits or program requirements.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">6) Third-Party Services</h2>
            <p className="text-gray-800">
              FreshWall integrates with third parties (e.g., Firebase). Their terms and privacy policies apply to their services. We&apos;re not responsible for third-party actions or outages.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">7) IP Ownership & Feedback</h2>
            <div className="space-y-2">
              <p className="text-gray-800">• We own the Service and all related IP. You receive a limited, non-exclusive, non-transferable license to use it during your subscription.</p>
              <p className="text-gray-800">• If you submit ideas or feedback, we may use them without obligation or compensation.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">8) Availability, Support & Changes</h2>
            <div className="space-y-2">
              <p className="text-gray-800">• We aim for reliable uptime, but the Service may be unavailable due to maintenance or factors outside our control.</p>
              <p className="text-gray-800">• We may change or discontinue features; if a change materially reduces core functionality of your paid plan, you can cancel.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">9) Security</h2>
            <p className="text-gray-800">
              We use reasonable administrative, technical, and physical safeguards. No method of transmission or storage is 100% secure. Notify us promptly of any suspected security issue at support@draftroomstudios.com.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">10) Warranties & Disclaimers</h2>
            <p className="text-gray-800">
              The Service is provided &quot;as is&quot; and &quot;as available&quot;. We disclaim all warranties, express or implied (including fitness, merchantability, non-infringement). FreshWall does not guarantee revenue, compliance, or outcome of any job or report.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">11) Limitation of Liability</h2>
            <p className="text-gray-800">
              To the maximum extent permitted by law, DraftRoom Studios and its suppliers are not liable for indirect, incidental, special, consequential, or punitive damages, or any loss of profits, revenue, data, or use. Our aggregate liability arising out of or relating to the Service is limited to the amounts you paid to us in the 12 months before the claim.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">12) Indemnification</h2>
            <p className="text-gray-800">
              You will defend, indemnify, and hold DraftRoom Studios harmless from claims arising out of your use of the Service, Customer Data, or breach of these Terms.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">13) Termination</h2>
            <p className="text-gray-800">
              You may cancel anytime by contacting us. We may suspend or terminate for cause (e.g., misuse, non-payment). Upon termination, your license ends and access to the Service stops. Sections intended to survive (e.g., IP, limitations, indemnity) will survive.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">14) Governing Law & Disputes</h2>
            <p className="mb-2 text-gray-800">These Terms are governed by the laws of the State of Montana (without regard to conflicts of laws).</p>
            <p className="mb-2 text-gray-800">Venue: the state and federal courts located in Montana.</p>
            <p className="text-gray-800">You and DraftRoom Studios waive jury trial rights where permitted.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">15) Export & Compliance</h2>
            <p className="text-gray-800">
              You agree to comply with applicable export controls and sanctions. You won&apos;t use the Service where prohibited by law.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">16) Changes to Terms</h2>
            <p className="text-gray-800">
              We may update these Terms occasionally. We&apos;ll post the new date and, for material changes, notify account owners by email or in-app. Continued use after changes means you accept the updated Terms.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">17) Contact</h2>
            <p className="text-gray-800 mb-3">
              If you have any questions about these Terms, please contact us:
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

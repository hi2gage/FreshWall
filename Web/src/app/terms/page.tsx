import { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Terms & Conditions - FreshWall',
  description: 'Terms and conditions for using FreshWall job logging and invoicing software.',
}

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-white py-12">
      <div className="max-w-4xl mx-auto px-6">
        <h1 className="text-4xl font-bold text-gray-900 mb-8">Terms & Conditions</h1>
        
        <div className="mb-8 p-6 bg-gray-50 rounded-lg text-sm text-gray-900">
          <p className="mb-2 text-gray-900"><strong>Effective date:</strong> December 1, 2024</p>
          <p className="mb-2 text-gray-900"><strong>Company:</strong> FreshWall LLC ("FreshWall", "we", "us", "our")</p>
          <p className="mb-2 text-gray-900"><strong>Service:</strong> FreshWall job logging, photo capture, reporting, and invoicing tools (web, mobile, and APIs).</p>
          <p className="text-gray-900"><strong>Contact:</strong> info@freshwall.app</p>
        </div>

        <p className="text-lg mb-8 leading-relaxed text-gray-900">By using FreshWall, you agree to these Terms. If you're using FreshWall for a company, you represent you're authorized to bind that company.</p>

        <div className="space-y-8 text-gray-900">
          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">1) Accounts & Access</h2>
            <div className="space-y-2">
              <p className="text-gray-800">• You must provide accurate account info and keep credentials confidential.</p>
              <p className="text-gray-800">• You're responsible for activity under your account.</p>
              <p className="text-gray-800">• We may suspend access for misuse, security risk, non-payment, or to comply with law.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">2) Subscriptions, Trials & Billing</h2>
            <div className="space-y-2 mb-4">
              <p className="text-gray-800">• Pricing is shown at checkout or on our site. Plans auto-renew monthly (or annually).</p>
              <p className="text-gray-800">• Trials: if not canceled before the trial ends, your plan begins automatically.</p>
              <p className="text-gray-800">• Taxes may apply. You authorize us (via our payment processor) to charge your payment method.</p>
            </div>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Cancellations & Refunds</h3>
            <div className="space-y-2">
              <p className="text-gray-800">• Cancel anytime; your plan remains active until the end of the current billing period.</p>
              <p className="text-gray-800">• We don't offer pro-rated refunds for partial periods, unless required by law.</p>
              <p className="text-gray-800">• If billing fails, we may pause or terminate your access.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">3) Customer Data & Privacy</h2>
            <div className="space-y-2 mb-4">
              <p className="text-gray-800">• "Customer Data" means content you submit—job records, photos, notes, location, invoices, and user info.</p>
              <p className="text-gray-800">• You own your Customer Data. We process it to provide and improve the Service per our Privacy Policy.</p>
              <p className="text-gray-800">• You're responsible for getting any required consents (e.g., if photos contain people or property identifiers).</p>
            </div>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Data retention & export</h3>
            <div className="space-y-2">
              <p className="text-gray-800">• You can export your data during an active subscription.</p>
              <p className="text-gray-800">• We may delete Customer Data 30 days after termination, except backups kept for limited periods.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">4) Acceptable Use</h2>
            <p className="mb-3 text-gray-800">You agree not to:</p>
            <div className="space-y-2 mb-4">
              <p className="text-gray-800">• Upload illegal content or violate others' privacy or IP rights.</p>
              <p className="text-gray-800">• Interfere with the Service, attempt unauthorized access, or exceed reasonable usage limits (e.g., automated scraping, abusive API calls).</p>
              <p className="text-gray-800">• Use FreshWall for emergency services, life-critical systems, or real-time mission critical dispatch.</p>
            </div>
            <p className="text-gray-800">We may investigate and remove content or suspend accounts for violations.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">5) Photos, Location & Reports</h2>
            <div className="space-y-2">
              <p className="text-gray-800">• Photos and locations are used to generate reports/invoices.</p>
              <p className="text-gray-800">• Do not upload sensitive personal data (e.g., IDs, medical info).</p>
              <p className="text-gray-800">• You're responsible for complying with local laws, permits, and city program requirements for reporting.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">6) Third-Party Services</h2>
            <p className="text-gray-800">FreshWall integrates with third parties (e.g., cloud storage, payments). Their terms and privacy policies apply to their services. We're not responsible for third-party actions or outages.</p>
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
              <p className="text-gray-800">• We may change or discontinue features; if a change materially reduces core functionality of your paid plan, you can cancel and we'll refund the unused portion of your current period.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">9) Security</h2>
            <p className="text-gray-800">We use reasonable administrative, technical, and physical safeguards. No method of transmission or storage is 100% secure. Notify us promptly of any suspected security issue at security@freshwall.app.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">10) Warranties & Disclaimers</h2>
            <p className="text-gray-800">The Service is provided "as is" and "as available". We disclaim all warranties, express or implied (including fitness, merchantability, non-infringement). FreshWall does not guarantee revenue, compliance, or outcome of any cleanup or report.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">11) Limitation of Liability</h2>
            <p className="text-gray-800">To the maximum extent permitted by law, FreshWall and its suppliers are not liable for indirect, incidental, special, consequential, or punitive damages, or any loss of profits, revenue, data, or use. Our aggregate liability arising out of or relating to the Service is limited to the amounts you paid to us in the 12 months before the claim.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">12) Indemnification</h2>
            <p className="text-gray-800">You will defend, indemnify, and hold FreshWall harmless from claims arising out of your use of the Service, Customer Data, or breach of these Terms.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">13) Termination</h2>
            <p className="text-gray-800">You may cancel anytime. We may suspend or terminate for cause (e.g., misuse, non-payment). Upon termination, your license ends and access to the Service stops. Sections intended to survive (e.g., IP, limitations, indemnity) will survive.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">14) Governing Law & Disputes</h2>
            <p className="mb-2 text-gray-800">These Terms are governed by the laws of the State of Montana (without regard to conflicts of laws).</p>
            <p className="mb-2 text-gray-800">Venue: the state and federal courts located in Bozeman, Montana.</p>
            <p className="text-gray-800">You and FreshWall waive jury trial rights where permitted.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">15) Export & Compliance</h2>
            <p className="text-gray-800">You agree to comply with applicable export controls and sanctions. You won't use the Service where prohibited by law.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">16) Changes to Terms</h2>
            <p className="text-gray-800">We may update these Terms occasionally. We'll post the new date and, for material changes, notify account owners by email or in-app. Continued use after changes means you accept the updated Terms.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">17) Contact</h2>
            <p className="mb-2 text-gray-800"><strong>Questions?</strong> info@freshwall.app</p>
            <p className="text-gray-800"><strong>Mailing address:</strong> FreshWall LLC, Bozeman, Montana</p>
          </section>
        </div>

        <div className="mt-12 pt-8 border-t border-gray-200">
          <a 
            href="/" 
            className="bg-green-700 hover:bg-green-800 text-white font-bold py-3 px-8 rounded-lg text-lg transition-colors inline-block"
          >
            Back to Home
          </a>
        </div>
      </div>
    </div>
  )
}
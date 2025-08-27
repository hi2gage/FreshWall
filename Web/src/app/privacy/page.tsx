import { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Privacy Policy - FreshWall',
  description: 'Privacy policy for FreshWall job logging and invoicing software.',
}

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-white py-12">
      <div className="max-w-4xl mx-auto px-6">
        <h1 className="text-4xl font-bold text-gray-900 mb-8">Privacy Policy</h1>
        
        <div className="mb-8 p-6 bg-gray-50 rounded-lg text-sm text-gray-900">
          <p className="mb-2 text-gray-900"><strong>Effective date:</strong> December 1, 2024</p>
          <p className="mb-2 text-gray-900"><strong>Company:</strong> FreshWall LLC ("FreshWall", "we", "us", "our")</p>
          <p className="text-gray-900"><strong>Contact:</strong> info@freshwall.app</p>
        </div>

        <p className="text-lg mb-8 leading-relaxed text-gray-900">We respect your privacy and are committed to protecting your information. This Privacy Policy explains what data we collect, how we use it, and your choices.</p>

        <div className="space-y-8 text-gray-900">
          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">1) Information We Collect</h2>
            <div className="space-y-2">
              <p className="text-gray-800">• <strong>Account Information:</strong> name, email, company, role, billing info.</p>
              <p className="text-gray-800">• <strong>Job Data:</strong> job details, notes, photos, GPS location, timestamps, invoices.</p>
              <p className="text-gray-800">• <strong>Device & Usage Data:</strong> browser type, IP address, app performance, cookies.</p>
              <p className="text-gray-800">• <strong>Communications:</strong> emails, support chats, demo requests.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">2) How We Use Information</h2>
            <p className="text-gray-800 mb-3">We use your data to:</p>
            <div className="space-y-2">
              <p className="text-gray-800">• Provide, operate, and improve FreshWall.</p>
              <p className="text-gray-800">• Generate invoices, reports, and analytics.</p>
              <p className="text-gray-800">• Send you transactional emails (e.g., receipts, updates).</p>
              <p className="text-gray-800">• Respond to support requests and demo inquiries.</p>
              <p className="text-gray-800">• Detect fraud, abuse, or security incidents.</p>
              <p className="text-gray-800">• Comply with law and enforce our Terms.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">3) Sharing of Information</h2>
            <p className="text-gray-800 mb-3">We do not sell your data. We may share data with:</p>
            <div className="space-y-2">
              <p className="text-gray-800">• <strong>Service Providers:</strong> hosting, cloud storage, payment processing, analytics, communication tools.</p>
              <p className="text-gray-800">• <strong>Legal & Safety:</strong> when required by law, or to protect rights, safety, and property.</p>
              <p className="text-gray-800">• <strong>Business Transfers:</strong> in connection with mergers, acquisitions, or asset sales.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">4) Data Retention</h2>
            <div className="space-y-2">
              <p className="text-gray-800">• We keep Customer Data while your account is active.</p>
              <p className="text-gray-800">• We may retain limited records (like invoices, support tickets) after account closure to comply with law.</p>
              <p className="text-gray-800">• Photos and job data may be deleted 30 days after subscription ends, unless required by contract.</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">5) Security</h2>
            <p className="text-gray-800">We use administrative, technical, and physical safeguards to protect your data. No system is 100% secure; please notify us at security@freshwall.app if you suspect an issue.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">6) Your Rights</h2>
            <p className="text-gray-800 mb-3">Depending on your location, you may have rights to:</p>
            <div className="space-y-2 mb-4">
              <p className="text-gray-800">• Access, update, or delete your personal info.</p>
              <p className="text-gray-800">• Request a copy of your data.</p>
              <p className="text-gray-800">• Opt out of marketing emails (unsubscribe link in each email).</p>
            </div>
            <p className="text-gray-800">To exercise these rights, contact us at info@freshwall.app.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">7) Cookies & Tracking</h2>
            <p className="text-gray-800">We use cookies and similar technologies for analytics, login sessions, and performance. You can control cookies via your browser, but disabling them may affect functionality.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">8) Children's Privacy</h2>
            <p className="text-gray-800">FreshWall is not directed to children under 16. We do not knowingly collect information from children.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">9) International Users</h2>
            <p className="text-gray-800">If you access FreshWall from outside the United States, your data will be processed in the U.S. where privacy laws may differ.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">10) Changes to This Policy</h2>
            <p className="text-gray-800">We may update this Privacy Policy from time to time. If we make material changes, we will notify you via email or in-app.</p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">11) Contact Us</h2>
            <p className="text-gray-800 mb-2"><strong>Questions?</strong></p>
            <div className="space-y-1">
              <p className="text-gray-800">• Email: info@freshwall.app</p>
              <p className="text-gray-800">• Mailing Address: FreshWall LLC, Bozeman, Montana</p>
            </div>
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
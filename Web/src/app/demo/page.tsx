import { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Request a Demo - FreshWall',
  description: 'Request a demo of FreshWall and see how it can help your graffiti removal company save time and get paid faster.',
}

export default function DemoPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="mx-auto max-w-2xl p-6">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">Request a Demo</h1>
          <p className="text-xl text-gray-700">
            Fill out the form below and we'll get back to you within 24 hours.
          </p>
        </div>
        <iframe
          src="https://tally.so/r/n98ZrQ?hideTitle=1"
          width="100%"
          height="760"
          style={{ border: 0 }}
          title="FreshWall Demo Request"
        />
      </div>
    </div>
  )
}
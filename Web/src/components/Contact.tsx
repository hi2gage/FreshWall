export function Contact() {
  return (
    <>
      {/* Call to Action Section */}
      <section className="py-20 bg-gray-800">
        <div className="container mx-auto px-6 text-center">
          <h2 className="text-4xl font-bold text-white mb-6">Ready to save hours and get paid faster?</h2>
          <div className="space-y-4">
            <a
              href="/demo"
              className="bg-white bg-green-700 hover:bg-green-800 text-white font-bold py-4 px-8 rounded-lg text-xl transition-colors inline-block"
            >
              Request a Demo
            </a>
            <p className="text-gray-300 text-lg">or email: info@freshwall.app</p>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="container mx-auto px-6 text-center">
          <div className="mb-6">
            <h3 className="text-2xl font-bold mb-2">FreshWall</h3>
            <p className="text-gray-400">Built in Montana</p>
          </div>
          <div className="flex justify-center space-x-8 text-gray-400">
            <a href="mailto:info@freshwall.app" className="hover:text-white transition-colors">
              info@freshwall.app
            </a>
            <span>|</span>
            <a href="/terms" className="hover:text-white transition-colors">Terms</a>
            <span>|</span>
            <a href="/privacy" className="hover:text-white transition-colors">Privacy</a>
          </div>
        </div>
      </footer>
    </>
  )
}
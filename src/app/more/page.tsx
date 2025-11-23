'use client';

import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';
import Link from 'next/link';

export default function MorePage() {
  const router = useRouter();
  const { user, loading } = useAuth();

  // Redirect if already logged in
  if (user && !loading) {
    router.push('/dashboard');
    return null;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Hero Section */}
      <div className="bg-gradient-to-b from-blue-50 to-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="text-center">
            <Link href="/" className="inline-block mb-8">
              <h1 className="text-4xl font-bold text-blue-600">FreshWall</h1>
            </Link>

            {/* User Choice - Step 1 */}
            <div className="max-w-2xl mx-auto">
              <h3 className="text-2xl font-bold text-gray-900 mb-8">
                Are you creating a new team or joining an existing one?
              </h3>

              <div className="grid md:grid-cols-2 gap-6">
                <Link
                  href="/more/create"
                  className="bg-white border-2 border-blue-200 hover:border-blue-400 rounded-xl p-8 text-left transition-colors group block"
                >
                  <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mb-4 group-hover:bg-blue-200 transition-colors">
                    <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                    </svg>
                  </div>
                  <h4 className="text-xl font-bold text-gray-900 mb-2">Create a New Team</h4>
                  <p className="text-gray-600">
                    Start fresh with your own team. You'll be the team admin and manage billing.
                  </p>
                </Link>

                <Link
                  href="/more/join"
                  className="bg-white border-2 border-gray-200 hover:border-blue-400 rounded-xl p-8 text-left transition-colors group block"
                >
                  <div className="w-12 h-12 bg-gray-100 rounded-lg flex items-center justify-center mb-4 group-hover:bg-blue-200 transition-colors">
                    <svg className="w-6 h-6 text-gray-600 group-hover:text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                  </div>
                  <h4 className="text-xl font-bold text-gray-900 mb-2">Join Existing Team</h4>
                  <p className="text-gray-600">
                    Join a team that's already set up. You'll need a team code from your admin.
                  </p>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>


      {/* Footer */}
      <footer className="bg-gray-100 border-t">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="text-center text-gray-600">
            <p>&copy; 2025 FreshWall. Professional graffiti incident tracking.</p>
            <div className="mt-4 space-x-4">
              <Link href="/privacy" className="hover:text-blue-600">Privacy Policy</Link>
              <Link href="/terms" className="hover:text-blue-600">Terms of Service</Link>
              <Link href="/" className="hover:text-blue-600">Back to Homepage</Link>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
'use client';

import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';
import SignupForm from '@/components/auth/SignupForm';
import Link from 'next/link';

export default function JoinTeamPage() {
  const router = useRouter();
  const { user, loading } = useAuth();

  // Redirect if already logged in
  if (user && !loading) {
    router.push('/dashboard');
    return null;
  }

  const handleSignupSuccess = () => {
    router.push('/dashboard');
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Hero Section */}
      <div className="bg-gradient-to-b from-green-50 to-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="text-center">
            <Link href="/" className="inline-block mb-8">
              <h1 className="text-4xl font-bold text-blue-600">FreshWall</h1>
            </Link>

            <h2 className="text-4xl font-extrabold text-gray-900 sm:text-5xl mb-6">
              Join Your Team
            </h2>

            <p className="text-xl text-gray-600 max-w-3xl mx-auto mb-8">
              You'll need a team code from your team admin to get started.
            </p>
          </div>
        </div>
      </div>

      {/* Join Team Form */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        {/* No Pricing Section - they're not paying */}

        {/* Signup Form */}
        <div className="max-w-md mx-auto">
          <div className="bg-white rounded-xl shadow-xl border-2 border-green-100 p-8">
            <h3 className="text-2xl font-bold text-gray-900 text-center mb-6">
              Join Team
            </h3>

            <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg">
              <div className="flex items-start space-x-3">
                <svg className="w-5 h-5 text-green-600 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <div>
                  <h4 className="text-sm font-medium text-green-900">Need a team code?</h4>
                  <p className="text-sm text-green-700 mt-1">
                    Ask your team admin for the team code. They can find it in their team settings.
                  </p>
                </div>
              </div>
            </div>

            <SignupForm onSuccess={handleSignupSuccess} isJoiningTeam={true} />

            <div className="mt-6 text-center">
              <p className="text-sm text-gray-600">
                Already have an account?{' '}
                <Link href="/login" className="font-medium text-blue-600 hover:text-blue-500">
                  Sign in here
                </Link>
              </p>
            </div>
          </div>
        </div>

        {/* Feature Highlights */}
        <div className="mt-16 grid md:grid-cols-3 gap-8">
          <div className="text-center">
            <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
            </div>
            <h4 className="text-xl font-semibold text-gray-900 mb-2">Photo Documentation</h4>
            <p className="text-gray-600">Capture incidents with GPS location, timestamps, and detailed notes</p>
          </div>

          <div className="text-center">
            <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
            </div>
            <h4 className="text-xl font-semibold text-gray-900 mb-2">Team Collaboration</h4>
            <p className="text-gray-600">Share incidents, assign tasks, and coordinate cleanup efforts</p>
          </div>

          <div className="text-center">
            <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <h4 className="text-xl font-semibold text-gray-900 mb-2">Professional Reports</h4>
            <p className="text-gray-600">Generate branded reports for clients with photos and progress tracking</p>
          </div>
        </div>

        {/* Return to app section */}
        <div className="mt-16 text-center">
          <div className="bg-green-50 border border-green-200 rounded-lg p-6 max-w-lg mx-auto">
            <h3 className="text-lg font-semibold text-gray-900 mb-3">
              All set!
            </h3>
            <p className="text-gray-600 mb-4 text-sm">
              Return to your iOS app to start tracking.
            </p>

            {/* Deep link back to app */}
            <a
              href="freshwall://login"
              className="inline-flex items-center space-x-2 bg-green-600 hover:bg-green-700 text-white font-medium py-2 px-4 rounded-lg transition-colors text-sm"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
              </svg>
              <span>Open FreshWall App</span>
            </a>
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
'use client';

import { useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { httpsCallable } from 'firebase/functions';
import { functions } from '@/lib/firebase';

interface JoinTeamFormProps {
  onSuccess?: () => void;
}

export default function JoinTeamForm({ onSuccess }: JoinTeamFormProps) {
  const { signUpWithEmail, signInWithGoogle } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [teamCode, setTeamCode] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const joinTeamCreateUser = httpsCallable(functions, 'joinTeamCreateUser');

  // Validate team code format (6-character hex code)
  const isValidTeamCode = (code: string) => {
    const cleanCode = code.trim().toUpperCase();
    return /^[0-9A-F]{6}$/.test(cleanCode);
  };

  const handleTeamCodeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.toUpperCase().trim();
    // Only allow valid hex characters and limit to 6 characters
    const filtered = value.replace(/[^0-9A-F]/g, '').slice(0, 6);
    setTeamCode(filtered);
  };

  const handleEmailSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    if (!isValidTeamCode(teamCode)) {
      setError('Team code must be exactly 6 characters (letters and numbers only)');
      setLoading(false);
      return;
    }

    try {
      // First create Firebase auth account
      const { user, error: authError } = await signUpWithEmail(email, password);

      if (authError || !user) {
        setError(authError || 'Failed to create account');
        setLoading(false);
        return;
      }

      // Then join team via Cloud Function
      const result = await joinTeamCreateUser({
        teamCode,
        displayName,
        email
      });

      console.log('Joined team:', result.data);
      onSuccess?.();

    } catch (error: any) {
      setError(error.message || 'Failed to join team');
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSignup = async () => {
    setLoading(true);
    setError('');

    if (!isValidTeamCode(teamCode)) {
      setError('Team code must be exactly 6 characters (letters and numbers only)');
      setLoading(false);
      return;
    }

    try {
      const { user, error: authError } = await signInWithGoogle();

      if (authError || !user) {
        setError(authError || 'Failed to sign in with Google');
        setLoading(false);
        return;
      }

      // Join team with Google account info
      const result = await joinTeamCreateUser({
        teamCode,
        displayName: user.displayName || user.email?.split('@')[0] || 'User',
        email: user.email || ''
      });

      console.log('Joined team with Google:', result.data);
      onSuccess?.();

    } catch (error: any) {
      setError(error.message || 'Failed to join team');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-md mx-auto bg-white p-8 rounded-lg shadow-lg">
      <h2 className="text-2xl font-bold text-center mb-6 text-gray-900">Join Your Team</h2>

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      <form onSubmit={handleEmailSignup} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Team Code
          </label>
          <input
            type="text"
            value={teamCode}
            onChange={handleTeamCodeChange}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 text-gray-900 text-center font-mono text-lg tracking-wider ${
              teamCode && isValidTeamCode(teamCode)
                ? 'border-green-300 focus:ring-green-500 bg-green-50'
                : teamCode
                ? 'border-red-300 focus:ring-red-500 bg-red-50'
                : 'border-gray-300 focus:ring-blue-500'
            }`}
            placeholder="ABC123"
            required
            maxLength={6}
          />
          <p className="text-xs text-gray-500 mt-1">
            Enter the 6-character code from your team admin
          </p>
          {teamCode && !isValidTeamCode(teamCode) && (
            <p className="text-xs text-red-600 mt-1">
              Code must be exactly 6 characters (letters and numbers only)
            </p>
          )}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Your Name
          </label>
          <input
            type="text"
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900"
            placeholder="John Doe"
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Email
          </label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900"
            placeholder="you@company.com"
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Password
          </label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900"
            placeholder="••••••••"
            required
            minLength={6}
          />
        </div>

        <button
          type="submit"
          disabled={loading || !isValidTeamCode(teamCode)}
          className="w-full bg-green-600 text-white py-2 px-4 rounded-md hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? 'Joining Team...' : 'Join Team'}
        </button>
      </form>

      <div className="mt-4">
        <div className="relative">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-gray-300" />
          </div>
          <div className="relative flex justify-center text-sm">
            <span className="px-2 bg-white text-gray-500">Or</span>
          </div>
        </div>

        <button
          onClick={handleGoogleSignup}
          disabled={loading || !isValidTeamCode(teamCode)}
          className="w-full mt-4 bg-white border border-gray-300 text-gray-700 py-2 px-4 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
        >
          <svg className="w-5 h-5 mr-2" viewBox="0 0 24 24">
            <path fill="#4285f4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34a853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="#fbbc05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
            <path fill="#ea4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
          </svg>
          Join with Google
        </button>

        {!isValidTeamCode(teamCode) && (
          <p className="text-sm text-gray-500 mt-2 text-center">
            Enter a valid team code to enable signup options
          </p>
        )}
      </div>
    </div>
  );
}
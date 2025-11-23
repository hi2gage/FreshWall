'use client';

import { useState } from 'react';
import { useAuth } from '@/hooks/useAuth';

interface LoginFormProps {
  onSuccess?: () => void;
}

export default function LoginForm({ onSuccess }: LoginFormProps) {
  const { signInWithEmail, signInWithGoogle, resetPassword } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [resetEmailSent, setResetEmailSent] = useState(false);

  const handleEmailLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const { user, error: authError } = await signInWithEmail(email, password);

      if (authError || !user) {
        setError(authError || 'Failed to sign in');
        setLoading(false);
        return;
      }

      onSuccess?.();

    } catch (error: any) {
      setError(error.message || 'Failed to sign in');
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLogin = async () => {
    setLoading(true);
    setError('');

    try {
      const { user, error: authError } = await signInWithGoogle();

      if (authError || !user) {
        setError(authError || 'Failed to sign in with Google');
        setLoading(false);
        return;
      }

      onSuccess?.();

    } catch (error: any) {
      setError(error.message || 'Failed to sign in with Google');
    } finally {
      setLoading(false);
    }
  };

  const handleResetPassword = async () => {
    if (!email.trim()) {
      setError('Please enter your email address first');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const { error: resetError } = await resetPassword(email);

      if (resetError) {
        setError(resetError);
      } else {
        setResetEmailSent(true);
      }
    } catch (error: any) {
      setError(error.message || 'Failed to send reset email');
    } finally {
      setLoading(false);
    }
  };

  if (resetEmailSent) {
    return (
      <div className="max-w-md mx-auto bg-white p-8 rounded-xl shadow-lg text-center">
        <div className="text-5xl mb-6">📧</div>
        <h2 className="text-h3 font-montserrat font-semibold text-copy-black mb-4">Check Your Email</h2>
        <p className="text-body text-gray-600 mb-8">
          We've sent a password reset link to <strong className="text-charcoal-navy">{email}</strong>
        </p>
        <button
          onClick={() => setResetEmailSent(false)}
          className="text-freshwall-orange hover:text-freshwall-orange/80 font-medium transition-colors text-body"
        >
          ← Back to Sign In
        </button>
      </div>
    );
  }

  return (
    <div className="max-w-md mx-auto bg-white p-8 rounded-xl shadow-lg">
      <h2 className="text-h3 font-montserrat font-semibold text-center mb-8 text-copy-black">Welcome Back</h2>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6 text-body-sm">
          {error}
        </div>
      )}

      <form onSubmit={handleEmailLogin} className="space-y-5">
        <div>
          <label className="block text-body-sm font-medium text-charcoal-navy mb-2">
            Email
          </label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-freshwall-orange focus:border-transparent text-copy-black transition-shadow"
            placeholder="you@company.com"
            required
          />
        </div>

        <div>
          <label className="block text-body-sm font-medium text-charcoal-navy mb-2">
            Password
          </label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-freshwall-orange focus:border-transparent text-copy-black transition-shadow"
            placeholder="••••••••"
            required
          />
        </div>

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-freshwall-orange text-white py-3 px-4 rounded-lg font-medium hover:bg-freshwall-orange/90 disabled:opacity-50 disabled:cursor-not-allowed transition-colors text-body"
        >
          {loading ? 'Signing In...' : 'Sign In'}
        </button>
      </form>

      <div className="mt-6">
        <div className="relative">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-gray-200" />
          </div>
          <div className="relative flex justify-center text-body-sm">
            <span className="px-3 bg-white text-gray-500">Or continue with</span>
          </div>
        </div>

        <button
          onClick={handleGoogleLogin}
          disabled={loading}
          className="w-full mt-6 bg-white border border-gray-300 text-charcoal-navy py-3 px-4 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center transition-colors text-body font-medium"
        >
          <svg className="w-5 h-5 mr-2" viewBox="0 0 24 24">
            <path fill="#4285f4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34a853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="#fbbc05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
            <path fill="#ea4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
          </svg>
          Google
        </button>
      </div>

      <div className="mt-6 text-center">
        <button
          onClick={handleResetPassword}
          disabled={loading}
          className="text-body-sm text-charcoal-navy hover:text-freshwall-orange disabled:opacity-50 transition-colors font-medium"
        >
          Forgot your password?
        </button>
      </div>
    </div>
  );
}
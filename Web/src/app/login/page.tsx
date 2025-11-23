'use client';

import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';
import LoginForm from '@/components/auth/LoginForm';
import Link from 'next/link';
import Image from 'next/image';

export default function LoginPage() {
  const router = useRouter();
  const { user, loading } = useAuth();

  // Redirect if already logged in
  if (user && !loading) {
    router.push('/dashboard');
    return null;
  }

  const handleLoginSuccess = () => {
    router.push('/dashboard');
  };

  return (
    <div className="min-h-screen bg-neutral-tone flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <Link href="/" className="flex justify-center group">
          <Image
            src="/freshwall-logo.svg"
            alt="FreshWall"
            width={200}
            height={90}
            className="group-hover:scale-105 transition-transform"
            priority
          />
        </Link>
        <h2 className="mt-8 text-center text-h2 font-montserrat font-semibold text-copy-black">
          Sign in to your account
        </h2>
        <p className="mt-3 text-center text-body text-gray-600">
          Access your team's incident tracking dashboard
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <LoginForm onSuccess={handleLoginSuccess} />

        <div className="mt-6 text-center">
          <p className="text-body-sm text-gray-600">
            Don't have an account?{' '}
            <Link href="/signup" className="font-medium text-freshwall-orange hover:text-freshwall-orange/80 transition-colors">
              Sign up for free
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
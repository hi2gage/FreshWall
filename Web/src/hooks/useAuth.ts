import { useAuthState } from 'react-firebase-hooks/auth';
import { auth } from '@/lib/firebase';
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signInWithPopup,
  signOut,
  sendPasswordResetEmail
} from 'firebase/auth';
import { googleProvider } from '@/lib/firebase';
import { getAuthErrorDetails, type AuthErrorDetails } from '@/lib/authErrors';

export function useAuth() {
  const [user, loading, error] = useAuthState(auth);

  const signInWithEmail = async (email: string, password: string) => {
    try {
      const result = await signInWithEmailAndPassword(auth, email, password);
      return { user: result.user, error: null, errorDetails: null };
    } catch (error: any) {
      const errorDetails = getAuthErrorDetails(error);
      return { user: null, error: errorDetails.message, errorDetails };
    }
  };

  const signUpWithEmail = async (email: string, password: string) => {
    try {
      const result = await createUserWithEmailAndPassword(auth, email, password);
      return { user: result.user, error: null, errorDetails: null };
    } catch (error: any) {
      const errorDetails = getAuthErrorDetails(error);
      return { user: null, error: errorDetails.message, errorDetails };
    }
  };

  const signInWithGoogle = async () => {
    try {
      const result = await signInWithPopup(auth, googleProvider);
      return { user: result.user, error: null, errorDetails: null };
    } catch (error: any) {
      const errorDetails = getAuthErrorDetails(error);
      return { user: null, error: errorDetails.message, errorDetails };
    }
  };

  const logout = async () => {
    try {
      await signOut(auth);
      return { error: null };
    } catch (error: any) {
      return { error: error.message };
    }
  };

  const resetPassword = async (email: string) => {
    try {
      await sendPasswordResetEmail(auth, email);
      return { error: null };
    } catch (error: any) {
      const errorDetails = getAuthErrorDetails(error);
      return { error: errorDetails.message };
    }
  };

  return {
    user,
    loading,
    error,
    signInWithEmail,
    signUpWithEmail,
    signInWithGoogle,
    logout,
    resetPassword
  };
}
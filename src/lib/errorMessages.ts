/**
 * Maps Firebase authentication error codes to user-friendly messages
 */

export interface AuthErrorResult {
  message: string;
  suggestDemo: boolean;
}

/**
 * Translates Firebase auth error codes into user-friendly messages
 * @param error - The error object from Firebase
 * @returns Object with user-friendly message and demo suggestion flag
 */
export function getAuthErrorMessage(error: any): AuthErrorResult {
  const errorCode = error?.code || '';
  const errorMessage = error?.message || '';

  // Extract Firebase error code from various formats
  const code = errorCode || extractErrorCode(errorMessage);

  switch (code) {
    case 'auth/invalid-credential':
    case 'auth/user-not-found':
    case 'auth/wrong-password':
      return {
        message: "We couldn't find an account with those credentials. Would you like to try our demo?",
        suggestDemo: true,
      };

    case 'auth/invalid-email':
      return {
        message: 'Please enter a valid email address.',
        suggestDemo: false,
      };

    case 'auth/user-disabled':
      return {
        message: 'This account has been disabled. Please contact support.',
        suggestDemo: false,
      };

    case 'auth/too-many-requests':
      return {
        message: 'Too many failed login attempts. Please try again later or reset your password.',
        suggestDemo: false,
      };

    case 'auth/email-already-in-use':
      return {
        message: 'An account with this email already exists. Please sign in instead.',
        suggestDemo: false,
      };

    case 'auth/weak-password':
      return {
        message: 'Password should be at least 6 characters.',
        suggestDemo: false,
      };

    case 'auth/operation-not-allowed':
      return {
        message: 'This sign-in method is not enabled. Please contact support.',
        suggestDemo: false,
      };

    case 'auth/popup-closed-by-user':
      return {
        message: 'Sign-in was cancelled. Please try again.',
        suggestDemo: false,
      };

    case 'auth/cancelled-popup-request':
      return {
        message: 'Only one sign-in window can be open at a time.',
        suggestDemo: false,
      };

    case 'auth/network-request-failed':
      return {
        message: 'Network error. Please check your connection and try again.',
        suggestDemo: false,
      };

    case 'auth/requires-recent-login':
      return {
        message: 'Please sign in again to continue.',
        suggestDemo: false,
      };

    case 'auth/invalid-action-code':
      return {
        message: 'This link is invalid or has expired. Please request a new one.',
        suggestDemo: false,
      };

    default:
      // For unknown errors, don't expose technical details but suggest demo
      return {
        message: 'Something went wrong. Please try again or explore our demo.',
        suggestDemo: true,
      };
  }
}

/**
 * Extracts error code from Firebase error message strings
 * Handles formats like "Firebase: Error (auth/invalid-credential)"
 */
function extractErrorCode(message: string): string {
  const match = message.match(/\(([^)]+)\)/);
  return match ? match[1] : '';
}

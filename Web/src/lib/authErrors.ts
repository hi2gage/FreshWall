/**
 * User-friendly error messages for Firebase Auth errors
 * Maps Firebase error codes to helpful, actionable messages
 */

export interface AuthErrorDetails {
  title: string;
  message: string;
  suggestion?: string;
  showDemoLink?: boolean;
}

/**
 * Get user-friendly error details from Firebase Auth error
 */
export function getAuthErrorDetails(error: any): AuthErrorDetails {
  const errorCode = error?.code || '';
  const errorMessage = error?.message || 'An unexpected error occurred';

  // Map Firebase error codes to user-friendly messages
  switch (errorCode) {
    // Email/Password errors
    case 'auth/invalid-email':
      return {
        title: 'Invalid Email',
        message: 'Please enter a valid email address',
        suggestion: 'Make sure your email is in the correct format (e.g., you@company.com)'
      };

    case 'auth/user-not-found':
      return {
        title: 'Account Not Found',
        message: 'No account exists with this email address',
        suggestion: 'Check your email or contact your team lead to get invited',
        showDemoLink: true
      };

    case 'auth/wrong-password':
      return {
        title: 'Incorrect Password',
        message: 'The password you entered is incorrect',
        suggestion: 'Try again or click "Forgot your password?" to reset it'
      };

    case 'auth/weak-password':
      return {
        title: 'Weak Password',
        message: 'Password must be at least 6 characters long',
        suggestion: 'Choose a stronger password with a mix of letters, numbers, and symbols'
      };

    case 'auth/email-already-in-use':
      return {
        title: 'Email Already Registered',
        message: 'An account with this email already exists',
        suggestion: 'Try signing in instead, or use "Forgot your password?" if needed'
      };

    // Account status errors
    case 'auth/user-disabled':
      return {
        title: 'Account Disabled',
        message: 'This account has been disabled',
        suggestion: 'Please contact FreshWall support for assistance'
      };

    case 'auth/account-exists-with-different-credential':
      return {
        title: 'Account Exists',
        message: 'An account with this email already exists using a different sign-in method',
        suggestion: 'Try signing in with your email and password instead'
      };

    // Rate limiting
    case 'auth/too-many-requests':
      return {
        title: 'Too Many Attempts',
        message: 'Access temporarily blocked due to too many failed login attempts',
        suggestion: 'Wait a few minutes and try again, or reset your password'
      };

    // Network errors
    case 'auth/network-request-failed':
      return {
        title: 'Connection Error',
        message: 'Unable to connect to the authentication service',
        suggestion: 'Check your internet connection and try again'
      };

    // Google Sign-In errors
    case 'auth/popup-closed-by-user':
      return {
        title: 'Sign-In Cancelled',
        message: 'The Google sign-in popup was closed before completing',
        suggestion: 'Please try signing in with Google again'
      };

    case 'auth/popup-blocked':
      return {
        title: 'Popup Blocked',
        message: 'Your browser blocked the sign-in popup',
        suggestion: 'Please allow popups for this site and try again'
      };

    case 'auth/cancelled-popup-request':
      return {
        title: 'Sign-In Cancelled',
        message: 'Sign-in was cancelled',
        suggestion: 'Please try again when ready'
      };

    // Invalid credentials
    case 'auth/invalid-credential':
      return {
        title: 'Login Failed',
        message: 'Incorrect email or password',
        suggestion: 'Please check your credentials and try again',
        showDemoLink: true
      };

    // Operation not allowed
    case 'auth/operation-not-allowed':
      return {
        title: 'Sign-In Method Disabled',
        message: 'This sign-in method is not enabled',
        suggestion: 'Please contact FreshWall support'
      };

    // Session errors
    case 'auth/requires-recent-login':
      return {
        title: 'Session Expired',
        message: 'Please sign in again to continue',
        suggestion: 'For security, you need to sign in again'
      };

    // Generic password reset errors
    case 'auth/invalid-action-code':
      return {
        title: 'Invalid Reset Link',
        message: 'This password reset link is invalid or has expired',
        suggestion: 'Request a new password reset email'
      };

    case 'auth/expired-action-code':
      return {
        title: 'Link Expired',
        message: 'This password reset link has expired',
        suggestion: 'Request a new password reset email'
      };

    // Missing email error
    case 'auth/missing-email':
      return {
        title: 'Email Required',
        message: 'Please enter your email address',
        suggestion: 'An email address is required to sign in'
      };

    // Default fallback
    default:
      // Check if error message contains specific keywords for better UX
      const lowerMessage = errorMessage.toLowerCase();

      if (lowerMessage.includes('network') || lowerMessage.includes('connection')) {
        return {
          title: 'Connection Error',
          message: 'Unable to connect to FreshWall',
          suggestion: 'Check your internet connection and try again'
        };
      }

      if (lowerMessage.includes('not found') || lowerMessage.includes('no user')) {
        return {
          title: 'Account Not Found',
          message: 'No FreshWall account found with these credentials',
          suggestion: 'Contact your team lead to get invited',
          showDemoLink: true
        };
      }

      return {
        title: 'Sign-In Error',
        message: errorMessage,
        suggestion: 'Please try again or contact support if the problem persists'
      };
  }
}

/**
 * Get a short, user-friendly error message (for inline display)
 */
export function getShortErrorMessage(error: any): string {
  const details = getAuthErrorDetails(error);
  return details.message;
}

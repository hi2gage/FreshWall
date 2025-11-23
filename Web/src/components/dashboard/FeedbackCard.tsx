'use client';

import { useState } from 'react';

export default function FeedbackCard() {
  const [feedback, setFeedback] = useState('');
  const [loading, setLoading] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!feedback.trim()) {
      return;
    }

    setLoading(true);

    // TODO: Implement feedback submission (could be a Cloud Function, email service, etc.)
    console.log('Submitting feedback:', { feedback });

    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));

    setLoading(false);
    setSubmitted(true);

    // Reset form after 3 seconds
    setTimeout(() => {
      setFeedback('');
      setSubmitted(false);
    }, 3000);
  };

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="mb-4">
        <h3 className="text-lg font-semibold text-gray-900">
          Share Your Feedback
        </h3>
        <p className="text-sm text-gray-600 mt-1">
          Help us improve FreshWall! Your feedback matters.
        </p>
      </div>

      {submitted ? (
        <div className="py-8 text-center">
          <div className="text-4xl mb-3">✅</div>
          <h4 className="text-lg font-semibold text-gray-900 mb-2">
            Thank you!
          </h4>
          <p className="text-sm text-gray-600">
            We appreciate your feedback and will review it soon.
          </p>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Feedback textarea */}
          <div>
            <label htmlFor="feedback" className="block text-sm font-medium text-gray-900 mb-2">
              What would you like to share?
            </label>
            <textarea
              id="feedback"
              value={feedback}
              onChange={(e) => setFeedback(e.target.value)}
              rows={6}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-seafoam-teal focus:border-seafoam-teal bg-white text-gray-900 resize-none"
              placeholder="Bug reports, feature requests, or general feedback..."
              required
            />
            <p className="text-xs text-gray-500 mt-1">
              {feedback.length}/500 characters
            </p>
          </div>

          {/* Submit button */}
          <button
            type="submit"
            disabled={loading || !feedback.trim()}
            className="w-full bg-seafoam-teal text-white py-2 px-4 rounded-md hover:bg-seafoam-teal/90 disabled:opacity-50 disabled:cursor-not-allowed font-medium transition-colors"
          >
            {loading ? 'Sending...' : 'Submit Feedback'}
          </button>
        </form>
      )}

      {/* Quick feedback options */}
      {!submitted && (
        <div className="mt-6 pt-6 border-t border-gray-200">
          <p className="text-xs text-gray-500 mb-3">
            Quick actions:
          </p>
          <div className="flex flex-wrap gap-2">
            <button
              type="button"
              onClick={() => setFeedback('I found a bug: ')}
              className="text-xs px-3 py-1 border border-gray-300 rounded-full hover:border-seafoam-teal text-gray-700 hover:text-seafoam-teal transition-colors"
            >
              🐛 Report Bug
            </button>
            <button
              type="button"
              onClick={() => setFeedback('Feature request: ')}
              className="text-xs px-3 py-1 border border-gray-300 rounded-full hover:border-seafoam-teal text-gray-700 hover:text-seafoam-teal transition-colors"
            >
              💡 Suggest Feature
            </button>
            <button
              type="button"
              onClick={() => setFeedback('I love FreshWall! ')}
              className="text-xs px-3 py-1 border border-gray-300 rounded-full hover:border-seafoam-teal text-gray-700 hover:text-seafoam-teal transition-colors"
            >
              ❤️ General Praise
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

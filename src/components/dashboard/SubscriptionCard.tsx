'use client';

import { useState } from 'react';

interface SubscriptionCardProps {
  currentPlan: 'free' | 'pro' | 'enterprise';
  usageStats: {
    incidents: { used: number; limit: number };
    teamMembers: { used: number; limit: number };
  };
}

export default function SubscriptionCard({ currentPlan, usageStats }: SubscriptionCardProps) {
  const [loading, setLoading] = useState(false);

  const handleUpgrade = async () => {
    setLoading(true);
    // Will implement Stripe checkout here
    console.log('Redirecting to Stripe checkout...');
    setLoading(false);
  };

  const plans = {
    free: {
      name: 'Free',
      price: '$0',
      features: ['5 incidents per month', '1 team member', 'Basic reporting']
    },
    pro: {
      name: 'Pro',
      price: '$29',
      features: ['Unlimited incidents', 'Up to 10 team members', 'Advanced reporting', 'Photo thumbnails', 'Data export']
    },
    enterprise: {
      name: 'Enterprise',
      price: 'Custom',
      features: ['Unlimited everything', 'Unlimited team members', 'Priority support', 'Custom integrations']
    }
  };

  const currentPlanData = plans[currentPlan];
  const isAtLimit = usageStats.incidents.used >= usageStats.incidents.limit;

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">
            Current Plan: {currentPlanData.name}
          </h3>
          <p className="text-2xl font-bold text-blue-600">
            {currentPlanData.price}{currentPlan !== 'free' && '/month'}
          </p>
        </div>
        {currentPlan === 'free' && (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
            Free Trial
          </span>
        )}
      </div>

      {/* Usage Meters */}
      <div className="space-y-4 mb-6">
        <div>
          <div className="flex justify-between text-sm text-gray-600 mb-1">
            <span>Incidents this month</span>
            <span>{usageStats.incidents.used} / {usageStats.incidents.limit}</span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className={`h-2 rounded-full ${isAtLimit ? 'bg-red-500' : 'bg-blue-500'}`}
              style={{ width: `${Math.min((usageStats.incidents.used / usageStats.incidents.limit) * 100, 100)}%` }}
            ></div>
          </div>
          {isAtLimit && (
            <p className="text-red-600 text-sm mt-1">
              ⚠️ You've reached your incident limit. Upgrade to continue tracking.
            </p>
          )}
        </div>

        <div>
          <div className="flex justify-between text-sm text-gray-600 mb-1">
            <span>Team members</span>
            <span>{usageStats.teamMembers.used} / {usageStats.teamMembers.limit}</span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className="bg-green-500 h-2 rounded-full"
              style={{ width: `${Math.min((usageStats.teamMembers.used / usageStats.teamMembers.limit) * 100, 100)}%` }}
            ></div>
          </div>
        </div>
      </div>

      {/* Current Plan Features */}
      <div className="mb-6">
        <h4 className="text-sm font-medium text-gray-900 mb-2">What's included:</h4>
        <ul className="text-sm text-gray-600 space-y-1">
          {currentPlanData.features.map((feature, index) => (
            <li key={index} className="flex items-center">
              <span className="text-green-500 mr-2">✓</span>
              {feature}
            </li>
          ))}
        </ul>
      </div>

      {/* Upgrade Button */}
      {currentPlan === 'free' && (
        <div>
          <button
            onClick={handleUpgrade}
            disabled={loading}
            className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50 font-medium"
          >
            {loading ? 'Processing...' : 'Upgrade to Pro - $29/month'}
          </button>
          <p className="text-xs text-gray-500 mt-2 text-center">
            Cancel anytime. 14-day money-back guarantee.
          </p>
        </div>
      )}

      {currentPlan === 'pro' && (
        <div className="text-center">
          <p className="text-sm text-gray-600 mb-2">
            Need more team members or custom features?
          </p>
          <button className="text-blue-600 hover:text-blue-700 text-sm font-medium">
            Contact Sales for Enterprise
          </button>
        </div>
      )}
    </div>
  );
}
'use client';

import { useAuth } from '@/hooks/useAuth';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import SubscriptionCard from '@/components/dashboard/SubscriptionCard';
import IncidentsTab from '@/components/dashboard/IncidentsTab';
import ClientsTab from '@/components/dashboard/ClientsTab';

export default function Dashboard() {
  const { user, loading, logout } = useAuth();
  const router = useRouter();
  const [activeTab, setActiveTab] = useState<'overview' | 'incidents' | 'clients' | 'team' | 'billing'>('overview');

  useEffect(() => {
    if (!loading && !user) {
      router.push('/login');
    }
  }, [user, loading, router]);

  const handleLogout = async () => {
    await logout();
    router.push('/');
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return null; // Will redirect to login
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-full mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-blue-600">FreshWall</h1>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-gray-700">Welcome, {user.displayName || user.email}</span>
              <button
                onClick={handleLogout}
                className="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-md text-sm"
              >
                Sign Out
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-full mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          {/* Tab Navigation */}
          <div className="border-b border-gray-200 mb-6">
            <nav className="-mb-px flex space-x-8">
              {[
                { id: 'overview', name: 'Overview', icon: '🏠' },
                { id: 'incidents', name: 'Incidents', icon: '📋' },
                { id: 'clients', name: 'Clients', icon: '👤' },
                { id: 'team', name: 'Team', icon: '👥' },
                { id: 'billing', name: 'Billing', icon: '💳' }
              ].map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id as any)}
                  className={`flex items-center py-2 px-1 border-b-2 font-medium text-sm ${
                    activeTab === tab.id
                      ? 'border-blue-500 text-blue-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  <span className="mr-2">{tab.icon}</span>
                  {tab.name}
                </button>
              ))}
            </nav>
          </div>

          {/* Tab Content */}
          <div className="min-h-[500px]">
            {activeTab === 'overview' && (
              <div className="space-y-6">
                <div className="grid lg:grid-cols-3 gap-6">
                  {/* Subscription Card */}
                  <div className="lg:col-span-1">
                    <SubscriptionCard
                      currentPlan="free"
                      usageStats={{
                        incidents: { used: 0, limit: 5 },
                        teamMembers: { used: 1, limit: 1 }
                      }}
                    />
                  </div>

                  {/* Quick Actions */}
                  <div className="lg:col-span-2 bg-white rounded-lg shadow p-6">
                    <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
                    <div className="grid md:grid-cols-2 gap-4">
                      <button className="p-4 border border-gray-200 rounded-lg hover:border-blue-300 text-left">
                        <div className="text-2xl mb-2">📱</div>
                        <h4 className="font-medium text-gray-900">Download Mobile App</h4>
                        <p className="text-sm text-gray-600">Start tracking incidents on the go</p>
                      </button>

                      <button
                        onClick={() => setActiveTab('team')}
                        className="p-4 border border-gray-200 rounded-lg hover:border-blue-300 text-left"
                      >
                        <div className="text-2xl mb-2">👥</div>
                        <h4 className="font-medium text-gray-900">Invite Team Members</h4>
                        <p className="text-sm text-gray-600">Collaborate with your team</p>
                      </button>
                    </div>
                  </div>
                </div>

                <div className="bg-blue-50 rounded-lg p-8 text-center">
                  <h2 className="text-2xl font-bold text-gray-900 mb-4">
                    🎉 Welcome to FreshWall!
                  </h2>
                  <p className="text-gray-600 mb-6">
                    Your team has been created. Download the mobile app to start tracking incidents.
                  </p>
                  <button
                    onClick={() => setActiveTab('incidents')}
                    className="bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700 mr-4"
                  >
                    View Incidents
                  </button>
                  <button
                    onClick={() => setActiveTab('billing')}
                    className="bg-green-600 text-white px-6 py-2 rounded-md hover:bg-green-700"
                  >
                    Upgrade Plan
                  </button>
                </div>
              </div>
            )}

            {activeTab === 'incidents' && <IncidentsTab />}

            {activeTab === 'clients' && <ClientsTab />}

            {activeTab === 'team' && (
              <div className="bg-white rounded-lg shadow p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Team Management</h3>
                <p className="text-gray-600 mb-6">Invite team members to collaborate on incident tracking.</p>
                <div className="text-center py-12">
                  <div className="text-4xl mb-4">👥</div>
                  <h4 className="text-lg font-semibold text-gray-900 mb-2">Team Features Coming Soon</h4>
                  <p className="text-gray-600">Invite members, manage roles, and collaborate effectively.</p>
                </div>
              </div>
            )}

            {activeTab === 'billing' && (
              <div className="bg-white rounded-lg shadow p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Billing & Subscription</h3>
                <div className="grid lg:grid-cols-2 gap-6">
                  <SubscriptionCard
                    currentPlan="free"
                    usageStats={{
                      incidents: { used: 0, limit: 5 },
                      teamMembers: { used: 1, limit: 1 }
                    }}
                  />
                  <div className="space-y-4">
                    <h4 className="font-semibold text-gray-900">Upgrade Benefits</h4>
                    <ul className="space-y-2 text-sm text-gray-600">
                      <li className="flex items-center">
                        <span className="text-green-500 mr-2">✓</span>
                        Unlimited incident tracking
                      </li>
                      <li className="flex items-center">
                        <span className="text-green-500 mr-2">✓</span>
                        Up to 10 team members
                      </li>
                      <li className="flex items-center">
                        <span className="text-green-500 mr-2">✓</span>
                        Advanced reporting and analytics
                      </li>
                      <li className="flex items-center">
                        <span className="text-green-500 mr-2">✓</span>
                        Photo thumbnails for faster loading
                      </li>
                      <li className="flex items-center">
                        <span className="text-green-500 mr-2">✓</span>
                        Data export capabilities
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
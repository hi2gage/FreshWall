'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { firestore } from '@/lib/firebase';
import { collection, query, orderBy, onSnapshot, doc, getDoc, getDocs } from 'firebase/firestore';
import ClientViewModal from './ClientViewModal';

// Based on iOS ClientDTO structure
interface Client {
  id: string;
  name: string;
  notes?: string;
  isDeleted: boolean;
  deletedAt?: any;
  createdAt: any;
  lastIncidentAt?: any;
  defaults?: {
    billingMethod: 'time' | 'square_footage' | 'custom';
    minimumBillableQuantity: number;
    amountPerUnit: number;
    timeRounding?: {
      roundingIncrement: number;
    };
    customUnitDescription?: string;
  };
}

export default function ClientsTab() {
  const { user } = useAuth();
  const [clients, setClients] = useState<Client[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'active' | 'deleted'>('active');
  const [selectedClient, setSelectedClient] = useState<Client | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [canViewBilling, setCanViewBilling] = useState(false);

  const handleViewClient = (client: Client) => {
    setSelectedClient(client);
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setSelectedClient(null);
  };

  useEffect(() => {
    if (!user) return;

    const fetchClients = async () => {
      try {
        setLoading(true);

        // Get teamId and role from custom claims or search teams
        let idTokenResult = await user.getIdTokenResult();
        let teamId = idTokenResult.claims?.teamId;
        let role = idTokenResult.claims?.role;

        // If no teamId in claims, try refreshing the token
        if (!teamId) {
          console.log('No teamId in claims, refreshing token...');
          idTokenResult = await user.getIdTokenResult(true);
          teamId = idTokenResult.claims?.teamId;
          role = idTokenResult.claims?.role;
        }

        // If still no team in claims, search teams collection directly
        if (!teamId) {
          console.log('Still no teamId in claims after refresh, searching teams for user...');

          const teamsSnapshot = await getDocs(collection(firestore, 'teams'));
          for (const teamDoc of teamsSnapshot.docs) {
            const userDoc = await getDoc(doc(firestore, `teams/${teamDoc.id}/users/${user.uid}`));
            if (userDoc.exists()) {
              teamId = teamDoc.id;
              role = userDoc.data()?.role;
              console.log('Found user in team:', teamId, 'with role:', role);
              break;
            }
          }

          if (!teamId) {
            console.log('User not found in any team');
            setClients([]);
            setLoading(false);
            return;
          }
        }

        // Set billing access based on role
        setCanViewBilling(role === 'admin' || role === 'manager');

        console.log('Fetching clients for team:', teamId);

        // Listen to clients for this team
        const clientsRef = collection(firestore, `teams/${teamId}/clients`);
        const q = query(clientsRef, orderBy('name', 'asc'));

        const unsubscribe = onSnapshot(q, async (snapshot) => {
          const clientsData = snapshot.docs.map((docSnapshot) => {
            const clientData = docSnapshot.data();
            return {
              id: docSnapshot.id,
              ...clientData,
            } as Client;
          });

          setClients(clientsData);
          setLoading(false);
        });

        return unsubscribe;
      } catch (error) {
        console.error('Error fetching clients:', error);
        setClients([]);
        setLoading(false);
      }
    };

    fetchClients();
  }, [user]);

  const filteredClients = clients.filter(client => {
    if (filter === 'all') return true;
    if (filter === 'active') return !client.isDeleted;
    if (filter === 'deleted') return client.isDeleted;
    return true;
  });

  const formatDate = (timestamp: any) => {
    if (!timestamp) return 'Unknown';

    try {
      const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    } catch (error) {
      return 'Unknown';
    }
  };

  const getBillingMethodLabel = (method: string) => {
    switch (method) {
      case 'time': return 'Time';
      case 'square_footage': return 'Square Footage';
      case 'custom': return 'Custom';
      default: return method;
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        <span className="ml-2 text-gray-600">Loading clients...</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header with filters */}
      <div className="flex justify-between items-center">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">Clients</h3>
          <p className="text-sm text-gray-600">Manage your client accounts and billing settings</p>
        </div>

        <div className="flex space-x-2">
          {(['active', 'all', 'deleted'] as const).map((status) => (
            <button
              key={status}
              onClick={() => setFilter(status)}
              className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                filter === status
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
              }`}
            >
              {status === 'active' ? 'Active' :
               status === 'all' ? 'All' :
               'Deleted'}
            </button>
          ))}
        </div>
      </div>

      {/* Clients List */}
      {filteredClients.length === 0 ? (
        <div className="text-center py-12 bg-gray-50 rounded-lg">
          <div className="text-4xl mb-4">👥</div>
          <h3 className="text-lg font-semibold text-gray-900 mb-2">
            No clients yet
          </h3>
          <p className="text-gray-600 mb-6">
            Start by adding your first client to track incidents and generate reports.
          </p>
          <button className="bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700">
            Add First Client
          </button>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Client Name
                  </th>
                  {canViewBilling && (
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Billing Method
                    </th>
                  )}
                  {canViewBilling && (
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Rate
                    </th>
                  )}
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Last Incident
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredClients.map((client) => (
                  <tr
                    key={client.id}
                    className="hover:bg-gray-50 cursor-pointer"
                    onClick={() => handleViewClient(client)}
                  >
                    <td className="px-6 py-4">
                      <div className="max-w-xs">
                        <div className="text-sm font-medium text-gray-900 truncate">
                          {client.name}
                        </div>
                        {client.notes && (
                          <div className="text-xs text-gray-500 mt-1 truncate">
                            {client.notes}
                          </div>
                        )}
                      </div>
                    </td>
                    {canViewBilling && (
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {client.defaults?.billingMethod
                          ? getBillingMethodLabel(client.defaults.billingMethod)
                          : 'Not configured'
                        }
                      </td>
                    )}
                    {canViewBilling && (
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {client.defaults?.amountPerUnit
                          ? `$${client.defaults.amountPerUnit.toFixed(2)}`
                          : 'Not set'
                        }
                      </td>
                    )}
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {client.lastIncidentAt ? formatDate(client.lastIncidentAt) : 'Never'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        client.isDeleted
                          ? 'bg-red-100 text-red-800'
                          : 'bg-green-100 text-green-800'
                      }`}>
                        {client.isDeleted ? 'Deleted' : 'Active'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleViewClient(client);
                        }}
                        className="text-blue-600 hover:text-blue-700 mr-3"
                      >
                        View
                      </button>
                      <button
                        onClick={(e) => e.stopPropagation()}
                        className="text-gray-600 hover:text-gray-700"
                      >
                        Edit
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Summary Stats */}
      {clients.length > 0 && (
        <div className={`grid grid-cols-1 ${canViewBilling ? 'md:grid-cols-3' : 'md:grid-cols-2'} gap-4`}>
          <div className="bg-white p-4 rounded-lg shadow">
            <div className="text-2xl font-bold text-gray-900">{clients.filter(c => !c.isDeleted).length}</div>
            <div className="text-sm text-gray-600">Active Clients</div>
          </div>
          {canViewBilling && (
            <div className="bg-white p-4 rounded-lg shadow">
              <div className="text-2xl font-bold text-blue-600">
                {clients.filter(c => c.defaults?.billingMethod).length}
              </div>
              <div className="text-sm text-gray-600">With Billing Setup</div>
            </div>
          )}
          <div className="bg-white p-4 rounded-lg shadow">
            <div className="text-2xl font-bold text-green-600">
              {clients.filter(c => c.lastIncidentAt).length}
            </div>
            <div className="text-sm text-gray-600">With Incidents</div>
          </div>
        </div>
      )}

      {/* View Modal */}
      <ClientViewModal
        client={selectedClient}
        isOpen={isModalOpen}
        onClose={handleCloseModal}
      />
    </div>
  );
}
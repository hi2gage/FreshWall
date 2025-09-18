'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { firestore } from '@/lib/firebase';
import { collection, query, orderBy, onSnapshot, where, doc, getDoc, getDocs } from 'firebase/firestore';
import IncidentViewModal from './IncidentViewModal';

// Based on actual IncidentDTO structure
interface Incident {
  id: string;
  clientRef?: string; // DocumentReference path
  clientName?: string; // Resolved client name for display
  clientDefaults?: {
    billingMethod: 'time' | 'square_footage' | 'custom';
    minimumBillableQuantity: number;
    amountPerUnit: number;
    timeRounding?: {
      roundingIncrement: number;
    };
    customUnitDescription?: string;
  };
  description: string;
  area: number;
  createdAt: any;
  startTime: any;
  endTime: any;
  beforePhotos: IncidentPhoto[];
  afterPhotos: IncidentPhoto[];
  createdBy: string; // DocumentReference path
  lastModifiedBy?: string;
  lastModifiedAt?: any;
  rate?: number;
  materialsUsed?: string;
  status?: 'open' | 'in_progress' | 'completed' | 'cancelled';
  // Enhanced metadata
  enhancedLocation?: {
    coordinates: {
      latitude: number;
      longitude: number;
    };
    address?: string;
  };
  surfaceType?: string;
  enhancedNotes?: {
    preWorkNotes?: string;
    workNotes?: string;
    postWorkNotes?: string;
  };
  customSurfaceDescription?: string;
  billing?: {
    billingMethod: 'time' | 'square_footage' | 'custom';
    minimumBillableQuantity: number;
    amountPerUnit: number;
    billingSource: 'client' | 'manual';
    wasOverridden: boolean;
    customUnitDescription?: string;
  };
}

interface IncidentPhoto {
  id: string;
  url: string;
  thumbnailUrl?: string;
  captureDate?: any;
  location?: {
    latitude: number;
    longitude: number;
  };
}

export default function IncidentsTab() {
  const { user } = useAuth();
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'open' | 'in_progress' | 'completed'>('all');
  const [selectedIncident, setSelectedIncident] = useState<Incident | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [canViewBilling, setCanViewBilling] = useState(false);

  const handleViewIncident = (incident: Incident) => {
    setSelectedIncident(incident);
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setSelectedIncident(null);
  };

  useEffect(() => {
    if (!user) return;

    const fetchIncidents = async () => {
      try {
        setLoading(true);

        // First, we need to determine the user's team
        // For now, let's try a few approaches to find the team

        // Approach 1: Check if team info is in user's custom claims
        let idTokenResult = await user.getIdTokenResult();
        let teamId = idTokenResult.claims?.teamId;
        let role = idTokenResult.claims?.role;

        // If no teamId in claims, try refreshing the token (in case claims were just set)
        if (!teamId) {
          console.log('No teamId in claims, refreshing token...');
          idTokenResult = await user.getIdTokenResult(true); // Force refresh
          teamId = idTokenResult.claims?.teamId;
          role = idTokenResult.claims?.role;
        }

        console.log('Token claims:', idTokenResult.claims);

        // Approach 2: If still no team in claims, search teams collection directly
        if (!teamId) {
          console.log('Still no teamId in claims after refresh, searching teams for user...');

          // Search all teams to find which one this user belongs to
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
            setIncidents([]);
            setLoading(false);
            return;
          }
        }

        // Set billing access based on role
        setCanViewBilling(role === 'admin' || role === 'manager');

        console.log('Fetching incidents for team:', teamId);

        // Listen to incidents for this team
        const incidentsRef = collection(firestore, `teams/${teamId}/incidents`);
        const q = query(incidentsRef, orderBy('createdAt', 'desc'));

        const unsubscribe = onSnapshot(q, async (snapshot) => {
          const incidentsPromises = snapshot.docs.map(async (docSnapshot) => {
            const incidentData = docSnapshot.data();

            // Resolve client name and billing defaults if clientRef exists
            let clientName = 'Unknown Client';
            let clientDefaults = undefined;
            if (incidentData.clientRef) {
              try {
                const clientDoc = await getDoc(incidentData.clientRef);
                if (clientDoc.exists()) {
                  const clientData = clientDoc.data() as any;
                  clientName = clientData?.name;
                  clientDefaults = clientData?.defaults;
                }
              } catch (error) {
                console.error('Error fetching client:', error);
              }
            }

            return {
              id: docSnapshot.id,
              ...incidentData,
              clientName,
              clientDefaults
            } as Incident;
          });

          const resolvedIncidents = await Promise.all(incidentsPromises);
          setIncidents(resolvedIncidents);
          setLoading(false);
        });

        return unsubscribe;
      } catch (error) {
        console.error('Error fetching incidents:', error);

        // Fallback to fake data for development
        console.log('Falling back to fake data for development...');
        setTimeout(() => {
          setIncidents([]);
          setLoading(false);
        }, 1000);
      }
    };

    fetchIncidents();
  }, [user]);

  const filteredIncidents = incidents.filter(incident =>
    filter === 'all' ? true : incident.status === filter
  );

  const calculateBilling = (incident: Incident) => {
    // Use incident-specific billing if available, otherwise fall back to client defaults
    const billing = incident.billing || incident.clientDefaults;

    if (!billing) return null;

    const { billingMethod, minimumBillableQuantity, amountPerUnit } = billing;

    if (billingMethod === 'time') {
      if (!incident.startTime || !incident.endTime) return null;

      try {
        const start = incident.startTime.toDate ? incident.startTime.toDate() : new Date(incident.startTime);
        const end = incident.endTime.toDate ? incident.endTime.toDate() : new Date(incident.endTime);
        const diffMs = end.getTime() - start.getTime();
        let hours = diffMs / (1000 * 60 * 60);

        // Apply time rounding if specified (only available in client defaults, not manual billing)
        if ('timeRounding' in billing && billing.timeRounding?.roundingIncrement) {
          const roundingHours = billing.timeRounding.roundingIncrement;
          hours = Math.ceil(hours / roundingHours) * roundingHours;
        }

        // Apply minimum billable quantity
        const billableHours = Math.max(hours, minimumBillableQuantity);
        return billableHours * amountPerUnit;
      } catch (error) {
        return null;
      }
    } else if (billingMethod === 'square_footage') {
      const billableArea = Math.max(incident.area || 0, minimumBillableQuantity);
      return billableArea * amountPerUnit;
    } else if (billingMethod === 'custom') {
      // For custom billing, we'd need the quantity from the incident data
      // For now, use minimum quantity as a fallback
      return minimumBillableQuantity * amountPerUnit;
    }

    return null;
  };

  const formatDate = (timestamp: any) => {
    if (!timestamp) return 'Unknown';

    try {
      // Handle Firestore timestamp
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

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        <span className="ml-2 text-gray-600 dark:text-gray-400">Loading incidents...</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header with filters */}
      <div className="flex justify-between items-center">
        <div>
          <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Incidents</h3>
          <p className="text-sm text-gray-600 dark:text-gray-400">Track and manage graffiti incidents</p>
        </div>

        <div className="flex space-x-2">
          {(['all', 'open', 'in_progress', 'completed'] as const).map((status) => (
            <button
              key={status}
              onClick={() => setFilter(status)}
              className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                filter === status
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'
              }`}
            >
              {status === 'all' ? 'All' :
               status === 'in_progress' ? 'In Progress' :
               status.charAt(0).toUpperCase() + status.slice(1)}
            </button>
          ))}
        </div>
      </div>

      {/* Incidents List */}
      {filteredIncidents.length === 0 ? (
        <div className="text-center py-12 bg-gray-50 dark:bg-gray-800 rounded-lg">
          <div className="text-4xl mb-4">📱</div>
          <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-2">
            No incidents yet
          </h3>
          <p className="text-gray-600 dark:text-gray-400 mb-6">
            Get started by downloading the FreshWall mobile app to track your first incident.
          </p>
          <button className="bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700">
            Download Mobile App
          </button>
        </div>
      ) : (
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow dark:shadow-gray-700/20 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
              <thead className="bg-gray-50 dark:bg-gray-700">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                    Photo
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                    Location
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                    Client
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                    Area
                  </th>
                  {canViewBilling && (
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                      Time Spent
                    </th>
                  )}
                  {canViewBilling && (
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                      Bill
                    </th>
                  )}
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                    Photos
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                    Date
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                {filteredIncidents.map((incident) => (
                  <tr
                    key={incident.id}
                    className="hover:bg-gray-50 dark:hover:bg-gray-700 cursor-pointer"
                    onClick={() => handleViewIncident(incident)}
                  >
                    <td className="px-6 py-4">
                      <div className="flex-shrink-0 h-12 w-12">
                        {incident.beforePhotos && incident.beforePhotos.length > 0 ? (
                          <img
                            className="h-12 w-12 rounded-lg object-cover border border-gray-200"
                            src={incident.beforePhotos[0].thumbnailUrl || incident.beforePhotos[0].url}
                            alt="Incident thumbnail"
                            onError={(e) => {
                              e.currentTarget.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDgiIGhlaWdodD0iNDgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjQ4IiBoZWlnaHQ9IjQ4IiBmaWxsPSIjRjNGNEY2Ii8+CjxwYXRoIGQ9Ik0yNCAxOEMyNi4yMDkxIDE4IDI4IDMxOS43OTA5IDI4IDIyQzI4IDI0LjIwOTEgMjYuMjA5MSAyNiAyNCAyNkMyMS43OTA5IDI2IDIwIDI0LjIwOTEgMjAgMjJDMjAgMTkuNzkwOSAyMS43OTA5IDE4IDI0IDE4WiIgZmlsbD0iIzlDQTNBRiIvPgo8cGF0aCBkPSJNMTQgMzRIMzRWMzJMMzAgMjhMMjYgMzJMMjIgMjhMMTggMzJWMzRaIiBmaWxsPSIjOUNBM0FGIi8+Cjwvc3ZnPgo=';
                            }}
                          />
                        ) : (
                          <div className="h-12 w-12 rounded-lg bg-gray-100 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 flex items-center justify-center">
                            <span className="text-gray-400 dark:text-gray-500 text-xs">No photo</span>
                          </div>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="max-w-xs">
                        <div className="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">
                          {incident.enhancedLocation?.address || 'Location not available'}
                        </div>
                        {incident.description && (
                          <div className="text-xs text-gray-500 dark:text-gray-400 mt-1 truncate">
                            {incident.description}
                          </div>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900 dark:text-gray-100 font-medium truncate max-w-32">
                        {incident.clientName}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                      {incident.area} sq ft
                    </td>
                    {canViewBilling && (
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                        {(() => {
                          if (!incident.startTime || !incident.endTime) return 'Unknown';
                          try {
                            const start = incident.startTime.toDate ? incident.startTime.toDate() : new Date(incident.startTime);
                            const end = incident.endTime.toDate ? incident.endTime.toDate() : new Date(incident.endTime);
                            const diffMs = end.getTime() - start.getTime();
                            const diffHours = diffMs / (1000 * 60 * 60);

                            if (diffHours < 1) {
                              const diffMinutes = Math.round(diffMs / (1000 * 60));
                              return `${diffMinutes} min`;
                            } else {
                              return `${diffHours.toFixed(1)} hrs`;
                            }
                          } catch (error) {
                            return 'Unknown';
                          }
                        })()}
                      </td>
                    )}
                    {canViewBilling && (
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                        {(() => {
                          const bill = calculateBilling(incident);
                          if (bill === null) return 'Not configured';
                          return `$${bill.toFixed(2)}`;
                        })()}
                      </td>
                    )}
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <div className="flex space-x-1">
                        <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs">
                          Before: {incident.beforePhotos?.length || 0}
                        </span>
                        {incident.afterPhotos?.length > 0 && (
                          <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-xs">
                            After: {incident.afterPhotos.length}
                          </span>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {formatDate(incident.createdAt)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleViewIncident(incident);
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
      {incidents.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow dark:shadow-gray-700/20">
            <div className="text-2xl font-bold text-gray-900 dark:text-gray-100">{incidents.length}</div>
            <div className="text-sm text-gray-600 dark:text-gray-400">Total Incidents</div>
          </div>
          <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow dark:shadow-gray-700/20">
            <div className="text-2xl font-bold text-red-600">
              {incidents.filter(i => i.status === 'open').length}
            </div>
            <div className="text-sm text-gray-600 dark:text-gray-400">Open</div>
          </div>
          <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow dark:shadow-gray-700/20">
            <div className="text-2xl font-bold text-yellow-600">
              {incidents.filter(i => i.status === 'in_progress').length}
            </div>
            <div className="text-sm text-gray-600 dark:text-gray-400">In Progress</div>
          </div>
          <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow dark:shadow-gray-700/20">
            <div className="text-2xl font-bold text-green-600">
              {incidents.filter(i => i.status === 'completed').length}
            </div>
            <div className="text-sm text-gray-600">Completed</div>
          </div>
        </div>
      )}

      {/* View Modal */}
      <IncidentViewModal
        incident={selectedIncident}
        isOpen={isModalOpen}
        onClose={handleCloseModal}
      />
    </div>
  );
}
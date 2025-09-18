'use client';

import { Fragment, useState, useEffect } from 'react';
import { Dialog, Transition } from '@headlessui/react';
import { XMarkIcon, MapPinIcon, ClockIcon, CurrencyDollarIcon, UserIcon } from '@heroicons/react/24/outline';
import { useAuth } from '@/hooks/useAuth';
import { firestore } from '@/lib/firebase';
import { doc, getDoc, getDocs, collection } from 'firebase/firestore';

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

interface ClientViewModalProps {
  client: Client | null;
  isOpen: boolean;
  onClose: () => void;
}

export default function ClientViewModal({ client, isOpen, onClose }: ClientViewModalProps) {
  const { user } = useAuth();
  const [showEditModal, setShowEditModal] = useState(false);
  const [userRole, setUserRole] = useState<string | null>(null);
  const [canViewBilling, setCanViewBilling] = useState(false);

  useEffect(() => {
    const fetchUserRole = async () => {
      if (!user) return;

      try {
        // First try to get role from custom claims
        const idTokenResult = await user.getIdTokenResult();
        let role = idTokenResult.claims?.role;

        // If no role in claims, search teams to find user's role
        if (!role) {
          const teamsSnapshot = await getDocs(collection(firestore, 'teams'));
          for (const teamDoc of teamsSnapshot.docs) {
            const userDoc = await getDoc(doc(firestore, `teams/${teamDoc.id}/users/${user.uid}`));
            if (userDoc.exists()) {
              role = userDoc.data()?.role;
              break;
            }
          }
        }

        setUserRole(role as string);
        // Allow billing access for admin and manager roles
        setCanViewBilling(role === 'admin' || role === 'manager');
      } catch (error) {
        console.error('Error fetching user role:', error);
        setCanViewBilling(false);
      }
    };

    if (isOpen && user) {
      fetchUserRole();
    }
  }, [user, isOpen]);

  const handleMainModalClose = () => {
    onClose();
  };

  if (!client) return null;

  const formatDate = (timestamp: any) => {
    if (!timestamp) return 'Unknown';

    try {
      const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (error) {
      return 'Unknown';
    }
  };

  const getBillingMethodLabel = (method: string) => {
    switch (method) {
      case 'time': return 'Time-based';
      case 'square_footage': return 'Square Footage';
      case 'custom': return 'Custom';
      default: return method;
    }
  };

  const getUnitLabel = (method: string) => {
    switch (method) {
      case 'time': return 'hour';
      case 'square_footage': return 'sq ft';
      case 'custom': return 'unit';
      default: return 'unit';
    }
  };

  const getRoundingDescription = (roundingIncrement: number) => {
    const minutes = Math.round(roundingIncrement * 60);
    if (minutes === 1) return '1 minute';
    if (minutes < 60) return `${minutes} minutes`;
    const hours = minutes / 60;
    return hours === 1 ? '1 hour' : `${hours} hours`;
  };

  return (
    <>
    <Transition appear show={isOpen} as={Fragment}>
      <Dialog as="div" className="relative z-50" onClose={handleMainModalClose}>
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-300"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-200"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black bg-opacity-25" />
        </Transition.Child>

        <div className="fixed inset-0 overflow-y-auto">
          <div className="flex min-h-full items-center justify-center p-4 text-center">
            <Transition.Child
              as={Fragment}
              enter="ease-out duration-300"
              enterFrom="opacity-0 scale-95"
              enterTo="opacity-100 scale-100"
              leave="ease-in duration-200"
              leaveFrom="opacity-100 scale-100"
              leaveTo="opacity-0 scale-95"
            >
              <Dialog.Panel className="w-full max-w-6xl transform overflow-hidden rounded-2xl bg-white text-left align-middle shadow-xl transition-all">
                {/* Header */}
                <div className="flex items-center justify-between p-6 border-b border-gray-200">
                  <div className="flex items-center space-x-3">
                    <div className="flex-shrink-0">
                      <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                        <UserIcon className="w-6 h-6 text-blue-600" />
                      </div>
                    </div>
                    <div>
                      <Dialog.Title as="h3" className="text-lg font-medium leading-6 text-gray-900">
                        {client.name}
                      </Dialog.Title>
                      <p className="text-sm text-gray-500">Client Details</p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-3">
                    <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${
                      client.isDeleted
                        ? 'bg-red-100 text-red-800 border-red-200'
                        : 'bg-green-100 text-green-800 border-green-200'
                    }`}>
                      {client.isDeleted ? 'Deleted' : 'Active'}
                    </span>
                    <button
                      onClick={handleMainModalClose}
                      className="text-gray-400 hover:text-gray-600 transition-colors"
                    >
                      <XMarkIcon className="h-6 w-6" />
                    </button>
                  </div>
                </div>

                <div className="p-6 max-h-[80vh] overflow-y-auto">
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">

                    {/* Client Information */}
                    <div className="space-y-6">
                      <div>
                        <h4 className="text-sm font-semibold text-gray-900 mb-3">Client Information</h4>
                        <div className="space-y-4">
                          <div>
                            <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Name</label>
                            <p className="text-sm text-gray-900 mt-1">{client.name}</p>
                          </div>

                          <div>
                            <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Notes</label>
                            <p className="text-sm text-gray-900 mt-1">
                              {client.notes || 'No notes'}
                            </p>
                          </div>

                          <div>
                            <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Created</label>
                            <p className="text-sm text-gray-900 mt-1">{formatDate(client.createdAt)}</p>
                          </div>

                          <div>
                            <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Last Incident</label>
                            <p className="text-sm text-gray-900 mt-1">
                              {client.lastIncidentAt ? formatDate(client.lastIncidentAt) : 'No incidents yet'}
                            </p>
                          </div>

                          {client.isDeleted && client.deletedAt && (
                            <div>
                              <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Deleted</label>
                              <p className="text-sm text-red-600 mt-1">{formatDate(client.deletedAt)}</p>
                            </div>
                          )}
                        </div>
                      </div>
                    </div>

                    {/* Billing Defaults */}
                    <div className="space-y-6">
                      <div>
                        <h4 className="text-sm font-semibold text-gray-900 mb-3">Billing Defaults</h4>
                        {!canViewBilling ? (
                          <div className="text-center py-8 text-gray-500">
                            <CurrencyDollarIcon className="w-12 h-12 mx-auto mb-3 text-gray-300" />
                            <p className="text-sm">Access Restricted</p>
                            <p className="text-xs text-gray-400 mt-1">
                              Only admins and managers can view billing information
                            </p>
                          </div>
                        ) : client.defaults ? (
                          <div className="space-y-4">
                            <div>
                              <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Billing Method</label>
                              <p className="text-sm text-gray-900 mt-1 flex items-center">
                                <CurrencyDollarIcon className="w-4 h-4 mr-1 text-gray-400" />
                                {getBillingMethodLabel(client.defaults.billingMethod)}
                              </p>
                            </div>

                            <div>
                              <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Minimum Billable Quantity
                              </label>
                              <p className="text-sm text-gray-900 mt-1">
                                {client.defaults.minimumBillableQuantity} {getUnitLabel(client.defaults.billingMethod)}
                                {client.defaults.minimumBillableQuantity > 1 ? 's' : ''}
                              </p>
                            </div>

                            <div>
                              <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Rate</label>
                              <p className="text-sm text-gray-900 mt-1">
                                ${client.defaults.amountPerUnit.toFixed(2)} per {getUnitLabel(client.defaults.billingMethod)}
                              </p>
                            </div>

                            {client.defaults.billingMethod === 'time' && client.defaults.timeRounding && (
                              <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                                  Time Rounding
                                </label>
                                <p className="text-sm text-gray-900 mt-1 flex items-center">
                                  <ClockIcon className="w-4 h-4 mr-1 text-gray-400" />
                                  Round to {getRoundingDescription(client.defaults.timeRounding.roundingIncrement)}
                                </p>
                              </div>
                            )}

                            {client.defaults.billingMethod === 'custom' && client.defaults.customUnitDescription && (
                              <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                                  Custom Unit Description
                                </label>
                                <p className="text-sm text-gray-900 mt-1">{client.defaults.customUnitDescription}</p>
                              </div>
                            )}

                            {/* Billing Examples */}
                            <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                              <h5 className="text-xs font-medium text-blue-900 uppercase tracking-wider mb-3">
                                Billing Examples
                              </h5>

                              {client.defaults.billingMethod === 'time' && (
                                <div className="space-y-3">
                                  <p className="text-xs text-blue-700">
                                    Rate: ${client.defaults.amountPerUnit.toFixed(2)}/hour • Minimum: {client.defaults.minimumBillableQuantity} hours
                                    {client.defaults.timeRounding && ` • Rounding: ${getRoundingDescription(client.defaults.timeRounding.roundingIncrement)}`}
                                  </p>

                                  <div className="bg-white rounded-md p-3 space-y-2">
                                    {[0.08, 0.17, 0.25, 0.5, 1.2, 1.75, 2.3, 3.1, 4.67].map((rawHours) => {
                                      let roundedHours = rawHours;

                                      // Apply rounding if specified
                                      if (client.defaults?.timeRounding?.roundingIncrement) {
                                        const roundingIncrement = client.defaults.timeRounding.roundingIncrement;
                                        roundedHours = Math.ceil(rawHours / roundingIncrement) * roundingIncrement;
                                      }

                                      // Apply minimum billable quantity
                                      const billableHours = Math.max(roundedHours, client.defaults?.minimumBillableQuantity || 0);
                                      const totalCost = billableHours * (client.defaults?.amountPerUnit || 0);

                                      return (
                                        <div key={rawHours} className="flex items-center text-xs space-x-2">
                                          <span className="w-12 text-gray-600">{rawHours.toFixed(2)}h</span>
                                          <span className="text-gray-500">→</span>
                                          <span className="w-12 font-medium text-gray-900">{roundedHours.toFixed(2)}h</span>
                                          {billableHours !== roundedHours && (
                                            <span className="text-orange-600 text-xs">
                                              (min: {billableHours.toFixed(2)}h)
                                            </span>
                                          )}
                                          <div className="flex-1"></div>
                                          <span className="font-semibold text-blue-800">
                                            ${totalCost.toFixed(2)}
                                          </span>
                                        </div>
                                      );
                                    })}
                                  </div>
                                </div>
                              )}

                              {client.defaults.billingMethod === 'square_footage' && (
                                <div className="space-y-3">
                                  <p className="text-xs text-blue-700">
                                    Rate: ${client.defaults.amountPerUnit.toFixed(2)}/sq ft • Minimum: {client.defaults.minimumBillableQuantity} sq ft
                                  </p>

                                  <div className="bg-white rounded-md p-3 space-y-2">
                                    {[25, 75, 120, 180, 250, 350, 500, 750, 1200].map((area) => {
                                      const billableArea = Math.max(area, client.defaults?.minimumBillableQuantity || 0);
                                      const totalCost = billableArea * (client.defaults?.amountPerUnit || 0);

                                      return (
                                        <div key={area} className="flex items-center text-xs space-x-2">
                                          <span className="w-16 text-gray-600">{area} sq ft</span>
                                          <span className="text-gray-500">→</span>
                                          <span className="w-16 font-medium text-gray-900">{billableArea} sq ft</span>
                                          {billableArea !== area && (
                                            <span className="text-orange-600 text-xs">(minimum)</span>
                                          )}
                                          <div className="flex-1"></div>
                                          <span className="font-semibold text-blue-800">
                                            ${totalCost.toFixed(2)}
                                          </span>
                                        </div>
                                      );
                                    })}
                                  </div>
                                </div>
                              )}

                              {client.defaults.billingMethod === 'custom' && (
                                <div className="text-sm text-blue-800">
                                  <p>
                                    Rate: ${client.defaults.amountPerUnit.toFixed(2)} per {client.defaults.customUnitDescription || 'unit'}
                                    (Minimum: {client.defaults.minimumBillableQuantity} {client.defaults.customUnitDescription || 'units'})
                                  </p>
                                </div>
                              )}
                            </div>
                          </div>
                        ) : (
                          <div className="text-center py-8 text-gray-500">
                            <CurrencyDollarIcon className="w-12 h-12 mx-auto mb-3 text-gray-300" />
                            <p className="text-sm">No billing defaults configured</p>
                            <p className="text-xs text-gray-400 mt-1">
                              Set up billing defaults to streamline incident billing
                            </p>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Footer */}
                <div className="flex justify-end space-x-3 p-6 border-t border-gray-200 bg-gray-50">
                  <button
                    onClick={handleMainModalClose}
                    className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                  >
                    Close
                  </button>
                  <button
                    onClick={() => setShowEditModal(true)}
                    className="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                  >
                    Edit Client
                  </button>
                </div>
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
    </>
  );
}
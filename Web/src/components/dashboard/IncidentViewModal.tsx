'use client';

import { Fragment, useState } from 'react';
import { Dialog, Transition } from '@headlessui/react';
import { XMarkIcon, MapPinIcon, ClockIcon, CurrencyDollarIcon } from '@heroicons/react/24/outline';

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

interface Incident {
  id: string;
  clientRef?: string;
  clientName?: string;
  description: string;
  area: number;
  createdAt: any;
  startTime: any;
  endTime: any;
  beforePhotos: IncidentPhoto[];
  afterPhotos: IncidentPhoto[];
  createdBy: string;
  lastModifiedBy?: string;
  lastModifiedAt?: any;
  rate?: number;
  materialsUsed?: string;
  status?: 'open' | 'in_progress' | 'completed' | 'cancelled';
  enhancedLocation?: {
    latitude: number;
    longitude: number;
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

interface IncidentViewModalProps {
  incident: Incident | null;
  isOpen: boolean;
  onClose: () => void;
}

export default function IncidentViewModal({ incident, isOpen, onClose }: IncidentViewModalProps) {
  const [selectedPhoto, setSelectedPhoto] = useState<IncidentPhoto | null>(null);
  const [isPhotoModalOpen, setIsPhotoModalOpen] = useState(false);

  const handlePhotoClick = (photo: IncidentPhoto) => {
    setSelectedPhoto(photo);
    setIsPhotoModalOpen(true);
  };

  const handlePhotoModalClose = () => {
    setIsPhotoModalOpen(false);
    setSelectedPhoto(null);
  };

  const handleMainModalClose = () => {
    // If photo modal is open, only close that - don't close main modal
    if (isPhotoModalOpen) {
      setIsPhotoModalOpen(false);
      setSelectedPhoto(null);
      return;
    }
    onClose();
  };

  if (!incident) return null;

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'open': return 'bg-red-100 text-red-800 border-red-200';
      case 'in_progress': return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'completed': return 'bg-green-100 text-green-800 border-green-200';
      case 'cancelled': return 'bg-gray-100 text-gray-800 border-gray-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const formatDate = (timestamp: any) => {
    if (!timestamp) return 'Unknown';
    try {
      const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
      return date.toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (error) {
      return 'Unknown';
    }
  };

  const calculateDuration = () => {
    try {
      const start = incident.startTime.toDate ? incident.startTime.toDate() : new Date(incident.startTime);
      const end = incident.endTime.toDate ? incident.endTime.toDate() : new Date(incident.endTime);
      const hours = (end.getTime() - start.getTime()) / (1000 * 60 * 60);
      return hours.toFixed(2);
    } catch (error) {
      return '0.00';
    }
  };

  const calculateBilling = () => {
    if (!incident.billing) return null;

    const { billingMethod, amountPerUnit, minimumBillableQuantity } = incident.billing;
    let quantity = 0;

    if (billingMethod === 'time') {
      quantity = Math.max(parseFloat(calculateDuration()), minimumBillableQuantity);
    } else if (billingMethod === 'square_footage') {
      quantity = Math.max(incident.area, minimumBillableQuantity);
    } else {
      quantity = minimumBillableQuantity; // Custom billing
    }

    const total = quantity * amountPerUnit;

    return {
      quantity: quantity.toFixed(2),
      rate: amountPerUnit.toFixed(2),
      total: total.toFixed(2),
      unit: billingMethod === 'time' ? 'hours' : billingMethod === 'square_footage' ? 'sq ft' : incident.billing.customUnitDescription || 'units'
    };
  };

  const billing = calculateBilling();

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
              <Dialog.Panel className="w-full max-w-7xl transform overflow-hidden rounded-2xl bg-white text-left align-middle shadow-xl transition-all">
                {/* Header */}
                <div className="flex items-center justify-between p-6 border-b border-gray-200">
                  <div className="flex-1">
                    <Dialog.Title as="h3" className="text-lg font-semibold text-gray-900">
                      Incident Details
                    </Dialog.Title>
                    <p className="text-sm text-gray-600 mt-1">
                      ID: {incident.id}
                    </p>
                  </div>
                  <div className="flex items-center space-x-3">
                    <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full border ${getStatusColor(incident.status || 'open')}`}>
                      {incident.status === 'in_progress' ? 'In Progress' :
                       (incident.status || 'open').charAt(0).toUpperCase() + (incident.status || 'open').slice(1)}
                    </span>
                    <button
                      onClick={handleMainModalClose}
                      className="text-gray-400 hover:text-gray-600 transition-colors"
                    >
                      <XMarkIcon className="h-6 w-6" />
                    </button>
                  </div>
                </div>

                {/* Content */}
                <div className="p-6 max-h-[80vh] overflow-y-auto">
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Left Column */}
                    <div className="space-y-6">
                      {/* Basic Information */}
                      <div className="bg-gray-50 rounded-lg p-4">
                        <h4 className="text-sm font-semibold text-gray-900 mb-3">Basic Information</h4>
                        <div className="space-y-3">
                          <div>
                            <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Client</label>
                            <p className="text-sm text-gray-900 mt-1">{incident.clientName || 'Unknown Client'}</p>
                          </div>
                          <div>
                            <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Description</label>
                            <p className="text-sm text-gray-900 mt-1">{incident.description}</p>
                          </div>
                          <div className="grid grid-cols-2 gap-4">
                            <div>
                              <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Area</label>
                              <p className="text-sm text-gray-900 mt-1">{incident.area} sq ft</p>
                            </div>
                            <div>
                              <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Surface Type</label>
                              <p className="text-sm text-gray-900 mt-1 capitalize">
                                {incident.surfaceType?.replace('_', ' ') || 'Unknown'}
                              </p>
                            </div>
                          </div>
                          {incident.materialsUsed && (
                            <div>
                              <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Materials Used</label>
                              <p className="text-sm text-gray-900 mt-1">{incident.materialsUsed}</p>
                            </div>
                          )}
                        </div>
                      </div>

                      {/* Timeline */}
                      <div className="bg-gray-50 rounded-lg p-4">
                        <h4 className="text-sm font-semibold text-gray-900 mb-3 flex items-center">
                          <ClockIcon className="h-4 w-4 mr-2" />
                          Timeline
                        </h4>
                        <div className="space-y-3">
                          <div>
                            <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Created</label>
                            <p className="text-sm text-gray-900 mt-1">{formatDate(incident.createdAt)}</p>
                          </div>
                          <div className="grid grid-cols-2 gap-4">
                            <div>
                              <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Start Time</label>
                              <p className="text-sm text-gray-900 mt-1">{formatDate(incident.startTime)}</p>
                            </div>
                            <div>
                              <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">End Time</label>
                              <p className="text-sm text-gray-900 mt-1">{formatDate(incident.endTime)}</p>
                            </div>
                          </div>
                          <div>
                            <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Duration</label>
                            <p className="text-sm text-gray-900 mt-1">{calculateDuration()} hours</p>
                          </div>
                          {incident.lastModifiedAt && (
                            <div>
                              <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Last Modified</label>
                              <p className="text-sm text-gray-900 mt-1">{formatDate(incident.lastModifiedAt)}</p>
                            </div>
                          )}
                        </div>
                      </div>

                      {/* Location */}
                      {incident.enhancedLocation && (
                        <div className="bg-gray-50 rounded-lg p-4">
                          <h4 className="text-sm font-semibold text-gray-900 mb-3 flex items-center">
                            <MapPinIcon className="h-4 w-4 mr-2" />
                            Location
                          </h4>
                          <div className="space-y-3">
                            {incident.enhancedLocation.address && (
                              <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Address</label>
                                <p className="text-sm text-gray-900 mt-1">{incident.enhancedLocation.address}</p>
                              </div>
                            )}
                            <div>
                              <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Coordinates</label>
                              <p className="text-sm text-gray-900 mt-1">
                                {incident.enhancedLocation?.coordinates
                                  ? `${incident.enhancedLocation.coordinates.latitude.toFixed(6)}, ${incident.enhancedLocation.coordinates.longitude.toFixed(6)}`
                                  : 'Location not available'
                                }
                              </p>
                            </div>
                          </div>
                        </div>
                      )}

                      {/* Billing */}
                      {billing && (
                        <div className="bg-gray-50 rounded-lg p-4">
                          <h4 className="text-sm font-semibold text-gray-900 mb-3 flex items-center">
                            <CurrencyDollarIcon className="h-4 w-4 mr-2" />
                            Billing Information
                          </h4>
                          <div className="space-y-3">
                            <div className="grid grid-cols-2 gap-4">
                              <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Method</label>
                                <p className="text-sm text-gray-900 mt-1 capitalize">
                                  {incident.billing?.billingMethod.replace('_', ' ')}
                                </p>
                              </div>
                              <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Rate</label>
                                <p className="text-sm text-gray-900 mt-1">${billing.rate} / {billing.unit}</p>
                              </div>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                              <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Quantity</label>
                                <p className="text-sm text-gray-900 mt-1">{billing.quantity} {billing.unit}</p>
                              </div>
                              <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Total</label>
                                <p className="text-sm font-semibold text-gray-900 mt-1">${billing.total}</p>
                              </div>
                            </div>
                            {incident.billing?.wasOverridden && (
                              <div className="text-xs text-amber-600 bg-amber-50 px-2 py-1 rounded">
                                ⚠️ Billing was manually overridden for this incident
                              </div>
                            )}
                          </div>
                        </div>
                      )}
                    </div>

                    {/* Right Column */}
                    <div className="space-y-6">
                      {/* Notes */}
                      {incident.enhancedNotes && (
                        <div className="bg-gray-50 rounded-lg p-4">
                          <h4 className="text-sm font-semibold text-gray-900 mb-3">Work Notes</h4>
                          <div className="space-y-3">
                            {incident.enhancedNotes.preWorkNotes && (
                              <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Pre-Work Assessment</label>
                                <p className="text-sm text-gray-900 mt-1">{incident.enhancedNotes.preWorkNotes}</p>
                              </div>
                            )}
                            {incident.enhancedNotes.workNotes && (
                              <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Work Performed</label>
                                <p className="text-sm text-gray-900 mt-1">{incident.enhancedNotes.workNotes}</p>
                              </div>
                            )}
                            {incident.enhancedNotes.postWorkNotes && (
                              <div>
                                <label className="text-xs font-medium text-gray-500 uppercase tracking-wider">Post-Work Notes</label>
                                <p className="text-sm text-gray-900 mt-1">{incident.enhancedNotes.postWorkNotes}</p>
                              </div>
                            )}
                          </div>
                        </div>
                      )}

                      {/* Before Photos */}
                      {incident.beforePhotos.length > 0 && (
                        <div className="bg-gray-50 rounded-lg p-4">
                          <h4 className="text-sm font-semibold text-gray-900 mb-3">
                            Before Photos ({incident.beforePhotos.length})
                          </h4>
                          <div className="grid grid-cols-2 gap-3">
                            {incident.beforePhotos.map((photo) => (
                              <div key={photo.id} className="relative cursor-pointer" onClick={() => handlePhotoClick(photo)}>
                                <img
                                  src={photo.thumbnailUrl || photo.url}
                                  alt="Before photo"
                                  className="w-full h-24 object-cover rounded-lg border border-gray-200 hover:opacity-90 transition-opacity"
                                  onError={(e) => {
                                    e.currentTarget.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZGRkIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNCIgZmlsbD0iIzk5OSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPkJlZm9yZSBQaG90bzwvdGV4dD48L3N2Zz4=';
                                  }}
                                />
                              </div>
                            ))}
                          </div>
                        </div>
                      )}

                      {/* After Photos */}
                      {incident.afterPhotos.length > 0 && (
                        <div className="bg-gray-50 rounded-lg p-4">
                          <h4 className="text-sm font-semibold text-gray-900 mb-3">
                            After Photos ({incident.afterPhotos.length})
                          </h4>
                          <div className="grid grid-cols-2 gap-3">
                            {incident.afterPhotos.map((photo) => (
                              <div key={photo.id} className="relative cursor-pointer" onClick={() => handlePhotoClick(photo)}>
                                <img
                                  src={photo.thumbnailUrl || photo.url}
                                  alt="After photo"
                                  className="w-full h-24 object-cover rounded-lg border border-gray-200 hover:opacity-90 transition-opacity"
                                  onError={(e) => {
                                    e.currentTarget.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZGRkIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNCIgZmlsbD0iIzk5OSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPkFmdGVyIFBob3RvPC90ZXh0Pjwvc3ZnPg==';
                                  }}
                                />
                              </div>
                            ))}
                          </div>
                        </div>
                      )}
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
                  <button className="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                    Edit Incident
                  </button>
                </div>
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>

    {/* Photo Modal */}
    <Transition appear show={isPhotoModalOpen} as={Fragment}>
      <Dialog as="div" className="relative z-[60]" onClose={handlePhotoModalClose}>
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-300"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-200"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black bg-opacity-75" />
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
                {selectedPhoto && (
                  <div className="relative">
                    <button
                      onClick={handlePhotoModalClose}
                      className="absolute top-4 right-4 z-10 p-2 bg-black bg-opacity-50 text-white rounded-full hover:bg-opacity-70 transition-opacity"
                    >
                      <XMarkIcon className="h-6 w-6" />
                    </button>
                    <img
                      src={selectedPhoto.url}
                      alt="Incident photo"
                      className="w-full h-auto max-h-[80vh] object-contain"
                      onError={(e) => {
                        e.currentTarget.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjQwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZGRkIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIyMCIgZmlsbD0iIzk5OSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPkltYWdlIE5vdCBGb3VuZDwvdGV4dD48L3N2Zz4=';
                      }}
                    />
                    {selectedPhoto.captureDate && (
                      <div className="absolute bottom-4 left-4 bg-black bg-opacity-60 text-white px-3 py-2 rounded-lg">
                        <p className="text-sm font-medium">
                          Captured: {formatDate(selectedPhoto.captureDate)}
                        </p>
                      </div>
                    )}
                  </div>
                )}
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
    </>
  );
}
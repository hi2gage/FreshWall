'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { firestore } from '@/lib/firebase';
import { collection, query, orderBy, getDocs, doc, getDoc } from 'firebase/firestore';
import { generateInvoicePDF } from '@/lib/pdfService';
import { DEFAULT_INVOICE_TEMPLATE, InvoiceTemplate } from '@/types/invoice';
import InvoiceTemplateEditor from './InvoiceTemplateEditor';
import InvoicePreview from './InvoicePreview';

interface Client {
  id: string;
  name: string;
  defaults?: {
    billingMethod: 'time' | 'square_footage' | 'custom';
    minimumBillableQuantity: number;
    amountPerUnit: number;
    timeRounding?: {
      roundingIncrement: number;
    };
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
  rate?: number;
  materialsUsed?: string;
  status?: string;
  enhancedLocation?: {
    address?: string;
  };
  surfaceType?: string;
  billing?: {
    billingMethod: 'time' | 'square_footage' | 'custom';
    minimumBillableQuantity: number;
    amountPerUnit: number;
  };
}

export default function InvoicesTab() {
  const { user } = useAuth();
  const [clients, setClients] = useState<Client[]>([]);
  const [selectedClient, setSelectedClient] = useState<string>('');
  const [availableMonths, setAvailableMonths] = useState<Array<{ month: number; year: number; display: string }>>([]);
  const [selectedMonthYear, setSelectedMonthYear] = useState('');
  const [useCustomDateRange, setUseCustomDateRange] = useState(false);
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [loading, setLoading] = useState(false);
  const [generating, setGenerating] = useState(false);
  const [template, setTemplate] = useState<InvoiceTemplate>(DEFAULT_INVOICE_TEMPLATE);
  const [showTemplateEditor, setShowTemplateEditor] = useState(false);
  const [previewIncidents, setPreviewIncidents] = useState<Incident[]>([]);
  const [previewClient, setPreviewClient] = useState<Client | null>(null);

  // Set default custom date range values
  useEffect(() => {
    const now = new Date();
    const firstDayOfPreviousMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);

    setStartDate(firstDayOfPreviousMonth.toISOString().split('T')[0]);
    setEndDate(now.toISOString().split('T')[0]);
  }, []);

  // Fetch available months when client is selected
  useEffect(() => {
    if (!selectedClient || !user) {
      setAvailableMonths([]);
      setSelectedMonthYear('');
      return;
    }

    const fetchAvailableMonths = async () => {
      try {
        // Get teamId
        let idTokenResult = await user.getIdTokenResult();
        let teamId = idTokenResult.claims?.teamId as string | undefined;

        if (!teamId) {
          idTokenResult = await user.getIdTokenResult(true);
          teamId = idTokenResult.claims?.teamId as string | undefined;
        }

        if (!teamId) {
          const teamsSnapshot = await getDocs(collection(firestore, 'teams'));
          for (const teamDoc of teamsSnapshot.docs) {
            const userDoc = await getDoc(doc(firestore, `teams/${teamDoc.id}/users/${user.uid}`));
            if (userDoc.exists()) {
              teamId = teamDoc.id;
              break;
            }
          }
        }

        if (!teamId) {
          return;
        }

        // Fetch all incidents for this client
        const incidentsRef = collection(firestore, `teams/${teamId}/incidents`);
        const incidentsSnapshot = await getDocs(incidentsRef);

        const monthYearSet = new Set<string>();
        incidentsSnapshot.forEach((docSnap) => {
          const data = docSnap.data();
          const clientRefPath = data.clientRef?.path || '';
          const isClientMatch = clientRefPath.includes(selectedClient);

          if (isClientMatch && data.createdAt) {
            const incidentDate = data.createdAt.toDate();
            const monthYear = `${incidentDate.getFullYear()}-${String(incidentDate.getMonth() + 1).padStart(2, '0')}`;
            monthYearSet.add(monthYear);
          }
        });

        // Convert to array and sort (most recent first)
        const months = Array.from(monthYearSet)
          .map((monthYear) => {
            const [year, month] = monthYear.split('-').map(Number);
            const date = new Date(year, month - 1, 1);
            return {
              month,
              year,
              display: date.toLocaleDateString('en-US', { month: 'long', year: 'numeric' }),
              sortKey: year * 100 + month,
            };
          })
          .sort((a, b) => b.sortKey - a.sortKey);

        setAvailableMonths(months);
      } catch (error) {
        console.error('Error fetching available months:', error);
      }
    };

    fetchAvailableMonths();
  }, [selectedClient, user]);

  useEffect(() => {
    if (!user) return;

    const fetchClients = async () => {
      try {
        setLoading(true);

        // Get teamId from custom claims or search teams (same approach as ClientsTab)
        let idTokenResult = await user.getIdTokenResult();
        let teamId = idTokenResult.claims?.teamId as string | undefined;

        // If no teamId in claims, try refreshing the token
        if (!teamId) {
          console.log('No teamId in claims, refreshing token...');
          idTokenResult = await user.getIdTokenResult(true);
          teamId = idTokenResult.claims?.teamId as string | undefined;
        }

        // If still no team in claims, search teams collection directly
        if (!teamId) {
          console.log('Still no teamId in claims, searching teams for user...');

          const teamsSnapshot = await getDocs(collection(firestore, 'teams'));
          for (const teamDoc of teamsSnapshot.docs) {
            const userDoc = await getDoc(doc(firestore, `teams/${teamDoc.id}/users/${user.uid}`));
            if (userDoc.exists()) {
              teamId = teamDoc.id;
              console.log('Found user in team:', teamId);
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

        console.log('Fetching clients for team:', teamId);

        // TypeScript type guard - teamId is guaranteed to be a string here
        if (!teamId) {
          console.error('No teamId available');
          setClients([]);
          setLoading(false);
          return;
        }

        // Fetch clients
        const clientsRef = collection(firestore, 'teams', teamId, 'clients');
        const clientsQuery = query(clientsRef, orderBy('name', 'asc'));
        const clientsSnapshot = await getDocs(clientsQuery);

        const clientsList: Client[] = [];
        clientsSnapshot.forEach((doc) => {
          const data = doc.data();
          if (!data.isDeleted) {
            clientsList.push({
              id: doc.id,
              name: data.name,
            });
          }
        });

        setClients(clientsList);
      } catch (error) {
        console.error('Error fetching clients:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchClients();
  }, [user]);

  useEffect(() => {
    if (!user) return;

    const loadTemplate = async () => {
      try {
        // Get teamId using same approach
        let idTokenResult = await user.getIdTokenResult();
        let teamId = idTokenResult.claims?.teamId as string | undefined;

        if (!teamId) {
          idTokenResult = await user.getIdTokenResult(true);
          teamId = idTokenResult.claims?.teamId as string | undefined;
        }

        if (!teamId) {
          const teamsSnapshot = await getDocs(collection(firestore, 'teams'));
          for (const teamDoc of teamsSnapshot.docs) {
            const userDoc = await getDoc(doc(firestore, `teams/${teamDoc.id}/users/${user.uid}`));
            if (userDoc.exists()) {
              teamId = teamDoc.id;
              break;
            }
          }
        }

        if (teamId) {
          // Load template from Firestore
          const templateDoc = await getDoc(doc(firestore, `teams/${teamId}/invoiceTemplate/default`));
          if (templateDoc.exists()) {
            const data = templateDoc.data();
            setTemplate({
              ...DEFAULT_INVOICE_TEMPLATE,
              ...data,
              createdAt: data.createdAt?.toDate() || new Date(),
              updatedAt: data.updatedAt?.toDate() || new Date(),
            } as InvoiceTemplate);
          }
        }
      } catch (error) {
        console.error('Error loading template:', error);
      }
    };

    loadTemplate();
  }, [user]);

  // Fetch preview data when selection changes
  useEffect(() => {
    if (!selectedClient || !user) {
      setPreviewIncidents([]);
      setPreviewClient(null);
      return;
    }

    // Calculate date range based on mode
    let start: Date;
    let end: Date;

    if (useCustomDateRange) {
      if (!startDate || !endDate) {
        setPreviewIncidents([]);
        return;
      }
      start = new Date(startDate);
      end = new Date(endDate);
      end.setHours(23, 59, 59, 999);
    } else {
      if (!selectedMonthYear) {
        setPreviewIncidents([]);
        return;
      }
      const [year, month] = selectedMonthYear.split('-').map(Number);
      start = new Date(year, month - 1, 1);
      end = new Date(year, month, 0);
      end.setHours(23, 59, 59, 999);
    }

    const fetchPreviewData = async () => {
      try {
        // Get teamId using same approach
        let idTokenResult = await user.getIdTokenResult();
        let teamId = idTokenResult.claims?.teamId as string | undefined;

        if (!teamId) {
          idTokenResult = await user.getIdTokenResult(true);
          teamId = idTokenResult.claims?.teamId as string | undefined;
        }

        if (!teamId) {
          const teamsSnapshot = await getDocs(collection(firestore, 'teams'));
          for (const teamDoc of teamsSnapshot.docs) {
            const userDoc = await getDoc(doc(firestore, `teams/${teamDoc.id}/users/${user.uid}`));
            if (userDoc.exists()) {
              teamId = teamDoc.id;
              break;
            }
          }
        }

        if (!teamId) {
          return;
        }

        // Fetch client details with defaults
        const clientDoc = await getDoc(doc(firestore, `teams/${teamId}/clients/${selectedClient}`));
        if (clientDoc.exists()) {
          const clientData = clientDoc.data();
          setPreviewClient({
            id: clientDoc.id,
            name: clientData.name,
            defaults: clientData.defaults,
          } as Client);
        }

        // Fetch incidents for this client in date range
        const incidentsRef = collection(firestore, `teams/${teamId}/incidents`);
        const incidentsSnapshot = await getDocs(incidentsRef);

        const incidents: Incident[] = [];
        incidentsSnapshot.forEach((docSnap) => {
          const data = docSnap.data();
          const incidentDate = data.createdAt?.toDate();

          const clientRefPath = data.clientRef?.path || '';
          const isClientMatch = clientRefPath.includes(selectedClient);
          const isInDateRange = incidentDate && incidentDate >= start && incidentDate <= end;

          if (isClientMatch && isInDateRange) {
            incidents.push({
              id: docSnap.id,
              ...data,
            } as Incident);
          }
        });

        setPreviewIncidents(incidents);
      } catch (error) {
        console.error('Error fetching preview data:', error);
      }
    };

    fetchPreviewData();
  }, [selectedClient, selectedMonthYear, useCustomDateRange, startDate, endDate, user]);

  const handleGenerateInvoice = async () => {
    if (!selectedClient || !user) {
      alert('Please select a client');
      return;
    }

    // Calculate date range based on mode
    let start: Date;
    let end: Date;
    let reportPeriod: string;

    if (useCustomDateRange) {
      if (!startDate || !endDate) {
        alert('Please select a date range');
        return;
      }
      start = new Date(startDate);
      end = new Date(endDate);
      end.setHours(23, 59, 59, 999);
      reportPeriod = `${start.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })} - ${end.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}`;
    } else {
      if (!selectedMonthYear) {
        alert('Please select a month and year');
        return;
      }
      const [year, month] = selectedMonthYear.split('-').map(Number);
      start = new Date(year, month - 1, 1);
      end = new Date(year, month, 0);
      end.setHours(23, 59, 59, 999);
      reportPeriod = `${start.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}`;
    }

    try {
      setGenerating(true);

      // Get teamId using the same approach
      let idTokenResult = await user.getIdTokenResult();
      let teamId = idTokenResult.claims?.teamId as string | undefined;

      if (!teamId) {
        idTokenResult = await user.getIdTokenResult(true);
        teamId = idTokenResult.claims?.teamId as string | undefined;
      }

      if (!teamId) {
        const teamsSnapshot = await getDocs(collection(firestore, 'teams'));
        for (const teamDoc of teamsSnapshot.docs) {
          const userDoc = await getDoc(doc(firestore, `teams/${teamDoc.id}/users/${user.uid}`));
          if (userDoc.exists()) {
            teamId = teamDoc.id;
            break;
          }
        }

        if (!teamId) {
          alert('No team found for user');
          setGenerating(false);
          return;
        }
      }

      // TypeScript type guard - teamId is guaranteed to be a string here
      if (!teamId) {
        alert('No team found for user');
        setGenerating(false);
        return;
      }

      // Get client
      const clientDoc = await getDoc(doc(firestore, 'teams', teamId, 'clients', selectedClient));
      const client = { id: clientDoc.id, ...clientDoc.data() } as any;

      console.log('Client data for invoice:', client);
      console.log('Client defaults:', client.defaults);

      // Merge client-specific template overrides with team template
      const effectiveTemplate: InvoiceTemplate = {
        ...template,
        ...(client.invoiceTemplate && {
          companyName: client.invoiceTemplate.companyName || template.companyName,
          companyAddress: client.invoiceTemplate.companyAddress || template.companyAddress,
          companyPhone: client.invoiceTemplate.companyPhone || template.companyPhone,
          companyWebsite: client.invoiceTemplate.companyWebsite || template.companyWebsite,
          invoicePrefix: client.invoiceTemplate.invoicePrefix || template.invoicePrefix,
          invoiceNumberFormat: (client.invoiceTemplate.invoiceNumberFormat as any) || template.invoiceNumberFormat,
          paymentTerms: client.invoiceTemplate.paymentTerms || template.paymentTerms,
          taxRate: client.invoiceTemplate.taxRate !== undefined ? client.invoiceTemplate.taxRate : template.taxRate,
          taxLabel: client.invoiceTemplate.taxLabel || template.taxLabel,
          showTax: client.invoiceTemplate.showTax !== undefined ? client.invoiceTemplate.showTax : template.showTax,
          footerThankYouMessage: client.invoiceTemplate.footerThankYouMessage || template.footerThankYouMessage,
          footerShowRemittanceInfo: client.invoiceTemplate.footerShowRemittanceInfo !== undefined ? client.invoiceTemplate.footerShowRemittanceInfo : template.footerShowRemittanceInfo,
          footerClosingMessage: client.invoiceTemplate.footerClosingMessage || template.footerClosingMessage,
          descriptionPrefix: client.invoiceTemplate.descriptionPrefix || template.descriptionPrefix,
          sortBy: (client.invoiceTemplate.sortBy as any) || template.sortBy,
          sortOrder: client.invoiceTemplate.sortOrder || template.sortOrder,
        })
      };

      console.log('Effective template for invoice:', effectiveTemplate);

      // Get incidents for this client in date range
      const incidentsRef = collection(firestore, 'teams', teamId, 'incidents');
      const incidentsSnapshot = await getDocs(incidentsRef);

      const incidents: Incident[] = [];
      incidentsSnapshot.forEach((doc) => {
        const data = doc.data();
        const incidentDate = data.createdAt?.toDate();

        // Check if incident belongs to this client and is in date range
        const clientRefPath = data.clientRef?.path || '';
        const isClientMatch = clientRefPath.includes(selectedClient);
        const isInDateRange = incidentDate && incidentDate >= start && incidentDate <= end;

        if (isClientMatch && isInDateRange) {
          const incident = {
            id: doc.id,
            ...data,
          } as Incident;

          // Log the complete incident structure for debugging
          console.log('=== INCIDENT DATA STRUCTURE ===');
          console.log('Full incident object:', JSON.stringify(incident, null, 2));
          console.log('ID:', incident.id);
          console.log('Description:', incident.description);
          console.log('Area:', incident.area);
          console.log('Enhanced Location:', incident.enhancedLocation);
          console.log('Surface Type:', incident.surfaceType);
          console.log('Billing:', incident.billing);
          console.log('Rate:', incident.rate);
          console.log('Materials Used:', incident.materialsUsed);
          console.log('Status:', incident.status);
          console.log('Start Time:', incident.startTime);
          console.log('End Time:', incident.endTime);
          console.log('Created At:', incident.createdAt);
          console.log('===============================');

          incidents.push(incident);
        }
      });

      if (incidents.length === 0) {
        alert('No incidents found for this client in the selected date range');
        setGenerating(false);
        return;
      }

      // Generate PDF with effective template (merged team + client overrides)
      const reportPeriod = `${new Date(startDate).toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}`;
      generateInvoicePDF(client, incidents, reportPeriod, effectiveTemplate);

    } catch (error) {
      console.error('Error generating invoice:', error);
      alert('Failed to generate invoice. Please try again.');
    } finally {
      setGenerating(false);
    }
  };

  if (loading) {
    return (
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow dark:shadow-gray-700/20 p-6">
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600 dark:text-gray-400">Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow dark:shadow-gray-700/20 p-6">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-2">Generate Invoice</h3>
        <p className="text-sm text-gray-600 dark:text-gray-400">
          Create customized invoices from incident data
        </p>
      </div>

      {/* Two Column Layout: Form + Preview */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Left: Generate Invoice Form */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow dark:shadow-gray-700/20 p-6">
          <div className="flex justify-between items-center mb-6">
            <h4 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Generate Invoice</h4>
            <button
              className="px-4 py-2 bg-blue-600 text-white text-sm font-semibold rounded-lg hover:bg-blue-700 transition-colors"
              onClick={() => setShowTemplateEditor(true)}
            >
              Customize
            </button>
          </div>

          <div className="space-y-6">
            {/* Client Selection */}
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Select Client
              </label>
              <select
                value={selectedClient}
                onChange={(e) => setSelectedClient(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">-- Select a client --</option>
                {clients.map((client) => (
                  <option key={client.id} value={client.id}>
                    {client.name}
                  </option>
                ))}
              </select>
            </div>

            {/* Date Selection */}
            {!useCustomDateRange ? (
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Select Month
                </label>
                <select
                  value={selectedMonthYear}
                  onChange={(e) => setSelectedMonthYear(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  disabled={!selectedClient || availableMonths.length === 0}
                >
                  <option value="">-- Select a month --</option>
                  {availableMonths.map((monthYear) => (
                    <option key={`${monthYear.year}-${monthYear.month}`} value={`${monthYear.year}-${String(monthYear.month).padStart(2, '0')}`}>
                      {monthYear.display}
                    </option>
                  ))}
                </select>
              </div>
            ) : (
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Start Date
                  </label>
                  <input
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    End Date
                  </label>
                  <input
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
              </div>
            )}

            {/* Toggle Custom Date Range */}
            <div>
              <button
                type="button"
                onClick={() => setUseCustomDateRange(!useCustomDateRange)}
                className="text-sm text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 underline"
              >
                {useCustomDateRange ? 'Use month selection' : 'Use custom date range'}
              </button>
            </div>

            {/* Generate Button */}
            <div>
              <button
                onClick={handleGenerateInvoice}
                disabled={
                  !selectedClient ||
                  generating ||
                  (useCustomDateRange ? (!startDate || !endDate) : !selectedMonthYear)
                }
                className="w-full px-6 py-3 bg-blue-600 text-white font-semibold rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
              >
                {generating ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    <span>Generating...</span>
                  </>
                ) : (
                  <span>Generate Invoice PDF</span>
                )}
              </button>
            </div>
          </div>
        </div>

        {/* Right: Invoice Preview */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow dark:shadow-gray-700/20 p-6">
          <h4 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-6">Invoice Preview</h4>
          <div className="flex justify-center items-start overflow-auto" style={{ maxHeight: '800px' }}>
            <div style={{ width: '8.5in', height: '11in', transform: 'scale(0.7)', transformOrigin: 'top center' }}>
              <InvoicePreview
                template={template}
                client={previewClient}
                incidents={previewIncidents}
              />
            </div>
          </div>
        </div>
      </div>

      {/* Template Editor Modal */}
      {showTemplateEditor && (
        <InvoiceTemplateEditor
          onClose={() => setShowTemplateEditor(false)}
          onSave={(updatedTemplate) => {
            setTemplate(updatedTemplate);
            setShowTemplateEditor(false);
          }}
        />
      )}
    </div>
  );
}

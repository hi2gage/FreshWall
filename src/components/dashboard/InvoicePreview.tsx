'use client';

import { InvoiceTemplate, generateInvoiceNumber } from '@/types/invoice';

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

interface InvoicePreviewProps {
  template: InvoiceTemplate;
  client?: Client | null;
  incidents?: Incident[];
}

// Sample data for preview
const SAMPLE_CLIENT = {
  name: 'City of Bozeman',
};

const SAMPLE_INCIDENTS_RAW = [
  {
    date: 'Nov 3, 2025',
    dateValue: new Date('2025-11-03'),
    description: 'Graffiti Removal at 115, E Olive St, Bozeman, MT, concrete',
    location: '115, E Olive St, Bozeman, MT',
    qty: 3,
    rate: 80.00,
    amount: 240.00,
  },
  {
    date: 'Sep 26, 2025',
    dateValue: new Date('2025-09-26'),
    description: 'Graffiti Removal at 500–550, W Dickerson St, Bozeman, MT, metal',
    location: '500–550, W Dickerson St, Bozeman, MT',
    qty: 0.5,
    rate: 80.00,
    amount: 40.00,
  },
  {
    date: 'Oct 21, 2025',
    dateValue: new Date('2025-10-21'),
    description: 'Graffiti Removal at 443, E Main St, Bozeman, MT, other',
    location: '443, E Main St, Bozeman, MT',
    qty: 1.5,
    rate: 85.00,
    amount: 127.50,
  },
];

function sortSampleIncidents(incidents: typeof SAMPLE_INCIDENTS_RAW, sortBy?: string, sortOrder?: 'asc' | 'desc') {
  console.log('Sorting incidents by:', sortBy, 'order:', sortOrder);

  const sorted = [...incidents].sort((a, b) => {
    let aValue: any;
    let bValue: any;

    switch (sortBy) {
      case 'date':
        aValue = a.dateValue.getTime();
        bValue = b.dateValue.getTime();
        break;
      case 'description':
      case 'location':
        aValue = a.location;
        bValue = b.location;
        break;
      case 'surfaceType':
      case 'area':
        // Sample data doesn't have these as separate fields, sort by location as fallback
        aValue = a.location;
        bValue = b.location;
        break;
      case 'quantity':
        aValue = a.qty;
        bValue = b.qty;
        break;
      case 'rate':
        aValue = a.rate;
        bValue = b.rate;
        break;
      case 'amount':
        aValue = a.amount;
        bValue = b.amount;
        break;
      case 'duration':
      case 'status':
      case 'notes':
        // Not available in sample data, default to date
        aValue = a.dateValue.getTime();
        bValue = b.dateValue.getTime();
        break;
      default:
        // Default to date sorting
        aValue = a.dateValue.getTime();
        bValue = b.dateValue.getTime();
        break;
    }

    // Handle string comparisons
    if (typeof aValue === 'string' && typeof bValue === 'string') {
      const comparison = aValue.localeCompare(bValue);
      return sortOrder === 'desc' ? -comparison : comparison;
    }

    // Handle numeric comparisons
    const comparison = aValue - bValue;
    return sortOrder === 'desc' ? -comparison : comparison;
  });

  console.log('Sorted incidents:', sorted.map(i => ({ date: i.date, qty: i.qty, amount: i.amount })));
  return sorted;
}

export default function InvoicePreview({ template, client, incidents }: InvoicePreviewProps) {
  // Convert real incidents to preview format
  const convertRealIncidents = (realIncidents: Incident[], clientData: Client | null) => {
    return realIncidents.map((incident) => {
      console.log('Converting incident:', {
        id: incident.id,
        billing: incident.billing,
        clientDefaults: clientData?.defaults,
        rate: incident.rate,
        area: incident.area,
        startTime: incident.startTime,
        endTime: incident.endTime,
      });

      // Use incident billing if available, otherwise use client defaults
      const billing = incident.billing || clientData?.defaults;

      // Calculate quantity and amount based on billing method
      let qty = 0;
      let rate = 0;
      let amount = 0;

      if (billing) {
        // Get rate from incident-specific billing, or client defaults, or fallback to 80
        rate = incident.billing?.amountPerUnit || incident.rate || clientData?.defaults?.amountPerUnit || 80;

        switch (billing.billingMethod) {
          case 'time':
            if (incident.startTime && incident.endTime) {
              const start = incident.startTime.toDate ? incident.startTime.toDate() : new Date(incident.startTime);
              const end = incident.endTime.toDate ? incident.endTime.toDate() : new Date(incident.endTime);
              const hours = (end.getTime() - start.getTime()) / (1000 * 60 * 60);

              // Apply time rounding if configured
              let duration = Math.max(0.5, hours);
              if (clientData?.defaults?.timeRounding?.roundingIncrement) {
                const increment = clientData.defaults.timeRounding.roundingIncrement;
                duration = Math.ceil(duration / increment) * increment;
              }

              qty = Math.max(billing.minimumBillableQuantity, duration);
            }
            break;
          case 'square_footage':
            qty = Math.max(billing.minimumBillableQuantity, incident.area || 0);
            break;
          case 'custom':
            qty = billing.minimumBillableQuantity;
            break;
        }

        amount = qty * rate;
      } else if (incident.rate) {
        // Legacy fallback
        rate = incident.rate;
        qty = incident.area || 0;
        amount = qty * rate;
      }

      console.log('Calculated values:', { qty, rate, amount });

      const incidentDate = incident.createdAt?.toDate ? incident.createdAt.toDate() : new Date(incident.createdAt);
      const location = incident.enhancedLocation?.address || 'Unknown location';
      const surfaceType = incident.surfaceType || '';

      return {
        date: incidentDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
        dateValue: incidentDate,
        description: `${template.descriptionPrefix || 'Graffiti Removal at'} ${location}${surfaceType ? ', ' + surfaceType : ''}`,
        location,
        qty,
        rate,
        amount,
      };
    });
  };

  // Use real data if provided, otherwise show empty invoice
  const displayClient = client || { name: '' };
  const rawIncidents = incidents !== undefined ? convertRealIncidents(incidents, client || null) : [];

  // Sort incidents based on template settings
  const sortedIncidents = sortSampleIncidents(rawIncidents, template.sortBy, template.sortOrder);

  // Generate invoice number based on format
  const invoiceNumber = generateInvoiceNumber(template.invoiceNumberFormat, 1, new Date());
  const fullInvoiceNumber = `${template.invoicePrefix}-${invoiceNumber}`;

  // Calculate subtotal from sorted incidents
  const subtotal = sortedIncidents.reduce((sum, inc) => sum + inc.amount, 0);
  const taxAmount = template.showTax ? subtotal * (template.taxRate || 0) : 0;
  const total = subtotal + taxAmount;

  return (
    <div className="bg-white shadow-lg p-8 text-gray-900 font-sans text-sm" style={{ width: '8.5in', height: '11in' }}>
      {/* Header Section */}
      <div className="flex justify-between mb-6">
        {/* Company Info */}
        <div className="text-left">
          <div className="text-lg font-bold mb-1">{template.companyName}</div>
          {template.showCompanyAddress && template.companyAddress.map((line, idx) => (
            <div key={idx} className="text-xs">{line}</div>
          ))}
          {template.showCompanyWebsite && template.companyWebsite && (
            <div className="text-xs">{template.companyWebsite}</div>
          )}
          {template.showCompanyPhone && template.companyPhone && (
            <div className="text-xs">{template.companyPhone}</div>
          )}
        </div>

        {/* Invoice Title & Details */}
        <div className="text-right">
          <div className="text-3xl font-bold mb-2">Invoice</div>
          <div className="text-xs space-y-1">
            <div className="flex justify-between gap-8">
              <span>Date</span>
              <span>11/3/2025</span>
            </div>
            <div className="flex justify-between gap-8">
              <span>Invoice #</span>
              <span>{fullInvoiceNumber}</span>
            </div>
            <div className="flex justify-between gap-8">
              <span>PO #</span>
              <span></span>
            </div>
            <div className="flex justify-between gap-8">
              <span>Terms</span>
              <span>{template.paymentTerms}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Bill To */}
      <div className="mb-4">
        <div className="text-sm font-bold mb-1">Bill To</div>
        <div className="text-sm">{displayClient.name}</div>
      </div>

      {/* Line Items Table */}
      <table className="w-full border-collapse border border-gray-300 text-xs mb-4">
        <thead>
          <tr className="bg-gray-200">
            {template.lineItemColumns
              .filter((col) => col.isVisible)
              .sort((a, b) => a.order - b.order)
              .map((column) => (
                <th
                  key={column.id}
                  className={`border border-gray-300 px-2 py-1 ${
                    column.type === 'description' ? 'text-left' :
                    column.type === 'rate' || column.type === 'amount' ? 'text-right' :
                    'text-center'
                  }`}
                >
                  {column.label}
                </th>
              ))}
          </tr>
        </thead>
        <tbody>
          {sortedIncidents.map((incident, idx) => (
            <tr key={idx}>
              {template.lineItemColumns
                .filter((col) => col.isVisible)
                .sort((a, b) => a.order - b.order)
                .map((column) => {
                  let value = '';

                  switch (column.type) {
                    case 'date':
                      value = incident.date;
                      break;
                    case 'description':
                      value = template.descriptionPrefix ?
                        incident.description.replace('Graffiti Removal at', template.descriptionPrefix) :
                        incident.description;
                      break;
                    case 'location':
                      value = incident.location;
                      break;
                    case 'quantity':
                      value = incident.qty.toString();
                      break;
                    case 'rate':
                      value = `$${incident.rate.toFixed(2)}`;
                      break;
                    case 'amount':
                      value = `$${incident.amount.toFixed(2)}`;
                      break;
                    default:
                      value = 'N/A';
                  }

                  return (
                    <td
                      key={column.id}
                      className={`border border-gray-300 px-2 py-1 ${
                        column.type === 'description' || column.type === 'location' ? 'text-left' :
                        column.type === 'rate' || column.type === 'amount' ? 'text-right' :
                        'text-center'
                      }`}
                    >
                      {value}
                    </td>
                  );
                })}
            </tr>
          ))}
        </tbody>
      </table>

      {/* Totals */}
      <div className="flex justify-end mb-6">
        <div className="w-64 space-y-1 text-xs">
          {template.showTax && (
            <>
              <div className="flex justify-between">
                <span>Subtotal</span>
                <span>${subtotal.toFixed(2)}</span>
              </div>
              <div className="flex justify-between">
                <span>{template.taxLabel || 'Tax'} ({((template.taxRate || 0) * 100).toFixed(1)}%)</span>
                <span>${taxAmount.toFixed(2)}</span>
              </div>
            </>
          )}
          <div className="flex justify-between font-bold text-base border-t pt-1">
            <span>Total</span>
            <span>${total.toFixed(2)}</span>
          </div>
        </div>
      </div>

      {/* Footer Messages */}
      <div className="space-y-3 text-xs">
        {template.footerThankYouMessage && (
          <div>{template.footerThankYouMessage}</div>
        )}

        {template.footerShowRemittanceInfo && (
          <div>
            <div className="font-bold mb-1">Please remit payment to:</div>
            <div>{template.companyName}</div>
            {template.companyAddress.map((line, idx) => (
              <div key={idx}>{line}</div>
            ))}
          </div>
        )}

        {template.footerClosingMessage && (
          <div className="font-bold mt-2">{template.footerClosingMessage}</div>
        )}
      </div>
    </div>
  );
}

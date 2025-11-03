import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
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

export function generateInvoicePDF(
  client: Client,
  incidents: Incident[],
  reportPeriod: string,
  template: InvoiceTemplate
) {
  const doc = new jsPDF();
  let yPosition = 20;

  // Company Header
  doc.setFontSize(16);
  doc.setFont('helvetica', 'bold');
  doc.text(template.companyName, 20, yPosition);
  yPosition += 8;

  // Company Details
  doc.setFontSize(10);
  doc.setFont('helvetica', 'normal');

  if (template.showCompanyAddress) {
    template.companyAddress.forEach((line) => {
      doc.text(line, 20, yPosition);
      yPosition += 5;
    });
  }

  if (template.showCompanyPhone && template.companyPhone) {
    doc.text(template.companyPhone, 20, yPosition);
    yPosition += 5;
  }

  if (template.showCompanyEmail && template.companyEmail) {
    doc.text(template.companyEmail, 20, yPosition);
    yPosition += 5;
  }

  if (template.showCompanyWebsite && template.companyWebsite) {
    doc.text(template.companyWebsite, 20, yPosition);
    yPosition += 5;
  }

  // Invoice Title (right side)
  doc.setFontSize(20);
  doc.setFont('helvetica', 'bold');
  doc.text('INVOICE', 200, 20, { align: 'right' });

  // Invoice Details (right side)
  doc.setFontSize(10);
  doc.setFont('helvetica', 'normal');
  const invoiceNumber = generateInvoiceNumber(template.invoiceNumberFormat, 1);
  doc.text(`Date: ${new Date().toLocaleDateString()}`, 200, 35, { align: 'right' });
  doc.text(`Invoice #: ${template.invoicePrefix}-${invoiceNumber}`, 200, 40, { align: 'right' });
  doc.text(`Terms: ${template.paymentTerms}`, 200, 45, { align: 'right' });

  // Bill To Section
  yPosition = Math.max(yPosition + 10, 60);
  doc.setFontSize(12);
  doc.setFont('helvetica', 'bold');
  doc.text('Bill To:', 20, yPosition);
  yPosition += 7;

  doc.setFontSize(10);
  doc.setFont('helvetica', 'normal');
  doc.text(client.name, 20, yPosition);
  yPosition += 15;

  // Prepare table data
  const tableData = incidents.map((incident) => {
    console.log('Processing incident for PDF:', incident); // Debug log
    const row: any[] = [];

    template.lineItemColumns
      .filter((col) => col.isVisible)
      .sort((a, b) => a.order - b.order)
      .forEach((column) => {
        let value = '';

        switch (column.type) {
          case 'date':
            const date = incident.createdAt?.toDate ? incident.createdAt.toDate() :
                        (incident.createdAt instanceof Date ? incident.createdAt : new Date(incident.createdAt));
            value = formatDate(date);
            break;
          case 'description':
            // Format like: "Graffiti Removal at [Location], [Surface Type]"
            const location = incident.enhancedLocation?.address || 'Unknown Location';
            const surface = incident.surfaceType ? `, ${incident.surfaceType}` : '';
            value = `Graffiti Removal at ${location}${surface}`;
            break;
          case 'location':
            value = incident.enhancedLocation?.address || 'Location not recorded';
            break;
          case 'surfaceType':
            value = incident.surfaceType || 'Not specified';
            break;
          case 'area':
            value = `${incident.area || 0} sq ft`;
            break;
          case 'quantity':
            const quantity = calculateQuantity(incident, client);
            value = formatQuantity(quantity);
            break;
          case 'rate':
            // Use client's default rate, or incident's rate, or $80 default
            const rate = incident.billing?.amountPerUnit || incident.rate || client.defaults?.amountPerUnit || 80;
            value = formatCurrency(rate);
            break;
          case 'amount':
            const total = calculateIncidentTotal(incident, client);
            value = formatCurrency(total);
            break;
          case 'duration':
            const duration = calculateDuration(incident);
            value = formatDuration(duration);
            break;
          case 'status':
            value = incident.status || 'Not specified';
            break;
          case 'notes':
            value = incident.materialsUsed || 'None';
            break;
        }

        console.log(`Column ${column.type}:`, value); // Debug log
        row.push(value);
      });

    return row;
  });

  // Table headers
  const tableHeaders = template.lineItemColumns
    .filter((col) => col.isVisible)
    .sort((a, b) => a.order - b.order)
    .map((col) => col.label);

  // Generate table
  autoTable(doc, {
    startY: yPosition,
    head: [tableHeaders],
    body: tableData,
    theme: 'striped',
    headStyles: {
      fillColor: [59, 130, 246], // Blue color
      textColor: 255,
      fontStyle: 'bold',
      fontSize: 10,
    },
    styles: {
      fontSize: 9,
      cellPadding: 3,
    },
    alternateRowStyles: {
      fillColor: [249, 250, 251],
    },
  });

  // Get final Y position after table
  const finalY = (doc as any).lastAutoTable.finalY + 10;

  // Calculate totals
  const subtotal = incidents.reduce((sum, incident) => sum + calculateIncidentTotal(incident, client), 0);
  const taxAmount = template.showTax ? subtotal * (template.taxRate || 0) : 0;
  const total = subtotal + taxAmount;

  // Totals section (right-aligned)
  let totalsY = finalY;

  if (template.showTax) {
    doc.text(`Subtotal: ${formatCurrency(subtotal)}`, 200, totalsY, { align: 'right' });
    totalsY += 7;
    doc.text(
      `${template.taxLabel || 'Tax'} (${((template.taxRate || 0) * 100).toFixed(1)}%): ${formatCurrency(taxAmount)}`,
      200,
      totalsY,
      { align: 'right' }
    );
    totalsY += 7;
  }

  doc.setFontSize(12);
  doc.setFont('helvetica', 'bold');
  doc.text(`Total: ${formatCurrency(total)}`, 200, totalsY, { align: 'right' });

  // Footer
  totalsY += 20;

  if (template.footerMessage) {
    doc.setFontSize(10);
    doc.setFont('helvetica', 'italic');
    doc.text(template.footerMessage, 105, totalsY, { align: 'center' });
    totalsY += 10;
  }

  if (template.footerShowRemittanceInfo) {
    doc.setFontSize(9);
    doc.setFont('helvetica', 'bold');
    doc.text('Please remit payment to:', 20, totalsY);
    totalsY += 5;

    doc.setFont('helvetica', 'normal');
    doc.text(template.companyName, 20, totalsY);
    totalsY += 5;

    template.companyAddress.forEach((line) => {
      doc.text(line, 20, totalsY);
      totalsY += 5;
    });

    // Add "Thank you for your business!" at the bottom
    totalsY += 5;
    doc.setFont('helvetica', 'italic');
    doc.text('Thank you for your business!', 20, totalsY);
  }

  // Save the PDF
  const fileName = `Invoice_${client.name.replace(/\s+/g, '_')}_${reportPeriod.replace(/\s+/g, '_')}.pdf`;
  doc.save(fileName);
}

// Helper functions
function calculateQuantity(incident: Incident, client: Client): number {
  // Use incident billing if available, otherwise use client defaults
  const billing = incident.billing || client.defaults;

  if (billing) {
    switch (billing.billingMethod) {
      case 'time':
        let duration = calculateDuration(incident);

        // Apply time rounding if configured
        if (client.defaults?.timeRounding?.roundingIncrement) {
          const increment = client.defaults.timeRounding.roundingIncrement;
          duration = Math.ceil(duration / increment) * increment;
          console.log('Applied time rounding - Original:', calculateDuration(incident), 'Rounded:', duration, 'Increment:', increment);
        }

        return Math.max(billing.minimumBillableQuantity, duration);
      case 'square_footage':
        return Math.max(billing.minimumBillableQuantity, incident.area);
      case 'custom':
        return billing.minimumBillableQuantity;
    }
  }

  // Legacy: calculate hours
  return calculateDuration(incident);
}

function calculateDuration(incident: Incident): number {
  if (!incident.startTime || !incident.endTime) return 0;

  let start: Date, end: Date;

  // Handle Firestore Timestamp or Date objects
  if (incident.startTime.toDate) {
    start = incident.startTime.toDate();
  } else if (incident.startTime instanceof Date) {
    start = incident.startTime;
  } else {
    start = new Date(incident.startTime);
  }

  if (incident.endTime.toDate) {
    end = incident.endTime.toDate();
  } else if (incident.endTime instanceof Date) {
    end = incident.endTime;
  } else {
    end = new Date(incident.endTime);
  }

  const durationMs = end.getTime() - start.getTime();
  const hours = durationMs / (1000 * 60 * 60);

  return Math.max(0.5, hours); // Minimum 0.5 hours
}

function calculateIncidentTotal(incident: Incident, client: Client): number {
  const quantity = calculateQuantity(incident, client);
  // Use client's default rate if no incident-specific rate
  const rate = incident.billing?.amountPerUnit || incident.rate || client.defaults?.amountPerUnit || 80;

  console.log('Calculating total - Quantity:', quantity, 'Rate:', rate, 'Total:', quantity * rate);

  return quantity * rate;
}

function formatDate(date: Date | undefined): string {
  if (!date) return 'N/A';
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
}

function formatQuantity(value: number): string {
  if (value === Math.floor(value)) {
    return value.toString();
  }
  return value.toFixed(1);
}

function formatCurrency(amount: number): string {
  return `$${amount.toFixed(2)}`;
}

function formatDuration(hours: number): string {
  const totalMinutes = Math.round(hours * 60);
  const h = Math.floor(totalMinutes / 60);
  const m = totalMinutes % 60;

  if (h > 0) {
    return `${h}h ${m}m`;
  } else {
    return `${m}m`;
  }
}

// Invoice Template Types for FreshWall Web

export interface InvoiceTemplate {
  id?: string;

  // Company Information
  companyName: string;
  companyAddress: string[];
  companyPhone?: string;
  companyEmail?: string;
  companyWebsite?: string;
  companyLogo?: string; // URL to logo image

  // Invoice Settings
  invoicePrefix: string; // e.g., "INV", "FW"
  invoiceNumberFormat: InvoiceNumberFormat;
  paymentTerms: string; // e.g., "Net 30", "Due upon receipt"
  taxRate?: number; // Optional tax percentage (e.g., 0.08 for 8%)
  taxLabel?: string; // e.g., "Sales Tax", "VAT"

  // Display Options
  showLogo: boolean;
  showCompanyAddress: boolean;
  showCompanyPhone: boolean;
  showCompanyEmail: boolean;
  showCompanyWebsite: boolean;
  showTax: boolean;

  // Line Item Configuration
  lineItemColumns: LineItemColumn[];
  showDetailedNotes: boolean;
  showPhotos: boolean;
  photosPerIncident: number; // Max number of photos to include per incident

  // Footer Content
  footerThankYouMessage?: string; // e.g., "It has been our pleasure working with you!"
  footerShowRemittanceInfo: boolean;
  footerClosingMessage?: string; // e.g., "Thank you for your business!"

  // Description Customization
  descriptionPrefix?: string; // e.g., "Graffiti Removal at" - prefix for incident descriptions
  descriptionFields: DescriptionField[]; // Fields to include in description and their order

  // Sorting
  sortBy?: ColumnType; // Which column to sort by
  sortOrder?: 'asc' | 'desc'; // Sort direction

  // Timestamps
  createdAt: Date;
  updatedAt: Date;
}

export type InvoiceNumberFormat =
  | 'dateSequential'     // YYYYMMDD-001
  | 'yearMonthSequential' // YYMM-001
  | 'sequential'         // 001, 002, 003
  | 'dateOnly';          // YYYYMMDD

export interface LineItemColumn {
  id: string;
  type: ColumnType;
  label: string;
  width: ColumnWidth;
  isVisible: boolean;
  order: number;
}

export type ColumnType =
  | 'date'
  | 'description'
  | 'location'
  | 'surfaceType'
  | 'area'
  | 'quantity'
  | 'rate'
  | 'amount'
  | 'duration'
  | 'status'
  | 'notes';

export type ColumnWidth =
  | { type: 'auto' }
  | { type: 'flexible' }
  | { type: 'fixed'; value: number };

export interface DescriptionField {
  id: string;
  type: DescriptionFieldType;
  label: string;
  isVisible: boolean;
  order: number;
  separator?: string; // Separator to use after this field (e.g., ", ", " - ", " at ")
}

export type DescriptionFieldType =
  | 'location'
  | 'surfaceType'
  | 'area'
  | 'status'
  | 'notes';

// Default Invoice Template
export const DEFAULT_INVOICE_TEMPLATE: InvoiceTemplate = {
  companyName: 'Clean Slate Group',
  companyAddress: ['34 Outlier Way', 'Bozeman, MT 59715'],
  companyPhone: '1-800-328-9974',
  companyEmail: undefined,
  companyWebsite: 'www.cleanslategroup.org',
  companyLogo: undefined,
  invoicePrefix: 'INV',
  invoiceNumberFormat: 'dateSequential',
  paymentTerms: 'Net 30',
  taxRate: undefined,
  taxLabel: undefined,
  showLogo: false,
  showCompanyAddress: true,
  showCompanyPhone: true,
  showCompanyEmail: false,
  showCompanyWebsite: true,
  showTax: false,
  lineItemColumns: [
    { id: '1', type: 'date', label: 'Date', width: { type: 'fixed', value: 60 }, isVisible: true, order: 0 },
    { id: '2', type: 'description', label: 'Description', width: { type: 'flexible' }, isVisible: true, order: 1 },
    { id: '3', type: 'quantity', label: 'Qty', width: { type: 'fixed', value: 50 }, isVisible: true, order: 2 },
    { id: '4', type: 'rate', label: 'Rate', width: { type: 'fixed', value: 60 }, isVisible: true, order: 3 },
    { id: '5', type: 'amount', label: 'Amount', width: { type: 'fixed', value: 70 }, isVisible: true, order: 4 },
  ],
  showDetailedNotes: false,
  showPhotos: false,
  photosPerIncident: 2,
  footerThankYouMessage: 'It has been our pleasure working with you!',
  footerShowRemittanceInfo: true,
  footerClosingMessage: 'Thank you for your business!',
  descriptionPrefix: 'Graffiti Removal at',
  descriptionFields: [
    { id: '1', type: 'location', label: 'Location', isVisible: true, order: 0, separator: ', ' },
    { id: '2', type: 'surfaceType', label: 'Surface Type', isVisible: true, order: 1, separator: '' },
  ],
  sortBy: 'date',
  sortOrder: 'asc',
  createdAt: new Date(),
  updatedAt: new Date(),
};

// Helper functions for invoice number generation
export function generateInvoiceNumber(format: InvoiceNumberFormat, sequenceNumber?: number, date: Date = new Date()): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const seq = String(sequenceNumber || 1).padStart(3, '0');

  switch (format) {
    case 'dateSequential':
      return `${year}${month}${day}-${seq}`;
    case 'yearMonthSequential':
      return `${String(year).slice(-2)}${month}-${seq}`;
    case 'sequential':
      return seq;
    case 'dateOnly':
      return `${year}${month}${day}`;
  }
}

export function getInvoiceNumberFormatExample(format: InvoiceNumberFormat): string {
  const now = new Date();
  return generateInvoiceNumber(format, 1, now);
}

export const INVOICE_NUMBER_FORMAT_OPTIONS: Array<{ value: InvoiceNumberFormat; label: string; example: string }> = [
  { value: 'dateSequential', label: 'Date + Sequential', example: getInvoiceNumberFormatExample('dateSequential') },
  { value: 'yearMonthSequential', label: 'Year/Month + Sequential', example: getInvoiceNumberFormatExample('yearMonthSequential') },
  { value: 'sequential', label: 'Sequential Only', example: getInvoiceNumberFormatExample('sequential') },
  { value: 'dateOnly', label: 'Date Only', example: getInvoiceNumberFormatExample('dateOnly') },
];

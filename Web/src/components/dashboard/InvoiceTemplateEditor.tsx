'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { firestore } from '@/lib/firebase';
import { doc, getDoc, setDoc, getDocs, collection } from 'firebase/firestore';
import { InvoiceTemplate, DEFAULT_INVOICE_TEMPLATE, INVOICE_NUMBER_FORMAT_OPTIONS } from '@/types/invoice';

interface InvoiceTemplateEditorProps {
  onClose: () => void;
  onSave: (template: InvoiceTemplate) => void;
}

export default function InvoiceTemplateEditor({ onClose, onSave }: InvoiceTemplateEditorProps) {
  const { user } = useAuth();
  const [template, setTemplate] = useState<InvoiceTemplate>(DEFAULT_INVOICE_TEMPLATE);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    loadTemplate();
  }, [user]);

  const loadTemplate = async () => {
    if (!user) return;

    try {
      setLoading(true);

      // Get teamId
      let idTokenResult = await user.getIdTokenResult();
      let teamId = idTokenResult.claims?.teamId;

      if (!teamId) {
        idTokenResult = await user.getIdTokenResult(true);
        teamId = idTokenResult.claims?.teamId;
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
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    if (!user) return;

    try {
      setSaving(true);

      // Get teamId
      let idTokenResult = await user.getIdTokenResult();
      let teamId = idTokenResult.claims?.teamId;

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
        // Serialize the template for Firestore, removing undefined values
        const { createdAt, updatedAt, ...templateData } = template;

        // Remove all undefined fields (Firestore doesn't accept undefined)
        const cleanedTemplate = Object.fromEntries(
          Object.entries(templateData).filter(([_, value]) => value !== undefined)
        );

        const updatedTemplate = {
          ...cleanedTemplate,
          createdAt: createdAt,
          updatedAt: new Date(),
        };

        console.log('Saving template to Firestore:', updatedTemplate);
        await setDoc(doc(firestore, `teams/${teamId}/invoiceTemplate/default`), updatedTemplate);

        onSave({ ...updatedTemplate, createdAt: new Date(createdAt), updatedAt: new Date() });
        alert('Template saved successfully!');
        onClose();
      } else {
        alert('No team ID found. Please try logging out and back in.');
      }
    } catch (error) {
      console.error('Error saving template:', error);
      alert('Failed to save template. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white dark:bg-gray-800 rounded-lg p-6">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600 dark:text-gray-400">Loading template...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 overflow-y-auto">
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-4xl w-full mx-4 my-8">
        {/* Header */}
        <div className="flex justify-between items-center p-6 border-b border-gray-200 dark:border-gray-700">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Customize Invoice Template</h2>
          <button onClick={onClose} className="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200">
            ✕
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6 max-h-[calc(100vh-200px)] overflow-y-auto">
          {/* Company Information */}
          <section>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Company Information</h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Company Name
                </label>
                <input
                  type="text"
                  value={template.companyName}
                  onChange={(e) => setTemplate({ ...template, companyName: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Address Line 1
                </label>
                <input
                  type="text"
                  value={template.companyAddress[0] || ''}
                  onChange={(e) => setTemplate({
                    ...template,
                    companyAddress: [e.target.value, template.companyAddress[1] || '']
                  })}
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Address Line 2
                </label>
                <input
                  type="text"
                  value={template.companyAddress[1] || ''}
                  onChange={(e) => setTemplate({
                    ...template,
                    companyAddress: [template.companyAddress[0] || '', e.target.value]
                  })}
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                />
              </div>

              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Phone
                  </label>
                  <input
                    type="text"
                    value={template.companyPhone || ''}
                    onChange={(e) => setTemplate({ ...template, companyPhone: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Website
                  </label>
                  <input
                    type="text"
                    value={template.companyWebsite || ''}
                    onChange={(e) => setTemplate({ ...template, companyWebsite: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                  />
                </div>
              </div>
            </div>
          </section>

          {/* Invoice Settings */}
          <section>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Invoice Settings</h3>
            <div className="space-y-4">
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Invoice Prefix
                  </label>
                  <input
                    type="text"
                    value={template.invoicePrefix}
                    onChange={(e) => setTemplate({ ...template, invoicePrefix: e.target.value })}
                    placeholder="INV"
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Number Format
                  </label>
                  <select
                    value={template.invoiceNumberFormat}
                    onChange={(e) => setTemplate({ ...template, invoiceNumberFormat: e.target.value as any })}
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                  >
                    {INVOICE_NUMBER_FORMAT_OPTIONS.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label} ({option.example})
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Payment Terms
                </label>
                <input
                  type="text"
                  value={template.paymentTerms}
                  onChange={(e) => setTemplate({ ...template, paymentTerms: e.target.value })}
                  placeholder="Net 30"
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                />
              </div>
            </div>
          </section>

          {/* Tax Settings */}
          <section>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Tax Settings</h3>
            <div className="space-y-4">
              <div className="flex items-center">
                <input
                  type="checkbox"
                  checked={template.showTax}
                  onChange={(e) => setTemplate({ ...template, showTax: e.target.checked })}
                  className="mr-2"
                />
                <label className="text-sm text-gray-700 dark:text-gray-300">
                  Enable tax calculation
                </label>
              </div>

              {template.showTax && (
                <div className="grid md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Tax Rate (%)
                    </label>
                    <input
                      type="number"
                      step="0.01"
                      value={(template.taxRate || 0) * 100}
                      onChange={(e) => setTemplate({ ...template, taxRate: parseFloat(e.target.value) / 100 })}
                      className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                      Tax Label
                    </label>
                    <input
                      type="text"
                      value={template.taxLabel || ''}
                      onChange={(e) => setTemplate({ ...template, taxLabel: e.target.value })}
                      placeholder="Sales Tax"
                      className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                    />
                  </div>
                </div>
              )}
            </div>
          </section>

          {/* Line Item Sorting */}
          <section>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Line Item Sorting</h3>
            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Sort By Column
                </label>
                <select
                  value={template.sortBy || 'date'}
                  onChange={(e) => setTemplate({ ...template, sortBy: e.target.value as any })}
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                >
                  <option value="date">Date</option>
                  <option value="description">Description</option>
                  <option value="location">Location</option>
                  <option value="surfaceType">Surface Type</option>
                  <option value="area">Area</option>
                  <option value="quantity">Quantity</option>
                  <option value="rate">Rate</option>
                  <option value="amount">Amount</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Sort Order
                </label>
                <select
                  value={template.sortOrder || 'asc'}
                  onChange={(e) => setTemplate({ ...template, sortOrder: e.target.value as 'asc' | 'desc' })}
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                >
                  <option value="asc">Ascending (A-Z, 0-9, earliest first)</option>
                  <option value="desc">Descending (Z-A, 9-0, latest first)</option>
                </select>
              </div>
            </div>
          </section>

          {/* Description Customization */}
          <section>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Description Format</h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Description Prefix
                </label>
                <input
                  type="text"
                  value={template.descriptionPrefix || ''}
                  onChange={(e) => setTemplate({ ...template, descriptionPrefix: e.target.value })}
                  placeholder="Graffiti Removal at"
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                />
                <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                  This will appear before the location in line item descriptions (e.g., "Graffiti Removal at 123 Main St")
                </p>
              </div>
            </div>
          </section>

          {/* Footer */}
          <section>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Footer Messages</h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Thank You Message
                </label>
                <input
                  type="text"
                  value={template.footerThankYouMessage || ''}
                  onChange={(e) => setTemplate({ ...template, footerThankYouMessage: e.target.value })}
                  placeholder="It has been our pleasure working with you!"
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                />
                <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                  Appears after the total amount
                </p>
              </div>

              <div className="flex items-center">
                <input
                  type="checkbox"
                  checked={template.footerShowRemittanceInfo}
                  onChange={(e) => setTemplate({ ...template, footerShowRemittanceInfo: e.target.checked })}
                  className="mr-2"
                />
                <label className="text-sm text-gray-700 dark:text-gray-300">
                  Show "Please remit payment to:" section
                </label>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Closing Message
                </label>
                <input
                  type="text"
                  value={template.footerClosingMessage || ''}
                  onChange={(e) => setTemplate({ ...template, footerClosingMessage: e.target.value })}
                  placeholder="Thank you for your business!"
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                />
                <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                  Appears at the very end of the invoice
                </p>
              </div>
            </div>
          </section>
        </div>

        {/* Actions */}
        <div className="flex justify-end space-x-4 p-6 border-t border-gray-200 dark:border-gray-700">
          <button
            onClick={onClose}
            className="px-4 py-2 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-md"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            disabled={saving}
            className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
          >
            {saving ? 'Saving...' : 'Save Template'}
          </button>
        </div>
      </div>
    </div>
  );
}

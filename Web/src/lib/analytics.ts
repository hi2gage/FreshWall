'use client';

import { addDoc, collection, serverTimestamp } from 'firebase/firestore';
import { firestore } from './firebase';

type AnalyticsPayload = Record<string, unknown>;

async function writeEvent(name: string, data: AnalyticsPayload) {
  try {
    await addDoc(collection(firestore, 'analytics_events'), {
      name,
      data,
      path: typeof window !== 'undefined' ? window.location.pathname : undefined,
      search: typeof window !== 'undefined' ? window.location.search : undefined,
      referrer: typeof document !== 'undefined' ? document.referrer : undefined,
      userAgent: typeof navigator !== 'undefined' ? navigator.userAgent : undefined,
      timestamp: serverTimestamp()
    });
  } catch (error) {
    console.error('Failed to record analytics event', error);
  }
}

export async function logAnalyticsEvent(name: string, data: AnalyticsPayload = {}) {
  // Avoid logging during server-side rendering
  if (typeof window === 'undefined') {
    return;
  }

  await writeEvent(name, data);
}

export async function logDemoClick(source: string, additional?: AnalyticsPayload) {
  await logAnalyticsEvent('demo_click', {
    source,
    ...additional
  });
}

export async function logDemoPageView(source?: string | null) {
  await logAnalyticsEvent('demo_page_view', {
    source: source || 'unknown'
  });
}

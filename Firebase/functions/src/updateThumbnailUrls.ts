import { onCustomEventPublished } from 'firebase-functions/v2/eventarc';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { logger } from 'firebase-functions/v2';

/**
 * Cloud Function that listens to Firebase Storage Resize Images extension events
 * and updates Firestore incident documents with thumbnail URLs.
 *
 * Triggers on: firebase.extensions.storage-resize-images.v1.onSuccess
 * Updates: incident documents in /teams/{teamId}/incidents/{incidentId}
 */
export const updateThumbnailUrls = onCustomEventPublished(
  'firebase.extensions.storage-resize-images.v1.onSuccess',
  async (event) => {
    const { data } = event;

    logger.info('Thumbnail generation success event received', { data });

    try {
      // Extract information from the event data
      const { bucket, name: thumbnailPath } = data;

      if (!thumbnailPath || !thumbnailPath.includes('_100x100')) {
        logger.info('Event not for a thumbnail, skipping', { thumbnailPath });
        return;
      }

      // Parse the thumbnail path to get the original path and incident info
      // Example: teams/teamId/incidents/incidentId/before/filename_100x100.jpg
      const pathParts = thumbnailPath.split('/');

      if (pathParts.length < 6 || pathParts[0] !== 'teams' || pathParts[2] !== 'incidents') {
        logger.info('Path does not match expected incident photo structure', { thumbnailPath });
        return;
      }

      const teamId = pathParts[1];
      const incidentId = pathParts[3];
      const folder = pathParts[4]; // 'before' or 'after'
      const thumbnailFilename = pathParts[5];

      // Get the original filename by removing _100x100
      const originalFilename = thumbnailFilename.replace('_100x100', '');

      logger.info('Processing thumbnail for incident photo', {
        teamId,
        incidentId,
        folder,
        originalFilename,
        thumbnailFilename
      });

      // Get the thumbnail download URL
      const storage = getStorage();
      const thumbnailRef = storage.bucket(bucket).file(thumbnailPath);
      const [thumbnailUrl] = await thumbnailRef.getSignedUrl({
        action: 'read',
        expires: '03-01-2500', // Far future date
      });

      logger.info('Generated thumbnail URL', { thumbnailUrl });

      // Update the incident document in Firestore
      const firestore = getFirestore();
      const incidentRef = firestore
        .collection('teams')
        .doc(teamId)
        .collection('incidents')
        .doc(incidentId);

      const incidentDoc = await incidentRef.get();

      if (!incidentDoc.exists) {
        logger.error('Incident document not found', { teamId, incidentId });
        return;
      }

      const incidentData = incidentDoc.data();
      const photoArrayField = folder === 'before' ? 'beforePhotos' : 'afterPhotos';
      const photos = incidentData?.[photoArrayField] || [];

      // Find the photo that matches the original filename and update its thumbnailUrl
      let photoUpdated = false;
      const updatedPhotos = photos.map((photo: any) => {
        if (photo.url && photo.url.includes(originalFilename)) {
          logger.info('Found matching photo, updating thumbnailUrl', {
            photoId: photo.id,
            originalFilename
          });
          photoUpdated = true;
          return {
            ...photo,
            thumbnailUrl: thumbnailUrl
          };
        }
        return photo;
      });

      if (photoUpdated) {
        // Update the incident document with the new thumbnail URL
        await incidentRef.update({
          [photoArrayField]: updatedPhotos
        });

        logger.info('Successfully updated incident with thumbnail URL', {
          teamId,
          incidentId,
          folder,
          originalFilename
        });
      } else {
        logger.warn('Could not find matching photo in incident document', {
          teamId,
          incidentId,
          folder,
          originalFilename,
          availablePhotos: photos.map((p: any) => p.url)
        });
      }

    } catch (error) {
      logger.error('Error updating thumbnail URL in Firestore', error, {
        eventData: data
      });

      // Don't throw - we don't want to crash the function
      // The thumbnail generation already succeeded
    }
  }
);
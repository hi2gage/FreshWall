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

    logger.info('updateThumbnailUrls v0.4 - Looking for 200x200 JPEG thumbnails', {
      functionVersion: '2.0',
      targetSize: '200x200',
      targetFormat: 'jpeg'
    });
    logger.info('Thumbnail generation success event received', { data });

    try {
      // Extract information from the event data
      const { input, outputs } = data;

      if (!outputs || !Array.isArray(outputs) || outputs.length === 0) {
        logger.info('No thumbnail outputs in event, skipping', { data });
        return;
      }

      // Get the original file info
      const originalFile = input;
      const bucket = originalFile.bucket;

      // Parse the original file path to get incident info
      // Example: teams/teamId/incidents/incidentId/before/filename.jpg
      const originalPath = originalFile.name;
      const pathParts = originalPath.split('/');

      if (pathParts.length < 6 || pathParts[0] !== 'teams' || pathParts[2] !== 'incidents') {
        logger.info('Path does not match expected incident photo structure', { originalPath });
        return;
      }

      const teamId = pathParts[1];
      const incidentId = pathParts[3];
      const folder = pathParts[4]; // 'before' or 'after'
      const originalFilename = pathParts[5];

      // Find the JPEG thumbnail from outputs (200x200 size)
      const jpegOutput = outputs.find(output =>
        output.value?.outputFilePath?.endsWith('_200x200.jpeg')
      );

      if (!jpegOutput?.value?.outputFilePath) {
        logger.info('No 200x200 JPEG thumbnail found in outputs', { outputs });
        return;
      }

      const thumbnailPath = jpegOutput.value.outputFilePath;

      logger.info('Processing thumbnail for incident photo', {
        teamId,
        incidentId,
        folder,
        originalFilename,
        thumbnailPath
      });

      // Extract the token from the original file metadata and construct thumbnail URL
      const token = originalFile.metadata?.firebaseStorageDownloadTokens;
      const encodedPath = encodeURIComponent(thumbnailPath);
      const thumbnailUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${encodedPath}?alt=media&token=${token}`;

      logger.info('Generated thumbnail URL', { thumbnailUrl, token });

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
            originalFilename,
            thumbnailUrl
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
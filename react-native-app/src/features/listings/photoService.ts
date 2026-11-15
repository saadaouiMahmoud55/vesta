import * as ImagePicker from 'expo-image-picker';
import { ImageManipulator, SaveFormat } from 'expo-image-manipulator';
import { maxBase64Chars } from '../../data/models/newListing';

export type PhotoError = 'tooLarge' | 'readFailed' | 'permission';

export class PhotoFailure extends Error {
  constructor(readonly error: PhotoError) {
    super(error);
  }
}

export function photoErrorKey(error: PhotoError): string {
  return error === 'tooLarge'
    ? 'photoErrorTooLarge'
    : 'photoErrorReadFailed';
}

const side = 800;
const qualities = [0.8, 0.65, 0.5, 0.35];

/** About 800 px JPEG, under 270000 base64 characters (the rules accept 280000). */
async function compressToBase64(
  uri: string,
  width: number,
  height: number,
): Promise<string> {
  try {
    for (const quality of qualities) {
      const context = ImageManipulator.manipulate(uri);
      if (Math.max(width, height) > side) {
        context.resize(width >= height ? { width: side } : { height: side });
      }
      const image = await context.renderAsync();
      const result = await image.saveAsync({
        base64: true,
        compress: quality,
        format: SaveFormat.JPEG,
      });
      if (result.base64 && result.base64.length <= maxBase64Chars) {
        return result.base64;
      }
    }
  } catch {
    throw new PhotoFailure('readFailed');
  }
  throw new PhotoFailure('tooLarge');
}

async function toBase64(
  assets: ImagePicker.ImagePickerAsset[],
): Promise<string[]> {
  const photos: string[] = [];
  for (const asset of assets) {
    photos.push(await compressToBase64(asset.uri, asset.width, asset.height));
  }
  return photos;
}

/** Gallery: up to `remaining` photos at once. Empty list if the user cancels. */
export async function pickFromGallery(remaining: number): Promise<string[]> {
  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: ['images'],
    allowsMultipleSelection: remaining > 1,
    selectionLimit: Math.max(remaining, 1),
    quality: 1,
  });
  return result.canceled ? [] : toBase64(result.assets.slice(0, remaining));
}

/** Camera: one photo. Empty list if the user cancels. */
export async function takePhoto(): Promise<string[]> {
  const permission = await ImagePicker.requestCameraPermissionsAsync();
  if (!permission.granted) {
    throw new PhotoFailure('permission');
  }
  const result = await ImagePicker.launchCameraAsync({
    mediaTypes: ['images'],
    quality: 1,
  });
  return result.canceled ? [] : toBase64(result.assets);
}

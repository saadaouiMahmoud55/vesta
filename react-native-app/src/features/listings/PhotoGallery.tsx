import React, { useRef, useState } from 'react';
import {
  FlatList,
  Image,
  StyleSheet,
  useWindowDimensions,
  View,
  ViewToken,
} from 'react-native';
import { AppText } from '../../core/components/AppText';
import { theme } from '../../core/theme';
import { LtrText } from '../../core/ui/rtlHelpers';
import { galleryCounter } from '../../data/models/photoList';

/**
 * Photos of a listing, one per page (4:3), with the counter `1 / N` at the
 * end of the photo. Twin of the gallery of the details screen in Flutter.
 */
export function PhotoGallery({
  photos,
}: {
  photos: readonly string[];
}): React.JSX.Element {
  const { width } = useWindowDimensions();
  const height = (width * 3) / 4;
  const [index, setIndex] = useState(0);
  // Stable references: FlatList does not accept new ones on each render.
  const onViewable = useRef(
    ({ viewableItems }: { viewableItems: ViewToken[] }) => {
      const first = viewableItems[0]?.index;
      if (typeof first === 'number') {
        setIndex(first);
      }
    },
  );
  const viewability = useRef({ viewAreaCoveragePercentThreshold: 60 });

  if (photos.length === 0) {
    return (
      <View style={[styles.empty, { height }]}>
        <AppText translationKey="listingDetailNoPhoto" />
      </View>
    );
  }

  return (
    <View style={{ height }}>
      <FlatList
        data={photos}
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        keyExtractor={(_, position) => String(position)}
        onViewableItemsChanged={onViewable.current}
        viewabilityConfig={viewability.current}
        renderItem={({ item }) => (
          <Image
            source={{ uri: `data:image/jpeg;base64,${item}` }}
            style={{ width, height }}
            resizeMode="cover"
          />
        )}
      />
      {photos.length > 1 ? (
        <View style={styles.counter}>
          <LtrText style={styles.counterText}>
            {galleryCounter(index, photos.length)}
          </LtrText>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  empty: {
    alignItems: 'center',
    backgroundColor: theme.colors.sand,
    justifyContent: 'center',
  },
  counter: {
    backgroundColor: theme.colors.white,
    borderRadius: theme.radius.pill,
    bottom: theme.spacing.sm,
    end: theme.spacing.sm,
    opacity: 0.9,
    paddingHorizontal: theme.spacing.sm,
    paddingVertical: theme.spacing.xs,
    position: 'absolute',
  },
  counterText: { color: theme.colors.navy, fontSize: theme.fontSizes.small },
});

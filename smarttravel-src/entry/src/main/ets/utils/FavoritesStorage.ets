import { CollectedMarker } from '../model/CollectMarkerModel'

const STORAGE_KEY = 'activity_map_favorites'

function cloneMarker(marker: CollectedMarker): CollectedMarker {
  return {
    id: marker.id,
    latitude: marker.latitude,
    longitude: marker.longitude,
    simpleAddress: marker.simpleAddress,
    detailAddress: marker.detailAddress,
    createdAt: marker.createdAt
  }
}

function cloneMarkers(markers: CollectedMarker[]): CollectedMarker[] {
  return markers.map((item) => cloneMarker(item))
}

export function ensureFavoritesStorage() {
  if (!AppStorage.Has(STORAGE_KEY)) {
    AppStorage.SetOrCreate(STORAGE_KEY, [] as CollectedMarker[])
  }
}

export function getFavorites(): CollectedMarker[] {
  ensureFavoritesStorage()
  const markers = AppStorage.Get(STORAGE_KEY) as CollectedMarker[] | undefined
  if (!markers) {
    return []
  }
  return cloneMarkers(markers)
}

export function addFavorite(marker: CollectedMarker) {
  ensureFavoritesStorage()
  const list = getFavorites()
  const exists = list.find((item) => item.latitude === marker.latitude && item.longitude === marker.longitude)
  if (exists) {
    return
  }
  list.push(cloneMarker(marker))
  AppStorage.Set(STORAGE_KEY, list)
}

export function removeFavorite(markerId: string) {
  ensureFavoritesStorage()
  const list = getFavorites().filter((item) => item.id !== markerId)
  AppStorage.Set(STORAGE_KEY, list)
}



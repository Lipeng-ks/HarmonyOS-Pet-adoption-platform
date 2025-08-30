import { http, type ApiResp } from './http'

export interface FavoriteRecord {
  id?: number
  userId: number
  animalId: number
  createdAt?: string
}

// POST /api/favorites { userId, animalId }
export function addFavorite(userId: number, animalId: number) {
  return http.post<ApiResp<FavoriteRecord>>('/favorites', { userId, animalId }).then(r => r.data)
}

// DELETE /api/favorites?userId=&animalId=
export function removeFavorite(userId: number, animalId: number) {
  return http.delete<ApiResp>('/favorites', { params: { userId, animalId } }).then(r => r.data)
}

// GET /api/favorites/user/{userId}
export function listFavoritesByUser(userId: number) {
  return http.get<ApiResp<FavoriteRecord[]>>(`/favorites/user/${userId}`).then(r => r.data)
}

// GET /api/favorites/exists?userId=&animalId=
export function checkFavorited(userId: number, animalId: number) {
  return http.get<ApiResp & { favorited: boolean }>(`/favorites/exists`, { params: { userId, animalId } }).then(r => r.data)
}

// GET /api/favorites/batch-check?userId=&animalIds=1,2,3
export function batchCheckFavorites(userId: number, animalIds: number[]) {
  return http.get<ApiResp<Set<number> | number[]>>('/favorites/batch-check', {
    params: { userId, animalIds: animalIds.join(',') }
  }).then(r => r.data)
}

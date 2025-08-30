import { http, type ApiResp } from './http'
import type { AxiosRequestConfig } from 'axios'

export interface LostPet {
  id?: number
  userId?: number | null
  title: string
  petName?: string | null
  type?: string | null
  gender?: boolean | null
  age?: number | null
  lostTime?: string | null
  city?: string | null
  lostAddress?: string | null
  description?: string | null
  contactName?: string | null
  contactPhone?: string | null
  reward?: number | null
  image?: string | null
  status?: 'ACTIVE' | 'FOUND' | 'CLOSED'
}

// 对齐后端 /api/missing-pets 接口
export function listLostPets(params?: { status?: 'ACTIVE' | 'FOUND' | 'CLOSED'; city?: string; start?: string; end?: string }, config?: AxiosRequestConfig) {
  return http.get<ApiResp<LostPet[]>>('/missing-pets', { params, ...config }).then(r => r.data)
}

export function getLostPet(id: number) {
  return http.get<ApiResp<LostPet>>(`/missing-pets/${id}`).then(r => r.data)
}

export function createLostPet(payload: LostPet) {
  return http.post<ApiResp<LostPet>>('/missing-pets', payload).then(r => r.data)
}

export function updateLostPet(id: number, payload: Partial<LostPet>) {
  return http.put<ApiResp<LostPet>>(`/missing-pets/${id}`, payload).then(r => r.data)
}

export function deleteLostPet(id: number) {
  return http.delete<ApiResp>(`/missing-pets/${id}`).then(r => r.data)
}

export function updateStatus(id: number, status: 'ACTIVE' | 'FOUND' | 'CLOSED') {
  return http.put<ApiResp<LostPet>>(`/missing-pets/${id}/status`, { status }).then(r => r.data)
}

// 按用户ID查询该用户发布的寻宠列表：GET /api/missing-pets/user/{userId}
export function listLostPetsByUser(userId: number, config?: AxiosRequestConfig) {
  return http.get<ApiResp<LostPet[]>>(`/missing-pets/user/${userId}`, { ...config }).then(r => r.data)
}


import { http, type ApiResp } from './http'
import type { AxiosRequestConfig } from 'axios'

export interface Animal {
  id?: number
  name: string
  gender?: boolean | null
  age?: number | null
  type?: string | null
  description?: string | null
  vaccinated?: boolean | null
  dewormed?: boolean | null
  neutered?: boolean | null
  image?: string | null
  city?: string | null
  isFree?: boolean | null
  adopted?: boolean | null
  listed?: boolean | null
  userId?: number | null
}

export function listAnimals(params?: { adopted?: boolean; listed?: boolean }, config?: AxiosRequestConfig) {
  return http.get<ApiResp<Animal[]>>('/animals', { params, ...config }).then(r => r.data)
}

export function getAnimal(id: number) {
  return http.get<ApiResp<Animal>>(`/animals/${id}`).then(r => r.data)
}

export function createAnimal(payload: Animal) {
  return http.post<ApiResp<Animal>>('/animals', payload).then(r => r.data)
}

export function updateAnimal(id: number, payload: Partial<Animal>) {
  return http.put<ApiResp<Animal>>(`/animals/${id}`, payload).then(r => r.data)
}

export function deleteAnimal(id: number) {
  return http.delete<ApiResp>(`/animals/${id}`).then(r => r.data)
}

export function updateListed(id: number, listed: boolean) {
  return http.put<ApiResp<Animal>>(`/animals/${id}/listed`, null, { params: { listed } }).then(r => r.data)
}

export function getAnimalsPage(params?: { 
  page?: number; 
  size?: number; 
  adopted?: boolean; 
  listed?: boolean 
}) {
  return http.get<ApiResp<{
    records: Animal[];
    total: number;
    page: number;
    size: number;
  }>>('/animals/page', { params }).then(r => r.data)
}

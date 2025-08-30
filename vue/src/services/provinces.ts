import { http } from './http'

// GET /api/provinces -> string[]
export function listProvinces() {
  return http.get<string[]>('/provinces').then(r => r.data)
}

// GET /api/provinces/{province}/cities -> string[]
export function listCitiesByProvince(province: string) {
  return http.get<string[]>(`/provinces/${encodeURIComponent(province)}/cities`).then(r => r.data)
}

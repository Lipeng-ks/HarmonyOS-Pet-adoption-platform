import { http, type ApiResp } from './http'

export interface City {
  id?: number
  name: string
  code?: string | null
  province?: string | null
}

export function listCities() {
  return http.get<ApiResp<City[]>>('/cities').then(r => r.data)
}

import { http, type ApiResp } from './http'

export interface UserAddress {
  id?: number
  name: string
  phone: string
  city: string
  detail: string
  isDefault?: boolean
}

export function listUserAddresses(username: string) {
  return http.get<ApiResp<UserAddress[]>>(`/users/${encodeURIComponent(username)}/addresses`).then(r => r.data)
}

export function addUserAddress(username: string, payload: UserAddress) {
  return http.post<ApiResp<{ id: number }>>(`/users/${encodeURIComponent(username)}/addresses`, payload).then(r => r.data)
}

export function updateUserAddress(username: string, id: number, payload: Partial<UserAddress>) {
  return http.put<ApiResp>(`/users/${encodeURIComponent(username)}/addresses/${id}`, payload).then(r => r.data)
}

export function deleteUserAddress(username: string, id: number) {
  return http.delete<ApiResp>(`/users/${encodeURIComponent(username)}/addresses/${id}`).then(r => r.data)
}
